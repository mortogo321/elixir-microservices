defmodule ApiWeb.MessageController do
  use ApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Api.Messages
  alias ApiWeb.Schemas.{Message, MessageRequest, MessagesResponse, Error}

  tags ["messages"]

  operation :index,
    summary: "List messages",
    description: "Returns a list of all messages (public)",
    responses: [
      ok: {"Messages list", "application/json", MessagesResponse}
    ]

  def index(conn, _params) do
    messages = Messages.list_messages()
    json(conn, %{messages: Enum.map(messages, &message_to_json/1)})
  end

  operation :show,
    summary: "Get message",
    description: "Returns a specific message by ID",
    parameters: [
      id: [in: :path, type: :integer, description: "Message ID", required: true]
    ],
    security: [%{"bearer" => []}],
    responses: [
      ok: {"Message", "application/json", Message},
      not_found: {"Not found", "application/json", Error}
    ]

  def show(conn, %{"id" => id}) do
    message = Messages.get_message!(id)
    json(conn, %{message: message_to_json(message)})
  end

  operation :create,
    summary: "Create message",
    description: "Create a new message (requires authentication)",
    security: [%{"bearer" => []}],
    request_body: {"Message content", "application/json", MessageRequest},
    responses: [
      created: {"Message created", "application/json", Message},
      unprocessable_entity: {"Validation error", "application/json", Error}
    ]

  def create(conn, %{"message" => message_params}) do
    user = Guardian.Plug.current_resource(conn)
    params = Map.put(message_params, "user_id", user.id)

    case Messages.create_message(params) do
      {:ok, message} ->
        conn
        |> put_status(:created)
        |> json(%{message: message_to_json(message)})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  operation :update,
    summary: "Update message",
    description: "Update an existing message (owner only)",
    parameters: [
      id: [in: :path, type: :integer, description: "Message ID", required: true]
    ],
    security: [%{"bearer" => []}],
    request_body: {"Message content", "application/json", MessageRequest},
    responses: [
      ok: {"Message updated", "application/json", Message},
      forbidden: {"Forbidden", "application/json", Error},
      unprocessable_entity: {"Validation error", "application/json", Error}
    ]

  def update(conn, %{"id" => id, "message" => message_params}) do
    message = Messages.get_message!(id)
    user = Guardian.Plug.current_resource(conn)

    if message.user_id == user.id do
      case Messages.update_message(message, message_params) do
        {:ok, message} ->
          json(conn, %{message: message_to_json(message)})

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: format_changeset_errors(changeset)})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "You can only update your own messages"})
    end
  end

  operation :delete,
    summary: "Delete message",
    description: "Delete a message (owner only)",
    parameters: [
      id: [in: :path, type: :integer, description: "Message ID", required: true]
    ],
    security: [%{"bearer" => []}],
    responses: [
      no_content: "Message deleted",
      forbidden: {"Forbidden", "application/json", Error}
    ]

  def delete(conn, %{"id" => id}) do
    message = Messages.get_message!(id)
    user = Guardian.Plug.current_resource(conn)

    if message.user_id == user.id do
      case Messages.delete_message(message) do
        {:ok, _message} ->
          send_resp(conn, :no_content, "")

        {:error, _changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Failed to delete message"})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "You can only delete your own messages"})
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

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
