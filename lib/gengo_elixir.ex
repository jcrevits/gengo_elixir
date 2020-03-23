defmodule Gengo do
  @moduledoc """
    Methods for the Gengo API - https://developers.gengo.com/
  """
  alias Requests

  # ACCOUNT METHODS - https://developers.gengo.com/v2/api_methods/account/

  def me() do
    Requests.general_request(:get, "/account/me")
  end

  def stats() do
    Requests.general_request(:get, "/account/stats")
  end

  def account_balance() do
    response = Requests.general_request(:get, "/account/balance")

    {response.credits, response.currency}
  end

  def preferred_translators() do
    Requests.general_request(:get, "/account/preferred_translators")
  end

  # SERVICE METHODS - https://developers.gengo.com/v2/api_methods/service/

  def languages() do
    Requests.general_request(:get, "/translate/service/languages")
  end

  def language_pairs() do
    Requests.general_request(:get, "/translate/service/language_pairs")
  end

  @doc """
  [%{body_src: "tesuto blah", lc_src: "en", lc_tgt: "ja", tier: "standard"}]
  """
  def quote(jobs) do
    Requests.request_with_body(:post, "/translate/service/quote", "data", %{jobs: jobs})
  end

  # ORDER METHODS - https://developers.gengo.com/v2/api_methods/order

  def order_details(order_id) do
    Requests.general_request(:get, "/translate/order/#{order_id}")
  end

  def order_cancel(order_id) do
    response = Requests.general_request(:delete, "/translate/order/#{order_id}")

    response[:order]
  end

  def order_comments(order_id) do
    response = Requests.general_request(:get, "/translate/order/#{order_id}/comments")

    response[:thread]
  end

  def order_comment_add(order_id, comment) do
    data = %{
      id: order_id,
      body: comment
    }

    Requests.post_request("/translate/order/#{order_id}/comment", data)
  end

  # JOBS METHODS - https://developers.gengo.com/v2/api_methods/jobs/

  # https://developers.gengo.com/v2/api_methods/jobs/#jobs-post
  # [%{body_src: "tesuto blah", lc_src: "en", lc_tgt: "ja", tier: "standard"}]
  def jobs_create(jobs) do
    Requests.request_with_body(:post, "/translate/jobs", "data", %{jobs: jobs})
  end

  # https://developers.gengo.com/v2/api_methods/jobs/#jobs-get
  # status: “available”, “pending”, “reviewable”, “approved”, “rejected”, or “canceled”
  # timestamp_after: Epoch timestamp from which to filter submitted jobs
  # count: defaults to 10 (maximum 200)
  # example :
  # [
  #   status: "reviewable",
  #   timestamp_after: 12390,
  #   count: 200
  # ]
  def jobs_retrieve(filters) do
    Requests.general_request(:get, "/translate/jobs", filters)
  end

  # https://developers.gengo.com/v2/api_methods/jobs/#jobs-by-id-get
  # Enum of integers
  def jobs_by_ids(job_ids) do
    joined_ids = Enum.join(job_ids, ",")
    response = Requests.general_request(:get, "/translate/jobs/#{joined_ids}")

    response[:jobs]
  end

  # https://developers.gengo.com/v2/api_methods/jobs/#jobs-put
  # revise: [%{action: "revise", job_ids: [%{job_id: 123}], comment: "Your comment here"}]
  # approve: [%{job_id: 123, rating: 1-5, for_translator: "comment for translator, for_mygengo: "gengo comment", public: 0 or 1}]
  # reject: [%{job_id: 123, reason: “quality”, “incomplete”, “other”, comment: "leave comment", follow_up: requeue or cancel}]
  # archive: [%{action: "archive", job_ids: [905103]}]
  def jobs_update(payload) do
    Requests.request_with_body(:put, "/translate/jobs", "data", payload)
  end

  # job_ids: Enum of job_id (int)
  def jobs_archive(job_ids) do
    Requests.general_request(
      :put,
      "/translate/jobs",
      [],
      [%{action: "archive", job_ids: job_ids}]
    )
  end

  # JOB METHODS - https://developers.gengo.com/v2/api_methods/job

  # job details - https://developers.gengo.com/v2/api_methods/job/#job-get
  def job_details(job_id) do
    response = Requests.request_with_body(:get, "/translate/job/#{job_id}", "data", %{id: job_id})

    response[:job]
  end

  # job delete - https://developers.gengo.com/v2/api_methods/job/#job-delete
  def job_cancel(job_id) do
    Requests.request_with_body(:delete, "/translate/job/#{job_id}", "data", %{id: job_id})
  end

  # job comments - https://developers.gengo.com/v2/api_methods/job/#comments-get
  def job_comments(job_id) do
    Requests.request_with_body(:get, "/translate/job/#{job_id}/comments", "data", %{id: job_id})
  end

  # job post comments - https://developers.gengo.com/v2/api_methods/job/#comment-post
  def job_comments_create(job_id, comment) do
    Requests.request_with_body(:get, "/translate/job/#{job_id}/comments", "data", %{
      id: job_id,
      body: comment
    })
  end

  # job revisions - https://developers.gengo.com/v2/api_methods/job/#revisions-get
  def job_revisions_by_job_id(job_id) do
    response = Requests.general_request(:get, "/translate/job/#{job_id}/revisions")

    response[:revisions]
  end

  # archive - https://developers.gengo.com/v2/api_methods/job/#job-put
  def job_archive(job_id) do
    Requests.request_with_body(:put, "/translate/job/#{job_id}", "action", %{action: "archive"})
  end

  # job specific revision - https://developers.gengo.com/v2/api_methods/job/#revision-get
  def job_revision_by_job_and_revision_id(job_id, revision_id) do
    Requests.general_request(:get, "/translate/job/#{job_id}/revision/#{revision_id}")
  end

  # job feedback - https://developers.gengo.com/v2/api_methods/job/#feedback-get
  def job_feedback_by_job_id(job_id) do
    response =
      Requests.request_with_body(:get, "/translate/job/#{job_id}/feedback", "data", %{id: job_id})

    response[:feedback]
  end

  # GLOSSARY METHODS - https://developers.gengo.com/v2/api_methods/glossary/

  # retrieve glossaries - https://developers.gengo.com/v2/api_methods/glossary/#glossaries-get
  def glossaries() do
    Requests.general_request(:get, "/translate/glossary")
  end

  def glossary_by_id(glossary_id) do
    Requests.general_request(:get, "/translate/glossary/#{glossary_id}")
  end
end
