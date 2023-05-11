defmodule AwesomeElixir.Processor.SyncCategory do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context
  alias AwesomeElixir.Processor.CategorySyncer
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.Processor.SyncLibrary

  defstruct []

  @spec call(t :: struct(), category_item :: Index.category_item()) :: :ok
  def call(t, category_item) do
    actual_attributes = %{
      name: category_item.name,
      description: category_item.description
    }

    update_result =
      case CategorySyncer.get_category_by(t, name: category_item.name) do
        nil ->
          CategorySyncer.create_category(t, actual_attributes)

        category ->
          CategorySyncer.update_category(t, category, actual_attributes)
      end

    CategorySyncer.handle_update_libraries(t, update_result, category_item.repos)

    :ok
  end

  def handle_update_libraries(t, {:ok, category}, repos) do
    existing_repo_urls = Enum.map(repos, & &1.url)
    Context.delete_stale_libraries(category.id, existing_repo_urls)

    for repo_item <- repos do
      SyncLibrary.call(t, repo_item, category)
    end
  end

  def handle_update_libraries(_t, {:error, changeset}, _repos) do
    name = Map.get(changeset.changes, :name) || Map.get(changeset.data, :name)

    Logger.error("Category sync error: #{name}")
  end
end

defimpl AwesomeElixir.Processor.CategorySyncer, for: AwesomeElixir.Processor.SyncCategory do
  alias AwesomeElixir.Context
  alias AwesomeElixir.Processor.SyncCategory
  alias AwesomeElixir.Processor.SyncLibrary

  def get_category_by(_t, clauses) do
    Context.get_category_by(clauses)
  end

  def create_category(_t, actual_attributes) do
    Context.create_category(actual_attributes)
  end

  def update_category(_t, category, actual_attributes) do
    Context.update_category(category, actual_attributes)
  end

  def handle_update_libraries(_t, update_result, category_repos) do
    SyncCategory.handle_update_libraries(%SyncLibrary{}, update_result, category_repos)
  end
end
