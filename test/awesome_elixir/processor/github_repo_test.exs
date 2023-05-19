defmodule AwesomeElixir.Processor.GithubRepoTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.Processor.GithubRepo

  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.TestHelper, as: H

  describe "call/1" do
    test "works" do
      info = %{
        "pushed_at" => "2023-03-12T16:51:13Z",
        "stargazers_count" => 91
      }

      result = GithubRepo.call(info)

      assert result == %{
               stars: 91,
               last_commit: ~U[2023-03-12 16:51:13Z]
             }
    end
  end

  describe "url_to_api_url/1" do
    test "base case" do
      url = "https://github.com/antonmi/ALF"
      expected = "https://api.github.com/repos/antonmi/ALF"
      result = GithubRepo.url_to_api_url(url)

      assert result == {:ok, expected}
    end

    test "nested" do
      url = "https://github.com/elixir-lang/elixir/wiki"
      expected = "https://api.github.com/repos/elixir-lang/elixir"
      result = GithubRepo.url_to_api_url(url)

      assert result == {:ok, expected}
    end

    test "trailing slash" do
      url = "https://github.com/benjamintanweihao/elixir-cheatsheets/"
      expected = "https://api.github.com/repos/benjamintanweihao/elixir-cheatsheets"
      result = GithubRepo.url_to_api_url(url)

      assert result == {:ok, expected}
    end

    test "invalid" do
      url = "https://github.com/invalid"
      result = GithubRepo.url_to_api_url(url)

      assert {:error, _} = result
    end
  end

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
