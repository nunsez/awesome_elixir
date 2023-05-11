defmodule AwesomeElixir.Processor.SyncGithub do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.Repo

  @spec call() :: :ok
  def call do
    github_libraries()
    |> Task.async_stream(
      &sync_github_library(&1),
      max_concurrency: GithubClient.pool_size()
    )
    |> Stream.run()
  end

  def with_url_prefix(string) when is_binary(string) do
    url_prefix() <> string
  end

  def url_prefix, do: "https://github.com/"

  @spec github_libraries() :: [Library.t()]
  def github_libraries do
    import Ecto.Query, only: [where: 3]

    pattern = with_url_prefix("%")

    Library
    |> where([l], like(l.url, ^pattern))
    |> Repo.all()
  end

  @spec sync_github_library(library :: Library.t()) ::
          {:ok, Library.t()} | {:error, Ecto.Changeset.t(Library.t())}
  def sync_github_library(library) do
    sync_github_library(library, &GithubClient.repo_api/1)
  end

  @spec sync_github_library(
          library :: Library.t(),
          api_worker :: (url :: String.t() -> {:ok, map()} | {:error, any()})
        ) :: {:ok, Library.t()} | {:error, Ecto.Changeset.t(Library.t())}
  def sync_github_library(library, api_worker) do
    api_response = api_worker.(library.url)
    handle_api_response(api_response, library)
  end

  def handle_api_response({:ok, info}, library) do
    attrs = GithubRepo.call(info)

    Context.update_library(library, attrs)
  end

  def handle_api_response({:error, reason} = response, library) do
    Logger.error("#{reason} #{library.url}")

    response
  end
end
