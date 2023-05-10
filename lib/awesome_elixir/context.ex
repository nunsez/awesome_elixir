defmodule AwesomeElixir.Context do
  @moduledoc false

  import Ecto.Query

  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Context.CategoryQueries
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.Repo

  @spec create_library(attrs :: map() | none()) ::
          {:ok, Library.t()} | {:error, Ecto.Changeset.t(Library.t())}
  def create_library(attrs \\ %{}) do
    %Library{}
    |> Library.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_library(library :: Library.t(), attrs :: map() | none()) ::
          {:ok, Library.t()} | {:error, Ecto.Changeset.t(Library.t())}
  def update_library(library, attrs \\ %{}) do
    library
    |> Library.changeset(attrs)
    |> Repo.update()
  end

  @spec change_library(library :: Library.t(), attrs :: map() | none()) ::
          Ecto.Changeset.t(Library.t())
  def change_library(library, attrs \\ %{}) do
    Library.changeset(library, attrs)
  end

  @spec create_category(attrs :: map() | none()) ::
          {:ok, Category.t()} | {:error, Ecto.Changeset.t(Category.t())}
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_category(category :: Category.t(), attrs :: map() | none()) ::
          {:ok, Category.t()} | {:error, Ecto.Changeset.t(Category.t())}
  def update_category(category, attrs \\ %{}) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @spec change_category(category :: Category.t(), attrs :: map() | none()) ::
          Ecto.Changeset.t(Category.t())
  def change_category(category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  @spec categories(min_stars :: integer() | none()) :: [Category.t()]
  def categories(min_stars \\ 0)

  def categories(min_stars) when is_integer(min_stars) and min_stars >= 0 do
    min_stars
    |> all_categories()
    |> Repo.all()
    |> Enum.reject(&no_libraries?/1)
  end

  def categories(_) do
    categories(0)
  end

  @spec all_categories(min_stars :: integer()) :: Ecto.Query.t()
  def all_categories(min_stars) do
    from(
      Category,
      preload: [libraries: ^sorted_libraries(min_stars)]
    )
  end

  @spec sorted_libraries(min_stars :: integer()) :: Ecto.Query.t()
  def sorted_libraries(min_stars) do
    from(
      l in Library,
      where: l.stars >= ^min_stars,
      order_by: [desc: l.last_commit > ago(6, "month")],
      order_by: [desc: l.stars]
    )
  end

  @spec no_libraries?(category :: Category.t()) :: boolean()
  def no_libraries?(category) do
    Enum.empty?(category.libraries)
  end

  @spec delete_stale_categories(existing_category_names :: [String.t()]) :: :ok
  def delete_stale_categories([]), do: :ok

  def delete_stale_categories(existing_category_names) when is_list(existing_category_names) do
    category_ids =
      Category
      |> CategoryQueries.stale_categories(existing_category_names)
      |> select([c], {c.id})

    categories_library_urls =
      Library
      |> where([l], l.category_id in subquery(category_ids))
      |> select([l], {l.url})

    Repo.transaction(fn ->
      Repo.delete_all(categories_library_urls)
      Repo.delete_all(category_ids)
    end)

    :ok
  end

  # TODO: write tests
  @spec delete_stale_libraries(category_name :: String.t(), library_urls :: [String.t()]) :: :ok
  def delete_stale_libraries(category_name, existing_library_urls)
      when is_binary(category_name) and is_list(existing_library_urls) do
    category_id =
      Category
      |> where([c], c.name == ^category_name)
      |> select([l], {l.url})

    libraries =
      Library
      |> where([l], l.category_id == subquery(category_id))
      |> where([l], l.url not in ^existing_library_urls)

    Repo.delete_all(libraries)

    :ok
  end

  @spec get_category_by(clauses :: keyword()) :: Category.t() | nil
  def get_category_by(clauses) when is_list(clauses) do
    Repo.get_by(Category, clauses)
  end

  @spec get_library_by(clauses :: keyword()) :: Library.t() | nil
  def get_library_by(clauses) when is_list(clauses) do
    Repo.get_by(Library, clauses)
  end
end
