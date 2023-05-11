defmodule AwesomeElixir.Processor do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.Processor.SyncCategory
  alias AwesomeElixir.Processor.SyncGithub
  alias AwesomeElixir.Repo

  defstruct [
    fetch_categories: &__MODULE__.fetch_categories/0,
    delete_stale_categories: &Context.delete_stale_categories/1,
    sync_category: &SyncCategory.call/1,
  ]

  @type t() :: %__MODULE__{
    fetch_categories: (() -> [Index.category_item()]),
    delete_stale_categories: (([String.t()]) -> :ok),
    sync_category: ((Index.category_item()) -> :ok)
  }

  @spec new(overrides :: map()) :: t()
  def new(overrides \\ %{}) do
    struct(__MODULE__, overrides)
  end

  @spec call() :: :ok
  def call do
    sync_categories()
    sync_libraries_data()

    :ok
  end

  @spec sync_categories() :: :ok
  def sync_categories do
    sync_categories(new())
  end

  @spec sync_categories(opts :: t()) :: :ok
  def sync_categories(%__MODULE__{} = opts) do
    category_items = opts.fetch_categories.()

    category_items
    |> Enum.map(& &1.name)
    |> opts.delete_stale_categories.()

    category_items
    |> Task.async_stream(
      opts.sync_category,
      max_concurrency: pool_size()
    )
    |> Stream.run()

    :ok
  end

  @spec fetch_categories() :: [Index.category_item()]
  def fetch_categories do
    GithubClient.index_doc()
    |> Index.call()
  end

  @spec pool_size() :: pos_integer()
  defp pool_size do
    size = Repo.config()[:pool_size]

    if is_integer(size) and size > 1 do
      floor(size / 2)
    else
      1
    end
  end

  @spec sync_libraries_data() :: :ok
  def sync_libraries_data do
    SyncGithub.call()

    :ok
  end
end
