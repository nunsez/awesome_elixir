defmodule AwesomeElixirWeb.Layouts do
  @moduledoc false

  use AwesomeElixirWeb, :html

  embed_templates "layouts/*"

  @dev Mix.env() == :dev
  def dev?, do: @dev

  defp vite_origin, do: "https://localhost:5173"

  def preamble(assigns, true) do
    ~H"""
    <script type="module" src={vite_origin() <> "/@vite/client"}>
    </script>
    <script type="module" src={vite_origin() <> "/assets/js/app.ts"}>
    </script>
    """
  end

  def preamble(assigns, false) do
    ~H"""
    <link phx-track-static rel="stylesheet" href={~p"/assets/app.css"} />
    <script defer phx-track-static type="text/javascript" src={~p"/assets/app.js"}>
    </script>
    """
  end
end
