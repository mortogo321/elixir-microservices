defmodule Alert.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Alert.Consumer
    ]

    opts = [strategy: :one_for_one, name: Alert.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
