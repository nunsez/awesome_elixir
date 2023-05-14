defmodule AwesomeElixir.Processor.SyncCategory do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.Processor.SyncLibrary
  alias AwesomeElixir.Processor.SyncLibraryDeps
  alias AwesomeElixir.ProductionDependencies

  @spec call(category_item :: Index.category_item()) :: :ok
  def call(category_item) do
    call(ProductionDependencies.new(), category_item)
  end

  @spec call(deps :: SyncLibraryDeps.t(), category_item :: Index.category_item()) :: :ok
  def call(deps, category_item) do
    actual_attributes = %{
      name: category_item.name,
      description: category_item.description
    }

    update_result =
      case Context.get_category_by(name: category_item.name) do
        nil ->
          Context.create_category(actual_attributes)

        category ->
          Context.update_category(category, actual_attributes)
      end

    handle_update_libraries(deps, update_result, category_item.repos)

    :ok
  end

  def handle_update_libraries(deps, {:ok, category}, repos) do
    existing_repo_urls = Enum.map(repos, & &1.url)
    Context.delete_stale_libraries(category.id, existing_repo_urls)

    for repo_item <- repos do
      SyncLibrary.call(deps, repo_item, category)
    end
  end

  def handle_update_libraries({:error, changeset}, _repos) do
    name = Map.get(changeset.changes, :name) || Map.get(changeset.data, :name)

    Logger.error("Category sync error: #{name}")
  end
end
