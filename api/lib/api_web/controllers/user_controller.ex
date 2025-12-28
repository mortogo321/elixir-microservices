defmodule ApiWeb.UserController do
  use ApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Api.Accounts
  alias ApiWeb.Schemas.{User, UserRequest, Error}

  tags ["users"]

  operation :me,
    summary: "Get current user",
    description: "Returns the currently authenticated user",
    security: [%{"bearer" => []}],
    responses: [
      ok: {"Current user", "application/json", User}
    ]

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    json(conn, %{user: user})
  end

  operation :index,
    summary: "List users",
    description: "Returns a list of all users",
    security: [%{"bearer" => []}],
    responses: [
      ok: {"Users list", "application/json", %OpenApiSpex.Schema{type: :object, properties: %{users: %OpenApiSpex.Schema{type: :array, items: User}}}}
    ]

  def index(conn, _params) do
    users = Accounts.list_users()
    json(conn, %{users: users})
  end

  operation :show,
    summary: "Get user",
    description: "Returns a specific user by ID",
    parameters: [
      id: [in: :path, type: :integer, description: "User ID", required: true]
    ],
    security: [%{"bearer" => []}],
    responses: [
      ok: {"User", "application/json", User},
      not_found: {"Not found", "application/json", Error}
    ]

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    json(conn, %{user: user})
  end

  operation :update,
    summary: "Update user",
    description: "Update an existing user",
    parameters: [
      id: [in: :path, type: :integer, description: "User ID", required: true]
    ],
    security: [%{"bearer" => []}],
    request_body: {"User data", "application/json", UserRequest},
    responses: [
      ok: {"User updated", "application/json", User},
      unprocessable_entity: {"Validation error", "application/json", Error}
    ]

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        json(conn, %{user: user})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  operation :delete,
    summary: "Delete user",
    description: "Delete a user",
    parameters: [
      id: [in: :path, type: :integer, description: "User ID", required: true]
    ],
    security: [%{"bearer" => []}],
    responses: [
      no_content: "User deleted",
      unprocessable_entity: {"Error", "application/json", Error}
    ]

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    case Accounts.delete_user(user) do
      {:ok, _user} ->
        send_resp(conn, :no_content, "")

      {:error, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to delete user"})
    end
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
