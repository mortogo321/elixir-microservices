defmodule Api.Messages do
  @moduledoc """
  The Messages context for real-time chat.
  """

  import Ecto.Query, warn: false
  alias Api.Repo
  alias Api.Messages.Message

  def list_messages(limit \\ 50) do
    Message
    |> order_by([m], desc: m.inserted_at)
    |> limit(^limit)
    |> preload(:user)
    |> Repo.all()
    |> Enum.reverse()
  end

  def get_message!(id), do: Repo.get!(Message, id) |> Repo.preload(:user)

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} ->
        message = Repo.preload(message, :user)
        broadcast_message(:new_message, message)
        {:ok, message}

      error ->
        error
    end
  end

  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, message} ->
        message = Repo.preload(message, :user)
        broadcast_message(:message_updated, message)
        {:ok, message}

      error ->
        error
    end
  end

  def delete_message(%Message{} = message) do
    case Repo.delete(message) do
      {:ok, message} ->
        broadcast_message(:message_deleted, message)
        {:ok, message}

      error ->
        error
    end
  end

  defp broadcast_message(event, message) do
    Phoenix.PubSub.broadcast(Api.PubSub, "messages", {event, message})
  end
end
