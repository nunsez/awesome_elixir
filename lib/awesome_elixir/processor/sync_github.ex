defmodule AwesomeElixir.Processor.SyncGithub do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.SyncGithubDeps
  alias AwesomeElixir.ProductionDependencies
  alias AwesomeElixir.Repo

  @spec call() :: :ok
  def call, do: call(ProductionDependencies.new())

  @spec call(deps :: SyncGithubDeps.t()) :: :ok
  def call(deps) do
    SyncGithubDeps.github_libraries(deps)
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

  @spec sync_github_library(library :: Library.t(), deps :: SyncGithubDeps.t()) ::
          {:ok, Library.t()} | {:error, Ecto.Changeset.t(Library.t())}
  def sync_github_library(library, deps) do
    response_result = SyncGithubDeps.repo_api(deps, library.url)

    case response_result do
      {:ok, info} ->
        attrs = SyncGithubDeps.github_repo_call(deps, info)
        SyncGithubDeps.update_library(deps, library, attrs)

      {:error, reason} ->
        Logger.error("#{reason} #{library.url}")

      _ ->
        Logger.error("#{response_result} #{library.url}")
    end
  end
end
