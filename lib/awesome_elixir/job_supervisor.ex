defmodule AwesomeElixir.JobSupervisor do
  @moduledoc false

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    :awesome_elixir
    |> Application.fetch_env!(Oban)
    |> Oban.start_link()
  end
end
