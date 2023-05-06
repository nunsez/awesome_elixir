# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :awesome_elixir,
  ecto_repos: [AwesomeElixir.Repo]

# Configures the endpoint
config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: AwesomeElixirWeb.ErrorHTML, json: AwesomeElixirWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AwesomeElixir.PubSub,
  live_view: [signing_salt: "3V1+JTGH"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Config Oban - job processing library
config :awesome_elixir, Oban,
  repo: AwesomeElixir.Repo,
  engine: Oban.Engines.Lite,
  queues: [default: 10]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
