defmodule AwesomeElixir.Synchronizer.SyncLibrary do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Synchronizer.Index
  alias AwesomeElixir.Synchronizer.SyncLibraryDeps
  alias AwesomeElixir.ProductionDependencies

  @spec call(
          repo_item :: Index.repo_item(),
          category :: Category.t()
        ) :: :ok
  def call(repo_item, category) do
    call(ProductionDependencies.new(), repo_item, category)
  end

  @spec call(
          deps :: SyncLibraryDeps.t(),
          repo_item :: Index.repo_item(),
          category :: Category.t()
        ) :: :ok
  def call(deps, repo_item, category) do
    actual_attributes = %{
      url: repo_item.url,
      name: repo_item.name,
      description: repo_item.description,
      category_id: category.id
    }

    update_result =
      case SyncLibraryDeps.get_library_by(deps, url: repo_item.url) do
        nil ->
          SyncLibraryDeps.create_library(deps, actual_attributes)

        library ->
          SyncLibraryDeps.update_library(deps, library, actual_attributes)
      end

    handle_update_library(update_result)

    :ok
  end

  def handle_update_library({:ok, _library}) do
    # do nothing
  end

  def handle_update_library({:error, changeset}) do
    repo_url = Map.get(changeset.changes, :url) || Map.get(changeset.data, :url)

    Logger.error("Library update error: #{repo_url}")
  end
end
