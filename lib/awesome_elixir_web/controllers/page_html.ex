defmodule AwesomeElixirWeb.PageHTML do
  use AwesomeElixirWeb, :html

  alias AwesomeElixir.Category
  alias AwesomeElixir.Delimiter
  alias AwesomeElixir.Library
  alias AwesomeElixirWeb.Gettext
  alias Phoenix.LiveComponent

  embed_templates "page_html/*"

  attr :categories, :list, default: []

  @spec category_list(assigns :: map()) :: LiveComponent.t()
  def category_list(assigns)

  attr :categories, :list, default: []

  @spec library_list(assigns :: map()) :: LiveComponent.t()
  def library_list(assigns)

  @spec category_id(category :: Category.t()) :: String.t()
  def category_id(category), do: "category-#{category.id}"

  @spec category_anchor(category :: Category.t()) :: String.t()
  def category_anchor(category), do: "#" <> category_id(category)

  @spec days_from_last_commit(library :: Library.t()) :: integer()
  def days_from_last_commit(%Library{} = library) do
    DateTime.utc_now()
    |> DateTime.diff(library.last_commit, :day)
  end

  @spec delimit(number :: integer()) :: String.t()
  def delimit(number), do: Delimiter.call(number, " ")

  @spec days(number :: integer()) :: String.t()
  def days(number) do
    Gettext.ngettext("day", "days", number)
  end
end
