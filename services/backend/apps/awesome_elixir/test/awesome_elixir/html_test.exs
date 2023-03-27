defmodule AwesomeElixir.HtmlTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest AwesomeElixir.Html

  alias AwesomeElixir.Html
  alias AwesomeElixir.TestHelper, as: H

  setup_all context do
    doc = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Html Title</title>
    </head>
    <body>
        <div id="empty"></div>

        <ul id="list" class="list" data-count="3">
            <li>One</li>
            <li>Two</li>
            <li>Three</li>
        </ul>
    </body>
    </html>
    """

    new_context = Map.put(context, :doc, doc)

    {:ok, new_context}
  end

  describe "parse/1" do
    test "valid html" do
      html = """
      <!DOCTYPE html>
      <html lang="en">
        <head></head>
        <body></body>
      </html>
      """

      assert [
               {"html", [{"lang", "en"}],
                [
                  {"head", [], []},
                  {"body", [], []}
                ]}
             ] = Html.parse(html)
    end
  end

  describe "find/2" do
    test "single node", %{doc: doc} do
      node = Html.find(doc, "body #empty")

      assert [{"div", [{"id", "empty"}], _}] = node
    end

    test "multiple nodes", %{doc: doc} do
      assert [_, _, _] = Html.find(doc, "ul.list li")
    end

    test "empty result", %{doc: doc} do
      assert [] = Html.find(doc, "invalid query")
    end
  end

  describe "attribute/2" do
    test "existing attribute", %{doc: doc} do
      assert Html.attribute(doc, "lang") == "en"
    end

    test "nonexistent attribute", %{doc: doc} do
      assert Html.attribute(doc, "nope") == nil
    end
  end

  describe "attribute/3" do
    test "existing attribute existing element", %{doc: doc} do
      assert Html.attribute(doc, "#list", "data-count") == "3"
    end

    test "nonexistent attribute existing element", %{doc: doc} do
      assert Html.attribute(doc, "#list", "nope") == nil
    end

    test "nonexistent attribute nonexistent element", %{doc: doc} do
      assert Html.attribute(doc, "#nope", "nonexistent") == nil
    end

    test "invalid attribute", %{doc: doc} do
      assert Html.attribute(doc, "#nope", "inva lid!") == nil
    end
  end

  describe "attr/4" do
    test "changes the attribute value", %{doc: doc} do
      selector = "html"
      attribute = "lang"

      new_doc = Html.attr(doc, selector, attribute, fn value -> value <> "glish" end)

      assert Html.attribute(new_doc, selector, attribute) == "english"
    end

    test "sets a new attribute with the value", %{doc: doc} do
      selector = "html"
      attribute = "foo"
      value = "bar"

      new_doc = Html.attr(doc, selector, attribute, fn _ -> value end)

      assert Html.attribute(new_doc, selector, attribute) == value
    end
  end
end
