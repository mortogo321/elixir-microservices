defmodule Auth.Events.Publisher do
  @moduledoc """
  RabbitMQ publisher for auth events.
  """

  use GenServer
  require Logger

  @reconnect_interval 5_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Publish a user signup event.
  """
  def publish_user_signup(user) do
    event = %{
      event: "user.signup",
      data: %{
        id: user.id,
        email: user.email,
        name: user.name,
        created_at: user.inserted_at
      },
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    GenServer.cast(__MODULE__, {:publish, "user.signup", event})
  end

  @impl true
  def init(_opts) do
    send(self(), :connect)
    {:ok, %{channel: nil, connection: nil}}
  end

  @impl true
  def handle_info(:connect, state) do
    case connect() do
      {:ok, channel, connection} ->
        Logger.info("Publisher connected to RabbitMQ")
        Process.monitor(connection.pid)
        {:noreply, %{state | channel: channel, connection: connection}}

      {:error, reason} ->
        Logger.error("Publisher failed to connect to RabbitMQ: #{inspect(reason)}")
        Process.send_after(self(), :connect, @reconnect_interval)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:DOWN, _, :process, _pid, reason}, state) do
    Logger.error("RabbitMQ connection lost: #{inspect(reason)}")
    Process.send_after(self(), :connect, @reconnect_interval)
    {:noreply, %{state | channel: nil, connection: nil}}
  end

  @impl true
  def handle_cast({:publish, routing_key, event}, %{channel: nil} = state) do
    Logger.warn("Cannot publish event, not connected to RabbitMQ")
    {:noreply, state}
  end

  @impl true
  def handle_cast({:publish, routing_key, event}, state) do
    exchange = Application.get_env(:auth, :rabbitmq_exchange, "events")
    payload = Jason.encode!(event)

    case AMQP.Basic.publish(state.channel, exchange, routing_key, payload,
           persistent: true,
           content_type: "application/json"
         ) do
      :ok ->
        Logger.info("Published event: #{routing_key}")

      {:error, reason} ->
        Logger.error("Failed to publish event: #{inspect(reason)}")
    end

    {:noreply, state}
  end

  defp connect do
    host = Application.get_env(:auth, :rabbitmq_host, "localhost")
    user = Application.get_env(:auth, :rabbitmq_user, "guest")
    pass = Application.get_env(:auth, :rabbitmq_pass, "guest")
    exchange = Application.get_env(:auth, :rabbitmq_exchange, "events")

    with {:ok, connection} <- AMQP.Connection.open(
           host: host,
           username: user,
           password: pass
         ),
         {:ok, channel} <- AMQP.Channel.open(connection) do
      # Declare exchange
      :ok = AMQP.Exchange.declare(channel, exchange, :topic, durable: true)

      {:ok, channel, connection}
    end
  end
end
