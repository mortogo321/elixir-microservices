defmodule ApiWeb.RoomChannel do
  @moduledoc false
  use ApiWeb, :channel

  @impl true
  def join("room:lobby", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def join("room:" <> _room_id, _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    push(socket, "presence_state", %{})
    {:noreply, socket}
  end

  @impl true
  def handle_in("shout", payload, socket) do
    user = socket.assigns.current_user

    broadcast(socket, "shout", %{
      user: %{id: user.id, name: user.name},
      message: payload["message"],
      timestamp: DateTime.utc_now()
    })

    {:noreply, socket}
  end

  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{pong: DateTime.utc_now()}}, socket}
  end
end
