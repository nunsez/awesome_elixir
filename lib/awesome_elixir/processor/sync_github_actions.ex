defprotocol AwesomeElixir.Processor.SyncGithubActions do
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.Processor.GithubRepo

  @spec github_libraries(deps :: struct()) :: [AwesomeElixir.Context.Library.t()]
  def github_libraries(_)

  @spec repo_api(deps :: struct(), url :: String.t()) :: {:ok, map()} | {:error, any()}
  def repo_api(_, url)

  @spec update_library(
          deps :: struct(),
          library :: AwesomeElixir.Context.Library.t(),
          attrs :: map()
        ) ::
          {:ok, AwesomeElixir.Context.Library.t()}
          | {:error, Ecto.Changeset.t(AwesomeElixir.Context.Library.t())}
  def update_library(_, library, attributes)

  @spec github_repo_call(deps :: struct(), info :: map()) :: GithubRepo.call_return()
  def github_repo_call(_, info)
end

defimpl AwesomeElixir.Processor.SyncGithubActions, for: AwesomeElixir.ProductionDependencies do
  alias AwesomeElixir.Context
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.Processor.SyncGithub

  def github_libraries(_) do
    SyncGithub.github_libraries()
  end

  def repo_api(_, url) do
    GithubClient.repo_api(url)
  end

  def update_library(_, library, attributes) do
    Context.update_library(library, attributes)
  end

  def github_repo_call(_, info) do
    GithubRepo.call(info)
  end
end

defimpl AwesomeElixir.Processor.SyncGithubActions, for: Map do
  alias AwesomeElixir.Context.Library

  def github_libraries(deps) do
    deps
    |> Map.get(:github_libraries, fn -> [] end)
    |> apply([])
  end

  def repo_api(deps, url) do
    deps
    |> Map.get(:repo_api, fn url -> {:ok, %{url: url}} end)
    |> apply([url])
  end

  def update_library(deps, library, attributes) do
    deps
    |> Map.get(:update_library, fn _, attrs -> {:ok, struct(Library, attrs)} end)
    |> apply([library, attributes])
  end

  def github_repo_call(deps, info) do
    deps
    |> Map.get(:github_repo_call, fn info -> info end)
    |> apply([info])
  end
end
