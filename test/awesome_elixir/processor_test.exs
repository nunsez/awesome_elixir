defmodule AwesomeElixir.ProcessorTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.Processor

  alias AwesomeElixir.AssertOrdered
  alias AwesomeElixir.Processor

  def category_items_data do
    [
      %{
        name: "name1",
        description: "",
        repos: []
      },
      %{
        name: "name2",
        description: "",
        repos: []
      }
    ]
  end

  describe "call/1" do
    test "works" do
      {:ok, agent} = AssertOrdered.start_link([])

      category_items = category_items_data()
      category_items_size = Enum.count(category_items)

      deps = %{
        fetch_categories: fn ->
          AssertOrdered.push(agent, :fetch_categories)

          category_items
        end,
        delete_stale_categories: fn names ->
          AssertOrdered.push(agent, :delete_stale_categories)

          assert Enum.count(names) == category_items_size

          :ok
        end,
        sync_category: fn _item ->
          AssertOrdered.push(agent, :sync_category)

          :ok
        end,
        sync_github_libraries: fn ->
          AssertOrdered.push(agent, :sync_github_libraries)
        end
      }

      Processor.call(deps)

      expected_messages = [
        :fetch_categories,
        :delete_stale_categories,
        :sync_category,
        :sync_category,
        :sync_github_libraries
      ]

      assert expected_messages == AssertOrdered.result(agent)
    end
  end
end
