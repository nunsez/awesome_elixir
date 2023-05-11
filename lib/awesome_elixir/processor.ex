defmodule AwesomeElixir.Processor do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.Processor.SyncCategory
  alias AwesomeElixir.Processor.SyncGithub
  alias AwesomeElixir.Repo

  @spec call() :: :ok
  def call do
    sync_categories(%SyncCategory{})
    sync_libraries_data()

    :ok
  end

  @spec sync_categories(t :: struct()) :: :ok
  def sync_categories(t) do
    category_items = fetch_categories()

    category_items
    |> Enum.map(& &1.name)
    |> Context.delete_stale_categories()

    category_items
    |> Task.async_stream(
      fn item -> SyncCategory.call(t, item) end,
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
