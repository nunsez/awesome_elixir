defmodule AwesomeElixirWeb.Layouts do
  @moduledoc false

  use AwesomeElixirWeb, :html

  embed_templates "layouts/*"

  def preamble_prod(assigns) do
    ~H"""
    <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
    <script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}>
    </script>
    """
  end

  def preamble_dev(assigns) do
    ~H"""
    <script type="module" src={vite_origin() <> "/@vite/client"}>
    </script>
    <script type="module" src={vite_origin() <> "/assets/js/app.ts"}>
    </script>
    """
  end

  defp vite_origin, do: "http://localhost:5173"

  @dev? Mix.env() == :dev

  def dev?, do: @dev?
end
