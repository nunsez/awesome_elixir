defmodule AwesomeElixir.Processor.SyncCategoryTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.Processor.SyncCategory

  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Processor.SyncCategory

  def category_item_data(overrides \\ %{}) do
    Enum.into(overrides, %{
      name: "test category name",
      description: "category description",
      repos: []
    })
  end

  describe "call/2" do
    test "creates category if not present" do
      parent = self()

      deps = %{
        get_category_by: fn _ -> nil end,
        create_category: fn attrs ->
          send(parent, :create_category)

          {:ok, struct(Category, attrs)}
        end,
        update_libraries: fn _, _, _ ->
          send(parent, :update_libraries)

          :ok
        end
      }

      SyncCategory.call(deps, category_item_data())

      assert_received :create_category
      assert_received :update_libraries
    end

    test "updates category if present" do
      parent = self()

      deps = %{
        update_category: fn _category, attrs ->
          send(parent, :update_category)

          {:ok, struct(Category, attrs)}
        end,
        update_libraries: fn _, _, _ ->
          send(parent, :update_libraries)

          :ok
        end
      }

      SyncCategory.call(deps, category_item_data())

      assert_received :update_category
      assert_received :update_libraries
    end

    test "deletes stale libraries if category was created" do
      parent = self()

      deps = %{
        get_category_by: fn _ -> nil end,
        create_category: fn attrs ->
          send(parent, :create_category)

          {:ok, struct(Category, attrs)}
        end,
        delete_stale_libraries: fn _, _ ->
          send(parent, :delete_stale_libraries)

          :ok
        end
      }

      SyncCategory.call(deps, category_item_data())

      assert_received :create_category
      assert_received :delete_stale_libraries
    end

    test "deletes stale libraries if category was updated" do
      parent = self()

      deps = %{
        update_category: fn _category, attrs ->
          send(parent, :update_category)

          {:ok, struct(Category, attrs)}
        end,
        delete_stale_libraries: fn _, _ ->
          send(parent, :delete_stale_libraries)

          :ok
        end
      }

      SyncCategory.call(deps, category_item_data())

      assert_received :update_category
      assert_received :delete_stale_libraries
    end
  end
end
