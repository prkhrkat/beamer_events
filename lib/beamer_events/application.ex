defmodule BeamerEvents.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BeamerEventsWeb.Telemetry,
      # Start the Ecto repository
      BeamerEvents.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: BeamerEvents.PubSub},
      # Start Finch
      {Finch, name: BeamerEvents.Finch},
      # Start the Endpoint (http/https)
      BeamerEventsWeb.Endpoint
      # Start a worker by calling: BeamerEvents.Worker.start_link(arg)
      # {BeamerEvents.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BeamerEvents.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BeamerEventsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
