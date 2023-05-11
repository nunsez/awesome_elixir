defmodule AwesomeElixir.Processor.SyncGithub do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.Repo

  defstruct github_libraries: &__MODULE__.github_libraries/0,
            repo_api: &GithubClient.repo_api/1

  @type t() :: %__MODULE__{
          github_libraries: (() -> [Library.t()]),
          repo_api: (String.t() -> {:ok, map()} | {:error, any()})
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

  @spec sync_github_library(library :: Library.t(), opts :: t()) ::
          {:ok, Library.t()} | {:error, Ecto.Changeset.t(Library.t())}
  def sync_github_library(library, opts) do
    library.url
    |> opts.repo_api.()
    |> handle_api_response(library)
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
