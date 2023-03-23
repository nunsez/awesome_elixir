defmodule AwesomeElixir.Repo do
  use Ecto.Repo,
    otp_app: :awesome_elixir,
    adapter: Ecto.Adapters.SQLite3
end
