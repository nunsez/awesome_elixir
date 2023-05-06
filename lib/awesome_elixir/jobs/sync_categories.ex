defmodule AwesomeElixir.Jobs.SyncCategories do
  @moduledoc false

  use Oban.Worker,
    max_attempts: 2,
    unique: [period: 12 * 60 * 60]

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    AwesomeElixir.Processor.sync_categories()

    :ok
  end
end
