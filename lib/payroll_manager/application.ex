defmodule PayrollManager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PayrollManagerWeb.Telemetry,
      # Start the Ecto repository
      PayrollManager.Repo,
      # Start Oban
      {Oban, Application.fetch_env!(:payroll_manager, Oban)},
      # Start the PubSub system
      {Phoenix.PubSub, name: PayrollManager.PubSub},
      # Start Finch
      {Finch, name: PayrollManager.Finch},
      # Start the Endpoint (http/https)
      PayrollManagerWeb.Endpoint
      # Start a worker by calling: PayrollManager.Worker.start_link(arg)
      # {PayrollManager.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PayrollManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PayrollManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
