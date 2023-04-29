defmodule AwesomeElixirWeb.PageHTML do
  alias AwesomeElixir.Category
  use AwesomeElixirWeb, :html

  embed_templates "page_html/*"

  def home(assigns) do
    ~H"""
    <.category_list items={@categories} />
    <.library_list categories={@categories} />
    """
  end

  def home_solid(assigns) do
    ~H"""
    <div id="app"></div>
    """
  end

  attr :items, :list, required: true

  def category_list(assigns) do
    ~H"""
    <.header>List of Categories</.header>
    <.list>
      <:item :for={item <- @items} title={item.name}>
        <%= item.description %>
      </:item>
    </.list>
    """
  end

  attr :items, :list, required: true

  def category_list_old(assigns) do
    ~H"""
    <ul>
    <%= for item <- @items do %>
      <.category item={item} />
    <% end %>
    </ul>
    """
  end

  attr :item, Category, required: true

  def category(assigns) do
    ~H"""
    <li>
      <%= @item.name %>: <%= @item.name %>
    </li>
    """
  end

  attr :categories, :list, default: []

  def library_list(assigns) do
    ~H"""
    <.header>List of Libraries</.header>

    <%= for category <- @categories do %>
      <div><%= category.name %></div>
        <.list>
          <:item :for={library <- category.libraries} title={library.name}>
            <%= library.description %> -- <%= library.stars %> -- <%= library.last_commit %>
          </:item>
        </.list>
    <% end %>
    """
  end
end
