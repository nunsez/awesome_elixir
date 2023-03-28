defmodule AwesomeElixir.Processor do
  @moduledoc false

  alias AwesomeElixir.Category
  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.Repo

  def sync_categories do
    document = GithubClient.index_doc()
    category_items = Index.call(document)

    for category_item <- category_items do
      case Repo.get_by(Category, name: category_item.name) do
        nil -> %Category{name: category_item.name}
        category -> category
      end
      |> Category.changeset(%{description: category_item.description})
      |> Repo.insert_or_update()
    end
  end
end
