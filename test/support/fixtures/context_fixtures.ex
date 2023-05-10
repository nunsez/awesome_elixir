defmodule AwesomeElixir.ContextFixtures do
  @moduledoc false

  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.Repo

  @spec create_category_with_libraries(
          overrides :: map() | none(),
          libraries_count :: non_neg_integer() | none()
        ) :: Category.t()
  def create_category_with_libraries(overrides \\ %{}, libraries_count \\ 1) do
    category = build_category_with_libraries(overrides, libraries_count)

    Repo.insert!(category)
  end

  @spec build_category_with_libraries(
          overrides :: map() | none(),
          libraries_count :: non_neg_integer() | none()
        ) :: Ecto.Changeset.t(Category.t())
  def build_category_with_libraries(overrides \\ %{}, libraries_count \\ 1) do
    category = build_category(overrides)

    libraries =
      for i <- 0..libraries_count, i > 0 do
        library_attributes(%{name: "lib-#{i}"})
      end

    category
    |> Ecto.Changeset.cast(%{libraries: libraries}, [])
    |> Ecto.Changeset.cast_assoc(:libraries, with: &Context.change_library/2)
  end

  def build_category(overrides \\ %{}) do
    attrs = category_attributes(overrides)

    Context.change_category(%Category{}, attrs)
  end

  @spec create_category(overrides :: map() | none()) :: Category.t()
  def create_category(overrides \\ %{}) do
    {:ok, category} =
      overrides
      |> category_attributes()
      |> Context.create_category()

    category
  end

  @spec category_attributes(overrides :: map() | none()) :: map()
  def category_attributes(overrides \\ %{}) do
    name = "category-" <> secure_random(4)

    Enum.into(overrides, %{
      name: name,
      description: "Awesome description"
    })
  end

  @spec create_library(overrides :: map() | none()) :: Library.t()
  def create_library(overrides \\ %{}) do
    {:ok, library} =
      overrides
      |> library_attributes()
      |> Context.create_library()

    library
  end

  @spec library_attributes(overrides :: map() | none()) :: map()
  def library_attributes(overrides \\ %{}) do
    name = "library-" <> secure_random(4)

    Enum.into(overrides, %{
      description: "Awesome description",
      last_commit: DateTime.add(DateTime.utc_now(), -7, :day),
      name: name,
      stars: 50,
      url: "https://example.com/account/#{name}"
    })
  end

  defp secure_random(n) do
    :crypto.strong_rand_bytes(n)
    |> Base.encode64()
    |> Base.url_encode64(padding: false)
  end
end
