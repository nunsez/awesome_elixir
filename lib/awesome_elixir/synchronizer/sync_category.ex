defmodule AwesomeElixir.Synchronizer.SyncCategory do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Synchronizer.Index
  alias AwesomeElixir.Synchronizer.SyncCategoryDeps
  alias AwesomeElixir.Synchronizer.SyncLibrary
  alias AwesomeElixir.ProductionDependencies

  @spec call(category_item :: Index.category_item()) :: :ok
  def call(category_item) do
    call(ProductionDependencies.new(), category_item)
  end

  @spec call(deps :: SyncCategoryDeps.t(), category_item :: Index.category_item()) :: :ok
  def call(deps, category_item) do
    actual_attributes = %{
      name: category_item.name,
      description: category_item.description
    }

    update_result =
      case SyncCategoryDeps.get_category_by(deps, name: category_item.name) do
        nil ->
          SyncCategoryDeps.create_category(deps, actual_attributes)

        category ->
          SyncCategoryDeps.update_category(deps, category, actual_attributes)
      end

    SyncCategoryDeps.update_libraries(deps, update_result, category_item.repos)

    :ok
  end

  @spec update_libraries(
          deps :: SyncCategoryDeps.t(),
          update_result ::
            {:ok, Category.t()}
            | {:error, Ecto.Changeset.t(Category.t())},
          repos :: [Index.repo_item()]
        ) :: any()
  def update_libraries(deps, {:ok, category}, repos) do
    existing_library_urls = Enum.map(repos, & &1.url)
    SyncCategoryDeps.delete_stale_libraries(deps, category.id, existing_library_urls)

    for repo_item <- repos do
      SyncLibrary.call(deps, repo_item, category)
    end
  end

  def update_libraries({:error, changeset}, _repos) do
    name = Map.get(changeset.changes, :name) || Map.get(changeset.data, :name)

    Logger.error("Category sync error: #{name}")
  end
end
