defmodule AwesomeElixir.Processor.GithubRepoTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.Processor.GithubRepo

  # alias AwesomeElixir.Html
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
end
