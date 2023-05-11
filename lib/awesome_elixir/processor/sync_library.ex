defmodule AwesomeElixir.Processor.SyncLibrary do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Processor.Index

  @spec call(Index.repo_item(), Category.t()) :: :ok
  def call(repo_item, category) do
    actual_attributes = %{
      url: repo_item.url,
      name: repo_item.name,
      description: repo_item.description,
      category_id: category.id
    }

    update_result =
      case Context.get_library_by(url: repo_item.url) do
        nil ->
          Context.create_library(actual_attributes)

        library ->
          Context.update_library(library, actual_attributes)
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
