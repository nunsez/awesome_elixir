defmodule AwesomeElixir.GithubClient.Request do
  @moduledoc false

  @spec api_headers(String.t() | nil) :: [{String.t(), String.t()}]
  def api_headers(_github_token \\ nil) do
    github_token = Application.get_env(:awesome_elixir, :github_token)

    [
      {"Accept", "application/vnd.github+json"},
      {"Authorization", "Bearer #{github_token}"},
      {"X-GitHub-Api-Version", "2022-11-28", "ds"}
    ]
  end

  @spec get(url :: String.t(), headers :: [{String.t(), String.t()}], body :: map() | nil) ::
          {:ok, Finch.Response.t()} | {:error, Exception.t()}
  def get(url, headers, body \\ nil) do
    :get
    |> Finch.build(url, headers, body)
    |> Finch.request(__MODULE__)
  end
end
