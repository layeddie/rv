defmodule RvAppUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RvAppUiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RvAppUi.PubSub},
      # Start the Endpoint (http/https)
      RvAppUiWeb.Endpoint
      # Start a worker by calling: RvAppUi.Worker.start_link(arg)
      # {RvAppUi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RvAppUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RvAppUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
