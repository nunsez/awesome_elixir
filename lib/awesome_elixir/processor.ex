defmodule AwesomeElixir.Processor do
  @moduledoc false

  alias AwesomeElixir.Category
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Library
  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.Repo

  def sync_categories do
    document = GithubClient.index_doc()
    category_items = Index.call(document)

    delete_stale_categories(category_items)

    for category_item <- category_items do
      update_result =
        case Repo.get_by(Category, name: category_item.name) do
          nil -> %Category{name: category_item.name}
          category -> category
        end
        |> Category.changeset(%{description: category_item.description})
        |> Repo.insert_or_update()

      handle_repos(update_result, category_item.repos)
    end

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
    %{stars: stars, last_commit: last_commit} = GithubRepo.call(info)

    library
    |> Library.changeset(%{stars: stars, last_commit: last_commit})
    |> Repo.insert_or_update()
  end

  def handle_api_response({:error, :not_found}, library) do
    IO.puts("Library not found #{library.url}")
  end

  def handle_api_response({:error, :server_error}, library) do
    IO.puts("Server error on #{library.url}")
  end

  def handle_api_response({:error, :invalid_url}, library) do
    IO.puts("Invalid url #{library.url}")
  end

  def handle_repo({:ok, _library}) do
    # do nothing
  end

  def handle_repo({:error, changeset}) do
    dd = Map.get(changeset.changes, :url) || Map.get(changeset.data, :url)
    IO.inspect(dd)
  end

  def handle_repos({:ok, category}, repos) do
    delete_stale_repos(category, repos)

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

      handle_repo(update_result)
    end
  end

  def handle_repos({:error, changeset}, _repos) do
    dd = Map.get(changeset.changes, :name) || Map.get(changeset.data, :name)
    IO.inspect(dd)
  end

  @spec delete_stale_categories([Index.category_item()]) :: any()
  def delete_stale_categories(category_items) do
    import Ecto.Query, only: [from: 2]

    existing_category_names = Enum.map(category_items, & &1.name)
    query = from(c in Category, where: c.name not in ^existing_category_names)
    Repo.delete_all(query)
  end

  @spec delete_stale_repos(Category.t(), [Index.repo_item()]) :: any()
  def delete_stale_repos(category, repos) do
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
