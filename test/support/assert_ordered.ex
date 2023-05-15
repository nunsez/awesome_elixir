defmodule AwesomeElixir.AssertOrdered do
  @moduledoc false

  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end)
  end

  def push(pid, value) do
    Agent.update(pid, fn state -> [value | state] end)
  end

  def result(pid) do
    Agent.get(pid, fn state -> Enum.reverse(state) end)
  end
end
