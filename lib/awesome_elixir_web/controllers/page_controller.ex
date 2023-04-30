defmodule AwesomeElixirWeb.PageController do
  use AwesomeElixirWeb, :controller

  alias AwesomeElixir.Context

  @spec home(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def home(conn, params) do
    params
    |> min_stars()
    |> Context.categories()
    |> then(&render(conn, :home, categories: &1))
  end

  @spec home_solid(conn :: Plug.Conn.t(), params :: map()) :: Plug.Conn.t()
  def home_solid(conn, _params) do
    render(conn, :home_solid)
  end

  @spec min_stars(params :: map()) :: integer()
  defp min_stars(params) do
    with {:ok, value} <- Map.fetch(params, "min_stars"),
         {min_stars, _} <- Integer.parse(value, 10) do
      min_stars
    else
      _ -> 0
    end
  end
end
