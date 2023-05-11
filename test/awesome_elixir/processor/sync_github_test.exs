defmodule AwesomeElixir.Processor.SyncGithubTest do
  @moduledoc false

  use AwesomeElixir.DataCase, async: true
  doctest AwesomeElixir.Processor.SyncGithub

  alias AwesomeElixir.Context.Library
  alias AwesomeElixir.ContextFixtures
  alias AwesomeElixir.Processor.SyncGithub

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
      initial_lib = ContextFixtures.create_library()

      data = %{
        "stargazers_count" => 321,
        "pushed_at" => "2023-01-01T08:00:00Z"
      }

      api_worker = fn _ -> {:ok, data} end
      sync_result = SyncGithub.sync_github_library(initial_lib, api_worker)

      assert {:ok, %Library{} = updated_lib} = sync_result
      assert updated_lib.stars == 321
      assert updated_lib.last_commit == ~U[2023-01-01 08:00:00Z]
    end

    @tag capture_log: true
    test "do nothing when error" do
      api_worker = fn _ -> {:error, :test_reason} end
      sync_result = SyncGithub.sync_github_library(%Library{}, api_worker)

      assert {:error, :test_reason} = sync_result
    end
  end
end
