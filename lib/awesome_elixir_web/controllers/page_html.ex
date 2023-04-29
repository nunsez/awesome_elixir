defmodule AwesomeElixirWeb.PageHTML do
  alias AwesomeElixir.Category
  use AwesomeElixirWeb, :html

  embed_templates "page_html/*"

  def home(assigns) do
    ~H"""
    <.header>List of Categories</.header>
    <.category_list items={@categories} />
    """
  end

  def home_solid(assigns) do
    ~H"""
    <div id="app"></div>
    """
  end

  attr :items, :list, required: true

  defp category_list(assigns) do
    ~H"""
    <ul>
    <%= for item <- @items do %>
      <.category item={item} />
    <% end %>
    </ul>
    """
  end

  attr :item, Category, required: true

  defp category(assigns) do
    ~H"""
    <li>
      <%= @item.name %>: <%= @item.name %>
    </li>
    """
  end
end
