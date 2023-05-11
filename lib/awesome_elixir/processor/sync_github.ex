defmodule AwesomeElixir.Processor.SyncGithub do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.SyncGithubActions
  alias AwesomeElixir.Processor.SyncGithubDependencies
  alias AwesomeElixir.Repo

  @spec call() :: :ok
  def call, do: call(%SyncGithubDependencies{})

  @spec call(deps :: SyncGithubActions.t()) :: :ok
  def call(deps) do
    SyncGithubActions.github_libraries(deps)
    |> Task.async_stream(
      &sync_github_library(&1, deps),
      max_concurrency: GithubClient.pool_size()
    )
    |> Stream.run()
  end

  @spec with_url_prefix(string :: String.t()) :: String.t()
  def with_url_prefix(string) when is_binary(string) do
    url_prefix() <> string
  end

  @spec url_prefix() :: String.t()
  def url_prefix, do: "https://github.com/"

  @spec github_libraries() :: [Library.t()]
  def github_libraries do
    import Ecto.Query, only: [where: 3]

    pattern = with_url_prefix("%")

    Library
    |> where([l], like(l.url, ^pattern))
    |> Repo.all()
  end

  @spec sync_github_library(library :: Library.t(), deps :: SyncGithubActions.t()) ::
          {:ok, Library.t()} | {:error, Ecto.Changeset.t(Library.t())}
  def sync_github_library(library, deps) do
    response_result = SyncGithubActions.repo_api(deps, library.url)

    case response_result do
      {:ok, info} ->
        attrs = SyncGithubActions.github_repo_call(deps, info)
        SyncGithubActions.update_library(deps, library, attrs)

      {:error, reason} ->
        Logger.error("#{reason} #{library.url}")

      _ ->
        Logger.error("#{response_result} #{library.url}")
    end
  end
end
