defmodule AwesomeElixir.GithubClient do
  @moduledoc false

  alias AwesomeElixir.Html

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    Finch.start_link(
      name: __MODULE__,
      pools: %{
        :default => [size: 10],
        "https://github.com" => [size: pools_size()]
      }
    )
  end

  def pools_size, do: 5

  @spec index_doc() :: Html.document()
  def index_doc do
    url = "https://github.com/h4cc/awesome-elixir"
    headers = [{"content-type", "text/html"}]
    response = response!(url, headers)

    Html.parse(response.body)
  end

  @spec repo_doc(String.t()) :: Html.document()
  def repo_doc(url) do
    headers = [{"content-type", "text/html"}]

    {:ok, response} =
      :get
      |> Finch.build(url, headers)
      |> Finch.request(__MODULE__)

    Html.parse(response.body)
  end

  def repo_api(url) do
    api_url = String.replace(url, "github.com", "api.github.com/repos")
    response = response!(api_url, api_headers())
    json = Jason.decode!(response.body)

    case response.status do
      status when status >= 300 and status < 400 ->
        response2 = response!(json["url"], api_headers())
        json = Jason.decode!(response2.body)
        {:ok, json}

      status when status >= 400 and status < 500 ->
        {:error, :not_found}

      status when status >= 500 and status < 600 ->
        {:error, :server_error}

      _ ->
        {:ok, json}
    end
  end

  @spec api_headers(String.t() | nil) :: [{String.t(), String.t()}]
  def api_headers(_github_token \\ nil) do
    github_token = Application.get_env(:awesome_elixir, :github_token)

    [
      {"Accept", "application/vnd.github+json"},
      {"Authorization", "Bearer #{github_token}"},
      {"X-GitHub-Api-Version", "2022-11-28", "ds"}
    ]
  end

  def rate_limit do
    url = "https://api.github.com/rate_limit"
    response = response!(url, api_headers())

    Jason.decode!(response.body)
  end

  @spec response!(String.t(), [{String.t(), String.t()}], map() | nil) :: Finch.Response.t()
  def response!(url, headers, body \\ nil) do
    {:ok, response} =
      :get
      |> Finch.build(url, headers, body)
      |> Finch.request(__MODULE__)

    response
  end
end
