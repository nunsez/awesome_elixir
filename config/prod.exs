import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

# Config Oban - job processing library
config :awesome_elixir, Oban,
  queues: [
    synchronization: [limit: 1, paused: false]
  ],
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       # At 00:00
       {"0 0 * * *", AwesomeElixir.Jobs.SyncCategories}
     ]}
  ]
