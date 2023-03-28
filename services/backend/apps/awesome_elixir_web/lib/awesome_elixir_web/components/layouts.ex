defmodule AwesomeElixirWeb.Layouts do
  use AwesomeElixirWeb, :html

  embed_templates "layouts/*"

  @dev Mix.env() == :dev
  def dev?, do: @dev

  def preamble(assigns, true) do
    ~H"""
    <script type="module" src="http://localhost:5173/@vite/client">
    </script>
    <script type="module" src="http://localhost:5173/assets/js/app.ts">
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
