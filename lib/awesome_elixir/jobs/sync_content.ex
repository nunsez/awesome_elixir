defmodule AwesomeElixir.Jobs.SyncContent do
  @moduledoc false

  use Oban.Worker,
    queue: :synchronization,
    max_attempts: 2,
    unique: [period: 12 * 60 * 60]

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    AwesomeElixir.Synchronizer.call()

    :ok
  end
end
