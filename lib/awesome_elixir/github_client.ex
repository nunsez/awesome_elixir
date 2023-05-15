defmodule AwesomeElixir.GithubClient do
  @moduledoc false

  alias AwesomeElixir.GithubClient.JsonRequest
  alias AwesomeElixir.GithubClient.Request
  alias AwesomeElixir.Html
  alias AwesomeElixir.Processor.GithubRepo

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
        "https://github.com" => [size: pool_size()]
      }
    )
  end

  @pool_size 5

  def pool_size, do: @pool_size

  @index_doc_url "https://github.com/h4cc/awesome-elixir"

  @spec index_doc() :: Html.document()
  def index_doc do
    index_doc(@index_doc_url)
  end

  @spec index_doc(url :: String.t()) :: Html.document()
  def index_doc(url) do
    headers = [{"content-type", "text/html"}]
    {:ok, response} = Request.get(url, headers)

    Html.parse(response.body)
  end

  @spec repo_api(url :: String.t()) :: {:ok, map()} | {:error, any()}
  def repo_api(url) do
    url_result = GithubRepo.url_to_api_url(url)

    case url_result do
      {:ok, api_url} -> JsonRequest.get(api_url)
      error -> error
    end
  end

  @rate_limit_url "https://api.github.com/rate_limit"

  @spec rate_limit() :: map()
  def rate_limit do
    rate_limit(@rate_limit_url)
  end

  @spec rate_limit(url :: String.t()) :: map()
  def rate_limit(url) do
    {:ok, json} = JsonRequest.get(url)

    json
  end
end
