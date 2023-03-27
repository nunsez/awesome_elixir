defmodule AwesomeElixir.Processor.IndexTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.Processor.Index

  # alias AwesomeElixir.Html
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.TestHelper, as: H

  test "call/1" do
    doc = H.doc("awesome_elixir.html")
    result = Index.call(doc)

    name = "Package Management"
    category = Enum.find(result, & &1.name == name)

    assert category.description == "Libraries and tools for package and dependency management."
    assert category.repos == [
      %{
        name: "Hex",
        url: "https://hex.pm/",
        description: "A package manager for the Erlang ecosystem."
      },
      %{
        name: "rebar3_hex",
        url: "https://github.com/hexpm/rebar3_hex",
        description: "Hex.pm plugin for rebar3."
      }
    ]
  end
end
