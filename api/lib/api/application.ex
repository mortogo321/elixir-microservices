defmodule Api.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # NOTE: grpc 1.x starts its client supervision tree via its own OTP
    # application (GRPC.Client.Application) — no manual supervisor child.
    children = [
      Api.Repo,
      {Phoenix.PubSub, name: Api.PubSub},
      ApiWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Api.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
