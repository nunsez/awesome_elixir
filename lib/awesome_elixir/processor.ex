defmodule AwesomeElixir.Processor do
  @moduledoc false

  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.Repo

  require Logger

  def category_attributes(category_item) do
    %{
      name: category_item.name,
      description: category_item.description
    }
  end

  def sync_category(category_item) do
    attrs = category_attributes(category_item)

    update_result =
      case Repo.get_by(Category, name: category_item.name) do
        nil ->
          Context.create_category(attrs)

        category ->
          Context.update_category(category, attrs)
      end

    handle_update_libraries(update_result, category_item.repos)
  end

  def sync_categories do
    document = GithubClient.index_doc()
    category_items = Index.call(document)

    category_items
    |> Enum.map(& &1.name)
    |> Context.delete_stale_categories()

    Enum.each(category_items, &sync_category/1)

    sync_libraries()

    :ok
  end

  def sync_libraries do
    sync_github()
  end

  def sync_github do
    import Ecto.Query, only: [from: 2]

    query = from(l in Library, where: like(l.url, "https://github.com/%"))
    libraries = Repo.all(query)

    Task.async_stream(
      libraries,
      fn library ->
        result = GithubClient.repo_api(library.url)
        handle_api_response(result, library)
      end,
      max_concurrency: GithubClient.pools_size()
    )
    |> Stream.run()
  end

  def handle_api_response({:ok, info}, library) do
    attrs = GithubRepo.call(info)

    Context.update_library(library, attrs)
  end

  def handle_api_response({:error, reason}, library) do
    Logger.error("#{reason} #{library.url}")
  end

  def handle_update_libraries({:ok, category}, repos) do
    delete_stale_libraries(category, repos)

    for repo_item <- repos do
      update_result =
        case Repo.get_by(Library, url: repo_item.url) do
          nil -> %Library{url: repo_item.url}
          repo -> repo
        end
        |> Library.changeset(%{
          name: repo_item.name,
          description: repo_item.description,
          category_id: category.id
        })
        |> Repo.insert_or_update()

      handle_update_library(update_result)
    end
  end

  def handle_update_libraries({:error, changeset}, _repos) do
    name = Map.get(changeset.changes, :name) || Map.get(changeset.data, :name)

    Logger.error("Category sync error: #{name}")
  end

  def handle_update_library({:ok, _library}) do
    # do nothing
  end

  def handle_update_library({:error, changeset}) do
    repo_url = Map.get(changeset.changes, :url) || Map.get(changeset.data, :url)

    Logger.error("Library update error: #{repo_url}")
  end

  @spec delete_stale_libraries(Category.t(), [Index.repo_item()]) :: any()
  def delete_stale_libraries(category, repos) do
    import Ecto.Query, only: [from: 2]

    existing_repo_urls = Enum.map(repos, & &1.url)

    query =
      from(l in Library,
        where: l.category_id == ^category.id,
        where: l.url not in ^existing_repo_urls
      )

    Repo.delete_all(query)
  end
end
