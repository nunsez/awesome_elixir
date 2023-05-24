defmodule AwesomeElixir.GithubClientTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.GithubClient

  alias AwesomeElixir.GithubClient
  alias AwesomeElixir.Html

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "index_doc/1" do
    test "works", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/h4cc/awesome-elixir", fn conn ->
        Plug.Conn.resp(conn, 200, ~s{<html>test response</html>})
      end)

      url = "http://localhost:#{bypass.port}/h4cc/awesome-elixir"
      doc = GithubClient.index_doc(url)

      assert Html.text(doc) =~ "test response"
    end
  end
end
