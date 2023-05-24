defmodule AwesomeElixir.Processor.GithubRepoTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.Processor.GithubRepo

  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.TestHelper, as: H

  describe "stars/1" do
    test "works" do
      doc = H.doc("commits_page.html")

      assert {:ok, 133} = GithubRepo.stars(doc)
    end
  end

  describe "last_commit/1" do
    test "valid datetime" do
      doc = H.doc("commits_page.html")

      assert {:ok, ~U[2023-05-18 14:32:47Z]} = GithubRepo.last_commit(doc)
    end

    test "node not found" do
      doc = H.doc("datetime_not_found.html")

      assert {:error, :not_found} = GithubRepo.last_commit(doc)
    end

    test "invalid datetime format" do
      doc = H.doc("datetime_invalid_format.html")

      assert {:error, :invalid_format} = GithubRepo.last_commit(doc)
    end
  end
end
