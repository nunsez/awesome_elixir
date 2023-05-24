defprotocol AwesomeElixir.Processor.SyncGithubDeps do
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.Processor.GithubRepo

  @spec github_libraries(deps :: any()) :: [Library.t()]
  def github_libraries(_)

  @spec repo_info(deps :: any(), url :: String.t()) :: {:ok, GithubRepo.info()} | {:error, any()}
  def repo_info(_, url)

  @spec update_library(
          deps :: any(),
          library :: Library.t(),
          attrs :: GithubRepo.info()
        ) ::
          {:ok, Library.t()}
          | {:error, Ecto.Changeset.t(Library.t())}
  def update_library(_, library, attributes)
end

defimpl AwesomeElixir.Processor.SyncGithubDeps, for: AwesomeElixir.ProductionDependencies do
  alias AwesomeElixir.Context
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.SyncGithub

  def github_libraries(_) do
    SyncGithub.github_libraries()
  end

  def repo_info(_, url) do
    GithubClient.repo_info(url)
  end

  def update_library(_, library, attributes) do
    Context.update_library(library, attributes)
  end
end

defimpl AwesomeElixir.Processor.SyncGithubDeps, for: Map do
  alias AwesomeElixir.Context

  def github_libraries(%{github_libraries: f}) do
    f.()
  end

  def github_libraries(_) do
    []
  end

  def repo_info(%{repo_api: f}, url) do
    f.(url)
  end

  def repo_info(_, url) do
    {:ok, %{url: url}}
  end

  def update_library(%{update_library: f}, library, attributes) do
    f.(library, attributes)
  end

  def update_library(_, library, attributes) do
    Context.change_library(library, attributes)
  end
end
