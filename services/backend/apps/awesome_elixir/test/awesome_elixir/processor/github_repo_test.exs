defmodule AwesomeElixir.Processor.GithubRepoTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.Processor.GithubRepo

  # alias AwesomeElixir.Html
  alias AwesomeElixir.Processor.GithubRepo
  alias AwesomeElixir.TestHelper, as: H

  describe "call/2" do
    test "1" do
      doc = H.doc("github_rebar3_hex.html")
      item = %{
        name: "rebar3_hex",
        description: "Hex.pm plugin for rebar3."
      }
      result = GithubRepo.call(doc, item)

      assert result == %{
               name: "rebar3_hex",
               description: "Hex.pm plugin for rebar3.",
               stars: 91,
               last_commit: ~U[2023-03-12 16:51:13Z]
             }
    end
  end
end
