# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :payroll_manager,
  ecto_repos: [PayrollManager.Repo]

config :payroll_manager, PayrollManager.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]

config :payroll_manager, Oban,
  engine: Oban.Engines.Basic,
  repo: PayrollManager.Repo,
  queues: [mailer: 10],
  plugins: [
    # Automatically move orphan jobs back to available so they can run again.
    # rescue after a generous period of time.
    {Oban.Plugins.Lifeline, rescue_after: :timer.minutes(30)},
    # to prevent the oban_jobs table from growing indefinitely,
    # we prune jobs older than 7 days (completed, cancelled and discarded jobs)
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7}
  ]

# Configures the endpoint
config :payroll_manager, PayrollManagerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: PayrollManagerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PayrollManager.PubSub,
  live_view: [signing_salt: "DG14wznr"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
