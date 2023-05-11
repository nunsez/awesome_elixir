defmodule AwesomeElixir.Processor.SyncGithub do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.Repo

  defstruct github_libraries: &__MODULE__.github_libraries/0,
            repo_api: &GithubClient.repo_api/1,
            update_library: &Context.update_library/2,
            github_repo_call: &GithubRepo.call/1

  @type t() :: %__MODULE__{
          github_libraries: (() -> [Library.t()]),
          repo_api: (String.t() -> {:ok, map()} | {:error, any()}),
          update_library:
            (Library.t(), map() -> {:ok, Library.t()} | {:error, Ecto.Changeset.t(Library.t())}),
          github_repo_call: (map() -> GithubRepo.call_return())
        }

  @spec new(overrides :: map()) :: t()
  def new(overrides \\ %{}) do
    struct(__MODULE__, overrides)
  end

  @spec call() :: :ok
  def call, do: call(new())

  @spec call(opts :: t()) :: :ok
  def call(%__MODULE__{} = opts) do
    opts.github_libraries.()
    |> Task.async_stream(
      &sync_github_library(&1, opts),
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

  @spec sync_github_library(library :: Library.t(), opts :: t()) ::
          {:ok, Library.t()} | {:error, Ecto.Changeset.t(Library.t())}
  def sync_github_library(library, opts) do
    response_result = opts.repo_api.(library.url)

    case response_result do
      {:ok, info} ->
        attrs = opts.github_repo_call.(info)
        opts.update_library.(library, attrs)

      {:error, reason} ->
        Logger.error("#{reason} #{library.url}")

      _ ->
        Logger.error("#{response_result} #{library.url}")
    end
  end
end
