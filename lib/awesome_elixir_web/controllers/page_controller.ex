defmodule AwesomeElixirWeb.PageController do
  alias AwesomeElixir.Category
  alias AwesomeElixir.Library
  alias AwesomeElixir.Repo
  use AwesomeElixirWeb, :controller

  def home(conn, _params) do
    categories = Repo.all(Category) |> dbg()
    render(conn, :home, categories: categories)
  end

  def home_solid(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home_solid)
  end
end
