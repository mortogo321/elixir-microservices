defmodule ApiWeb.AuthController do
  use ApiWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias ApiWeb.Schemas.{AuthResponse, UserRequest, LoginRequest, RefreshRequest, Error}

  defp auth_client do
    Application.get_env(:api, :auth_client, Api.Grpc.AuthClient)
  end

  tags(["auth"])

  operation(:register,
    summary: "Register a new user",
    description: "Create a new user account via auth gRPC service",
    request_body: {"User registration", "application/json", UserRequest},
    responses: [
      created: {"Auth response", "application/json", AuthResponse},
      unprocessable_entity: {"Validation error", "application/json", Error}
    ]
  )

  def register(conn, %{"user" => user_params}) do
    email = user_params["email"]
    password = user_params["password"]
    name = user_params["name"]

    case auth_client().register(email, password, name) do
      {:ok, %{success: true} = response} ->
        conn
        |> put_status(:created)
        |> json(%{
          user: format_user(response.user),
          access_token: response.access_token,
          refresh_token: response.refresh_token,
          expires_in: response.expires_in
        })

      {:ok, %{success: false, message: message}} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: message})

      {:error, message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: message})
    end
  end

  operation(:login,
    summary: "Login",
    description: "Authenticate user via auth gRPC service",
    request_body: {"Login credentials", "application/json", LoginRequest},
    responses: [
      ok: {"Auth response", "application/json", AuthResponse},
      unauthorized: {"Invalid credentials", "application/json", Error}
    ]
  )

  def login(conn, %{"email" => email, "password" => password}) do
    case auth_client().login(email, password) do
      {:ok, %{success: true} = response} ->
        json(conn, %{
          user: format_user(response.user),
          access_token: response.access_token,
          refresh_token: response.refresh_token,
          expires_in: response.expires_in
        })

      {:ok, %{success: false, message: message}} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: message})

      {:error, _message} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  operation(:refresh,
    summary: "Refresh token",
    description: "Refresh access token using refresh token via auth gRPC service",
    request_body: {"Refresh token", "application/json", RefreshRequest},
    responses: [
      ok: {"Auth response", "application/json", AuthResponse},
      unauthorized: {"Invalid refresh token", "application/json", Error}
    ]
  )

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case auth_client().refresh_token(refresh_token) do
      {:ok, %{success: true} = response} ->
        json(conn, %{
          user: format_user(response.user),
          access_token: response.access_token,
          refresh_token: response.refresh_token,
          expires_in: response.expires_in
        })

      {:ok, %{success: false, message: message}} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: message})

      {:error, _message} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid refresh token"})
    end
  end

  operation(:validate,
    summary: "Validate token",
    description: "Validate an access token via auth gRPC service",
    parameters: [
      authorization: [
        in: :header,
        type: :string,
        description: "Bearer token",
        required: true
      ]
    ],
    responses: [
      ok: {"Validation response", "application/json", AuthResponse},
      unauthorized: {"Invalid token", "application/json", Error}
    ]
  )

  def validate(conn, _params) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %{valid: true, user: user}} <- auth_client().validate_token(token) do
      json(conn, %{
        valid: true,
        user: format_user(user)
      })
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired token"})
    end
  end

  defp format_user(nil), do: nil

  defp format_user(user) do
    %{
      id: user.id,
      email: user.email,
      name: user.name,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
