defmodule ApiWeb.MessageChannel do
  @moduledoc false
  use ApiWeb, :channel

  alias Api.Messages

  @impl true
  def join("messages:lobby", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    Phoenix.PubSub.subscribe(Api.PubSub, "messages")
    messages = Messages.list_messages()

    push(socket, "messages_history", %{
      messages: Enum.map(messages, &message_to_json/1)
    })

    {:noreply, socket}
  end

  def handle_info({:new_message, message}, socket) do
    push(socket, "new_message", %{message: message_to_json(message)})
    {:noreply, socket}
  end

  def handle_info({:message_updated, message}, socket) do
    push(socket, "message_updated", %{message: message_to_json(message)})
    {:noreply, socket}
  end

  def handle_info({:message_deleted, message}, socket) do
    push(socket, "message_deleted", %{message_id: message.id})
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_message", %{"content" => content}, socket) do
    user = socket.assigns.current_user

    case Messages.create_message(%{"content" => content, "user_id" => user.id}) do
      {:ok, message} ->
        {:reply, {:ok, %{message: message_to_json(message)}}, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: format_errors(changeset)}}, socket}
    end
  end

  defp message_to_json(message) do
    %{
      id: message.id,
      content: message.content,
      user: %{
        id: message.user.id,
        name: message.user.name,
        email: message.user.email
      },
      inserted_at: message.inserted_at,
      updated_at: message.updated_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
