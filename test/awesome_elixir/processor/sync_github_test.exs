defmodule AwesomeElixir.Processor.SyncGithubTest do
  @moduledoc false

  use AwesomeElixir.DataCase, async: true
  doctest AwesomeElixir.Processor.SyncGithub

  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.ContextFixtures
  alias AwesomeElixir.Processor.SyncGithub

  describe "call/1" do
    test "processes all libraries" do
      parent = self()

      lib1 = %Library{url: "url-1"}
      lib2 = %Library{url: "url-2"}

      opts = SyncGithub.new(%{
        github_libraries: fn -> [lib2, lib1] end,
        repo_api: fn _ -> {:ok, %{}} end,
        github_repo_call: fn _ -> :stub end,
        update_library: fn lib, _ -> send(parent, lib.url) end
      })

      SyncGithub.call(opts)

      for url <- ["url-1", "url-2"] do
        assert_received ^url
      end
    end
  end

  describe "github_libraries/0" do
    test "returns github library list" do
      github_lib1 = ContextFixtures.create_library(url: SyncGithub.with_url_prefix("lib-1"))
      github_lib2 = ContextFixtures.create_library(url: SyncGithub.with_url_prefix("lib-2"))
      ContextFixtures.create_library(url: "https://example.com/another/library")

      github_libraries = SyncGithub.github_libraries()

      assert github_libraries == [github_lib1, github_lib2]
    end
  end

  describe "sync_github_library/2" do
    test "updates library when ok" do
      parent = self()

      opts = SyncGithub.new(%{
        repo_api: fn _ -> {:ok, %{}} end,
        github_repo_call: fn _ -> :stub end,
        update_library: fn _, _ -> send(parent, :update_library) end
      })

      SyncGithub.sync_github_library(%Library{}, opts)

      assert_received :update_library
    end

    @tag capture_log: true
    test "does not update library when error" do
      parent = self()

      opts = SyncGithub.new(%{
        repo_api: fn _ -> {:error, :test_reason} end,
        github_repo_call: fn _ -> :stub end,
        update_library: fn _, _ -> send(parent, :update_library) end
      })

      SyncGithub.sync_github_library(%Library{}, opts)

      refute_received :update_library
    end
  end
end
