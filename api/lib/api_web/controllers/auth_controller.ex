defmodule ApiWeb.AuthController do
  use ApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Api.Accounts
  alias Api.Guardian
  alias ApiWeb.Schemas.{AuthResponse, UserRequest, LoginRequest, Error}

  tags ["auth"]

  operation :register,
    summary: "Register a new user",
    description: "Create a new user account and return auth token",
    request_body: {"User registration", "application/json", UserRequest},
    responses: [
      created: {"Auth response", "application/json", AuthResponse},
      unprocessable_entity: {"Validation error", "application/json", Error}
    ]

  def register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        conn
        |> put_status(:created)
        |> json(%{
          user: user,
          token: token
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  operation :login,
    summary: "Login",
    description: "Authenticate user and return auth token",
    request_body: {"Login credentials", "application/json", LoginRequest},
    responses: [
      ok: {"Auth response", "application/json", AuthResponse},
      unauthorized: {"Invalid credentials", "application/json", Error}
    ]

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        json(conn, %{
          user: user,
          token: token
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
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
