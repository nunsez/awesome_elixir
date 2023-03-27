defmodule AwesomeElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      AwesomeElixir.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: AwesomeElixir.PubSub},
      AwesomeElixir.GithubClient
      # Start a worker by calling: AwesomeElixir.Worker.start_link(arg)
      # {AwesomeElixir.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: AwesomeElixir.Supervisor)
  end
end
