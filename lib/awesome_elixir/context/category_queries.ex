defmodule AwesomeElixir.Context.CategoryQueries do
  @moduledoc false

  import Ecto.Query

  alias AwesomeElixir.Context.Category

  @spec stale_categories(
          queryable :: Ecto.Query.t() | Category,
          existing_category_names :: [String.t()]
        ) :: Ecto.Query.t()
  def stale_categories(queryable, existing_category_names)
      when is_list(existing_category_names) do
    queryable
    |> where([c], c.name not in ^existing_category_names)
  end
end
