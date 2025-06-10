defmodule QualityViewer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      QualityViewerWeb.Telemetry,
      QualityViewer.Repo,
      {DNSCluster, query: Application.get_env(:quality_viewer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: QualityViewer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: QualityViewer.Finch},
      # Start a worker by calling: QualityViewer.Worker.start_link(arg)
      # {QualityViewer.Worker, arg},
      # Start to serve requests, typically the last entry
      QualityViewerWeb.Endpoint,
      QualityViewer.Transcode.Queue
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QualityViewer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QualityViewerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
