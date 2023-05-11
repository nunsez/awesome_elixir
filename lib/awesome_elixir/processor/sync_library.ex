defmodule AwesomeElixir.Processor.SyncLibrary do
  @moduledoc false

  require Logger

  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.Processor.LibrarySyncer

  defstruct []

  @spec call(t :: struct(), Index.repo_item(), Category.t()) :: :ok
  def call(t, repo_item, category) do
    actual_attributes = %{
      url: repo_item.url,
      name: repo_item.name,
      description: repo_item.description,
      category_id: category.id
    }

    update_result =
      case LibrarySyncer.get_library_by(t, url: repo_item.url) do
        nil ->
          LibrarySyncer.create_library(t, actual_attributes)

        library ->
          LibrarySyncer.update_library(t, library, actual_attributes)
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

defimpl AwesomeElixir.Processor.LibrarySyncer, for: AwesomeElixir.Processor.SyncLibrary do
  alias AwesomeElixir.Context

  def get_library_by(_t, clauses) do
    Context.get_library_by(clauses)
  end

  def create_library(_t, attrs) do
    Context.create_library(attrs)
  end

  def update_library(_t, library, attrs) do
    Context.update_library(library, attrs)
  end
end
