defmodule AwesomeElixir.Synchronizer.SyncLibraryTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.Synchronizer.SyncLibrary

  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.Synchronizer.SyncLibrary

  import ExUnit.CaptureLog

  def repo_item_data(overrides \\ %{}) do
    Enum.into(overrides, %{
      name: "test name",
      url: "test.example.com/acc/repo",
      description: "awesome test lib"
    })
  end

  describe "call/3" do
    test "updates library if present" do
      parent = self()

      deps = %{
        update_library: fn _, _ ->
          send(parent, :update_library)

          {:ok, %Library{}}
        end
      }

      SyncLibrary.call(deps, repo_item_data(), %Category{})

      assert_received :update_library
    end

    test "creates library if not present" do
      parent = self()

      deps = %{
        get_library_by: fn _ -> nil end,
        create_library: fn info ->
          send(parent, :create_library)

          {:ok, struct(Library, info)}
        end
      }

      SyncLibrary.call(deps, repo_item_data(), %Category{})

      assert_received :create_library
    end

    test "log error when unable to update" do
      changeset = Context.change_library(%Library{})

      deps = %{
        update_library: fn _, _ -> {:error, changeset} end
      }

      fun = fn ->
        SyncLibrary.call(deps, repo_item_data(), %Category{})
      end

      assert capture_log(fun) =~ "error"
    end

    test "log error when unable to create" do
      changeset = Context.change_library(%Library{})

      deps = %{
        get_library_by: fn _ -> nil end,
        create_library: fn _ -> {:error, changeset} end
      }

      fun = fn ->
        SyncLibrary.call(deps, repo_item_data(), %Category{})
      end

      assert capture_log(fun) =~ "error"
    end
  end
end
