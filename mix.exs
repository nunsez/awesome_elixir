defmodule AwesomeElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :awesome_elixir,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AwesomeElixir.Application, []},
      extra_applications: extra_applications(Mix.env())
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.2"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.16"},
      {:floki, "~> 0.34.2"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:finch, "~> 0.15.0"},
      {:oban, "~> 2.15"},
      {:tesla, "~> 1.7"},

      # dev and test
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},

      # test
      {:bypass, "~> 2.1", only: [:test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": [fn _ -> npm("install") end],
      "assets.build": [fn _ -> npm("run build") end],
      "assets.deploy": ["assets.build", "phx.digest"]
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix, :ex_unit]
    ]
  end

  defp extra_applications(:test) do
    [:logger]
  end

  defp extra_applications(_) do
    [:logger, :runtime_tools, :os_mon]
  end

  @spec npm(command :: String.t()) :: integer()
  defp npm(command) do
    node_env = System.get_env("NODE_ENV", Mix.env() |> to_string())

    Mix.shell().cmd("npm #{command}", env: [{"NODE_ENV", node_env}])
  end
end
