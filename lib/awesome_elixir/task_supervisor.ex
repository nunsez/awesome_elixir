defmodule AwesomeElixir.TaskSupervisor do
  @moduledoc false

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    Task.Supervisor.start_link(name: __MODULE__)
  end
end
