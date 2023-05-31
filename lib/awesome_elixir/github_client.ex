defmodule AwesomeElixir.GithubClient do
  @moduledoc false

  alias AwesomeElixir.Html
  alias AwesomeElixir.Synchronizer.GithubRepo

  use Tesla,
    only: [:get],
    adapter: {Tesla.Adapter.Finch, name: __MODULE__}

  plug Tesla.Middleware.FollowRedirects

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

  @spec index_doc(url :: String.t()) :: Html.document()
  def index_doc(url \\ @index_doc_url) do
    {:ok, response} = get(url)

    Html.parse(response.body)
  end

  @spec repo_info(url :: String.t()) :: {:ok, map()} | {:error, any()}
  def repo_info(url) do
    with {:ok, commits_url} <- GithubRepo.commits_url(url),
         {:ok, response} <- get(commits_url),
         doc <- Html.parse(response.body),
         {:ok, last_commit} <- GithubRepo.last_commit(doc),
         {:ok, stars} <- GithubRepo.stars(doc) do
      data = %{
        stars: stars,
        last_commit: last_commit
      }

      {:ok, data}
    else
      error -> error
    end
  end
end
