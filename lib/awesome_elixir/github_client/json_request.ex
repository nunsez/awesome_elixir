defmodule AwesomeElixir.GithubClient.JsonRequest do
  @moduledoc false

  alias AwesomeElixir.GithubClient.Request

  @spec get(url :: String.t(), redirect_count :: non_neg_integer() | nil) ::
          {:ok, map()} | {:error, any()}
  def get(url, redirect_count \\ 3)

  def get(url, redirect_count) do
    response_result = Request.get(url, Request.api_headers())

    case response_result do
      {:ok, response} -> handle(response, redirect_count)
      error -> error
    end
  end

  # handle 20x
  def handle(%{status: status, body: body}, _)
      when status >= 200 and status < 300 do
    {:ok, Jason.decode!(body)}
  end

  # handle 30x redirects
  def handle(%{status: status} = response, redirect_count)
      when status in [301, 302, 303, 307, 308] do
    if redirect_count > 0 do
      json = Jason.decode!(response.body)

      get(json["url"], redirect_count - 1)
    else
      {:error, :too_many_redirects}
    end
  end

  def handle(%{status: status}, _) do
    {:error, "Status: #{status}"}
  end
end
