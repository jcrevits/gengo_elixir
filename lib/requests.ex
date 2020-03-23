defmodule Requests do
  @moduledoc """
    Handles HTTP requests
  """

  # SANDBOX
  @gengo_api_url "http://api.sandbox.gengo.com/v2"
  @public_key "PUBLIC_KEY"
  @private_key "PRIVATE_KEY"

  use Tesla

  def auth do
    timestamp = DateTime.utc_now() |> DateTime.to_unix() |> to_string

    [
      api_key: @public_key,
      api_sig: calculate_sig(timestamp),
      ts: timestamp
    ]
  end

  def calculate_sig(timestamp) do
    :crypto.mac(
      :hmac,
      :sha,
      @private_key,
      timestamp
    )
    |> Base.encode16()
    |> String.downcase()
  end

  def general_request(method, url, params \\ [], body \\ nil) do
    case Tesla.request(
           client(),
           url: url,
           method: method,
           query: auth() ++ params,
           body: body
         ) do
      {:ok, %{body: body}} ->
        process_response(body)

      {:error, _} ->
        IO.puts("Request error")
    end
  end

  def process_response(body) do
    {:ok, decoded} = Poison.decode(body, keys: :atoms)

    case decoded[:opstat] do
      "ok" ->
        decoded[:response]

      "error" ->
        IO.puts("Error: #{decoded[:err][:msg]} (code: #{decoded[:err][:code]})")

      _ ->
        IO.inspect(decoded)
    end
  end

  def post_request(url, payload) do
    general_request(:post, url, [], payload |> encode())
  end

  def request_with_body(method, url, field_name, data) do
    multipart =
      Tesla.Multipart.new()
      |> Tesla.Multipart.add_field(field_name, data |> encode())

    general_request(method, url, [], multipart)
  end

  def encode(payload) do
    Poison.encode!(payload, [])
  end

  # somehow this endpoint is different - no opstat in response, and no v2 in url...
  def unit_count_request(data) do
    {:ok, %{body: results}} = Tesla.post(client(), "/service/unit_count", data)

    results
  end

  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl, @gengo_api_url},
      Tesla.Middleware.Logger
    ]

    adapter = {Tesla.Adapter.Hackney, [recv_timeout: 30_000]}

    Tesla.client(middleware, adapter)
  end
end
