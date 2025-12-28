defmodule Auth.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Auth.Repo,
      {GRPC.Server.Supervisor, endpoint: Auth.GRPC.Endpoint, port: grpc_port(), start_server: true}
    ]

    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp grpc_port do
    Application.get_env(:auth, :grpc)[:port] || 50051
  end
end
