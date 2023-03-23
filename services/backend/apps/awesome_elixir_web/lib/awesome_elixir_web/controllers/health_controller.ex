defmodule AwesomeElixirWeb.HealthController do
  use AwesomeElixirWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{status: "ok"})
  end
end
