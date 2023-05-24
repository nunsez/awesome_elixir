defmodule AwesomeElixirWeb.Helpers.DelimiterTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixirWeb.Helpers.Delimiter

  alias AwesomeElixirWeb.Helpers.Delimiter

  describe "call/2" do
    test "positive lower than 1000" do
      assert Delimiter.call(777) == "777"
    end

    test "positive greater than 1000" do
      assert Delimiter.call(1500) == "1 500"
    end

    test "negative lower than -1000" do
      assert Delimiter.call(-1500) == "-1 500"
    end

    test "negative greater than -1000" do
      assert Delimiter.call(-777) == "-777"
    end

    test "custom delimiter" do
      assert Delimiter.call(-1500, ",") == "-1,500"
    end

    test "big positive number" do
      assert Delimiter.call(10_000_000) == "10 000 000"
    end

    test "big negative number" do
      assert Delimiter.call(-100_000_000) == "-100 000 000"
    end
  end
end
