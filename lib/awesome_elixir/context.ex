defmodule AwesomeElixir.Context do
  @moduledoc false

  import Ecto.Query

  alias AwesomeElixir.Category
  alias AwesomeElixir.Library
  alias AwesomeElixir.Repo

  def categories(min_stars) do
    min_stars
    |> all_categories()
    |> Repo.all()
    |> Enum.reject(&no_libraries?/1)
  end

  def all_categories(min_stars) do
    from(
      Category,
      preload: [libraries: ^sorted_libraries(min_stars)]
    )
  end

  def sorted_libraries(min_stars) do
    from(
      l in Library,
      where: l.stars >= ^min_stars,
      order_by: [desc: l.last_commit > ago(6, "month")],
      order_by: [desc: l.stars]
    )
  end

  def no_libraries?(category) do
    Enum.empty?(category.libraries)
  end
end
