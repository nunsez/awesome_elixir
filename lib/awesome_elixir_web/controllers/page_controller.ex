defmodule AwesomeElixirWeb.PageController do
  alias AwesomeElixir.Category
  alias AwesomeElixir.Library
  alias AwesomeElixir.Repo
  use AwesomeElixirWeb, :controller

  import Ecto.Query

  def home(conn, _params) do
    sorted_libraries = from(
      l in Library,
      order_by: [desc: l.last_commit > ago(6, "month")],
      order_by: [desc: l.stars]
    )

    query = from(Category, preload: [libraries: ^sorted_libraries])
    categories = Repo.all(query)

    render(conn, :home, categories: categories)
  end

  def home_solid(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home_solid)
  end
end
