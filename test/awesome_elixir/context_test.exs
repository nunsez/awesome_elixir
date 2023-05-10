defmodule AwesomeElixir.ContextTest do
  @moduledoc false

  use AwesomeElixir.DataCase, async: true
  doctest AwesomeElixir.Context

  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.ContextFixtures
  alias AwesomeElixir.Repo

  describe "libraries" do
    @invalid_attrs %{name: nil, url: nil, description: nil}

    test "create_library/1 with valid data creates library" do
      category = ContextFixtures.create_category()
      valid_attrs = %{
        name: "some name",
        url: "https://example.com/acc/repo",
        description: "desc",
        category_id: category.id
      }

      assert {:ok, %Library{} = library} = Context.create_library(valid_attrs)
      assert library.name == "some name"
      assert library.description == "desc"
      assert library.category_id == category.id
    end

    test "create_library/1 with invalid data returns changeset" do
      assert {:error, %Ecto.Changeset{}} = Context.create_library(@invalid_attrs)
    end

    test "update_library/2 with valid data updates library" do
      category = ContextFixtures.create_category()
      library = ContextFixtures.create_library(%{category_id: category.id})
      last_commit = ~U[2023-05-10 03:56:33Z]
      update_attrs = %{last_commit: last_commit, stars: 555}

      assert {:ok, %Library{} = library} = Context.update_library(library, update_attrs)
      assert library.last_commit == last_commit
      assert library.stars == 555
    end

    test "update_library/2 with invalid data returns changeset" do
      category = ContextFixtures.create_category()
      library = ContextFixtures.create_library(%{category_id: category.id})

      assert {:error, %Ecto.Changeset{}} = Context.update_library(library, @invalid_attrs)
    end
  end

  describe "categories" do
    @invalid_attrs %{name: nil, description: nil}

    test "create_category/1 with valid data creates category" do
      valid_attrs = %{name: "some name", description: "some desc"}

      assert {:ok, %Category{} = category} = Context.create_category(valid_attrs)
      assert category.name == "some name"
      assert category.description == "some desc"
    end

    test "create_category/1 with invalid data returns changeset" do
      assert {:error, %Ecto.Changeset{}} = Context.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates category" do
      category = ContextFixtures.create_category()
      update_attrs = %{description: "some desc"}

      assert {:ok, %Category{} = category} = Context.update_category(category, update_attrs)
      assert category.description == "some desc"
    end

    test "update_category/2 with invalid data returns changeset" do
      category = ContextFixtures.create_category()

      assert {:error, %Ecto.Changeset{}} = Context.update_category(category, @invalid_attrs)
    end

    test "categories/1 without min_stars returns categories with libraries" do
      category = ContextFixtures.create_category_with_libraries(%{}, 1)
      ContextFixtures.create_category_with_libraries(%{}, 0)

      categories = Context.categories()

      assert categories == [category]
    end

    test "categories/1 with min_stars returns categories with libraries that have enough stars" do
      category1 = ContextFixtures.create_category()
      ContextFixtures.create_library(%{stars: 100, category_id: category1.id})

      category2 = ContextFixtures.create_category()
      ContextFixtures.create_library(%{stars: 500, category_id: category2.id})
      category2_with_libs = Repo.preload(category2, :libraries)

      categories = Context.categories(300)

      assert categories == [category2_with_libs]
    end

    test "categories/1 with invalid min_stars returns all categories" do
      ContextFixtures.create_category_with_libraries(%{}, 1)
      ContextFixtures.create_category_with_libraries(%{}, 1)

      categories = Context.categories("foo")

      assert Enum.count(categories) == 2
    end
  end
end
