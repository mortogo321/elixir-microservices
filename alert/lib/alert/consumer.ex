defmodule Alert.Consumer do
  @moduledoc """
  RabbitMQ consumer for user signup events.
  """

  use GenServer
  require Logger

  @reconnect_interval 5_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
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
        Logger.info("Connected to RabbitMQ")
        Process.monitor(connection.pid)
        {:noreply, %{state | channel: channel, connection: connection}}

      {:error, reason} ->
        Logger.error("Failed to connect to RabbitMQ: #{inspect(reason)}")
        Process.send_after(self(), :connect, @reconnect_interval)
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:basic_deliver, payload, meta}, state) do
    Logger.info("Received message: #{payload}")

    case Jason.decode(payload) do
      {:ok, event} ->
        handle_event(event)
        AMQP.Basic.ack(state.channel, meta.delivery_tag)

      {:error, reason} ->
        Logger.error("Failed to decode message: #{inspect(reason)}")
        AMQP.Basic.reject(state.channel, meta.delivery_tag, requeue: false)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_consume_ok, _meta}, state) do
    Logger.info("Consumer registered")
    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_cancel, _meta}, state) do
    Logger.warn("Consumer cancelled")
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:DOWN, _, :process, _pid, reason}, state) do
    Logger.error("RabbitMQ connection lost: #{inspect(reason)}")
    Process.send_after(self(), :connect, @reconnect_interval)
    {:noreply, %{state | channel: nil, connection: nil}}
  end

  defp connect do
    host = Application.get_env(:alert, :rabbitmq_host, "localhost")
    user = Application.get_env(:alert, :rabbitmq_user, "guest")
    pass = Application.get_env(:alert, :rabbitmq_pass, "guest")
    exchange = Application.get_env(:alert, :rabbitmq_exchange, "events")
    queue = Application.get_env(:alert, :rabbitmq_queue, "alert.user_signup")

    with {:ok, connection} <- AMQP.Connection.open(
           host: host,
           username: user,
           password: pass
         ),
         {:ok, channel} <- AMQP.Channel.open(connection) do
      # Declare exchange
      :ok = AMQP.Exchange.declare(channel, exchange, :topic, durable: true)

      # Declare queue
      {:ok, _} = AMQP.Queue.declare(channel, queue, durable: true)

      # Bind queue to exchange with routing key
      :ok = AMQP.Queue.bind(channel, queue, exchange, routing_key: "user.signup")

      # Start consuming
      {:ok, _consumer_tag} = AMQP.Basic.consume(channel, queue)

      {:ok, channel, connection}
    end
  end

  defp handle_event(%{"event" => "user.signup", "data" => data}) do
    Logger.info("Processing user signup event for: #{data["email"]}")

    # Send welcome email (logged in dev mode)
    Alert.Mailer.send_welcome_email(data)
  end

  defp handle_event(event) do
    Logger.warn("Unknown event: #{inspect(event)}")
  end
end
