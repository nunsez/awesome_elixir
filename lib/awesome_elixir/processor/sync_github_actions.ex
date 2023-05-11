defprotocol AwesomeElixir.Processor.SyncGithubActions do
  def github_libraries(_t)

  def repo_api(_t, url)

  def update_library(_t, library, attributes)

  def github_repo_call(_t, info)
end

defmodule AwesomeElixir.Processor.SyncGithubDependencies do
  @moduledoc false

  defstruct []

  def new, do: %__MODULE__{}
end

defimpl AwesomeElixir.Processor.SyncGithubActions,
  for: AwesomeElixir.Processor.SyncGithubDependencies do
  alias AwesomeElixir.Context
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.Processor.SyncGithub

  def github_libraries(_t) do
    SyncGithub.github_libraries()
  end

  def repo_api(_t, url) do
    GithubClient.repo_api(url)
  end

  def update_library(_t, library, attributes) do
    Context.update_library(library, attributes)
  end

  def github_repo_call(_t, info) do
    GithubRepo.call(info)
  end
end

defmodule AwesomeElixir.Processor.SyncGithubFakeDependencies do
  @moduledoc false

  alias AwesomeElixir.Context.Library

  defstruct [
    :github_libraries,
    :repo_api,
    :update_library,
    :github_repo_call
  ]

  def new(overrides \\ %{}) do
    attributes = Enum.into(overrides, defaults())

    struct(__MODULE__, attributes)
  end

  def defaults do
    %{
      github_libraries: fn -> :stub end,
      repo_api: fn url -> {:ok, %{url: url}} end,
      update_library: fn _, attrs -> {:ok, struct(Library, attrs)} end,
      github_repo_call: fn info -> info end
    }
  end
end

defimpl AwesomeElixir.Processor.SyncGithubActions,
  for: AwesomeElixir.Processor.SyncGithubFakeDependencies do
  def github_libraries(t) do
    t.github_libraries.()
  end

  def repo_api(t, url) do
    t.repo_api.(url)
  end

  def update_library(t, library, attributes) do
    t.update_library.(library, attributes)
  end

  def github_repo_call(t, info) do
    t.github_repo_call.(info)
  end
end
