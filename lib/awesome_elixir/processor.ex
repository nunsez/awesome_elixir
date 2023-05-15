defmodule AwesomeElixir.Processor do
  @moduledoc false

  require Logger

  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.ProcessorDeps
  alias AwesomeElixir.ProductionDependencies
  alias AwesomeElixir.Repo

  @spec call() :: :ok
  def call do
    call(ProductionDependencies.new())
  end

  @spec call(deps :: ProcessorDeps.t()) :: :ok
  def call(deps) do
    sync_categories(deps)
    sync_libraries_data(deps)

    :ok
  end

  @spec sync_categories() :: :ok
  def sync_categories do
    sync_categories(ProductionDependencies.new())
  end

  @spec sync_categories(deps :: ProcessorDeps.t()) :: :ok
  def sync_categories(deps) do
    category_items = ProcessorDeps.fetch_categories(deps)

    existing_category_names = Enum.map(category_items, & &1.name)
    ProcessorDeps.delete_stale_categories(deps, existing_category_names)

    category_items
    |> Task.async_stream(
      &ProcessorDeps.sync_category(deps, &1),
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

  @spec sync_libraries_data(deps :: ProcessorDeps.t()) :: :ok
  def sync_libraries_data(deps) do
    ProcessorDeps.sync_github_libraries(deps)

    :ok
  end
end
