defmodule Auth.GRPC.Server do
  @moduledoc """
  gRPC server implementation for AuthService.
  """

  use GRPC.Server, service: Auth.Proto.AuthService.Service

  alias Auth.Accounts
  alias Auth.Token
  alias Auth.Proto

  @spec register(Proto.RegisterRequest.t(), GRPC.Server.Stream.t()) :: Proto.AuthResponse.t()
  def register(request, _stream) do
    attrs = %{
      email: request.email,
      password: request.password,
      name: request.name
    }

    case Accounts.create_user(attrs) do
      {:ok, user} ->
        {access_token, refresh_token, expires_in} = Token.generate_tokens(user)

        Proto.AuthResponse.new(
          success: true,
          message: "User registered successfully",
          user: user_to_proto(user),
          access_token: access_token,
          refresh_token: refresh_token,
          expires_in: expires_in
        )

      {:error, changeset} ->
        Proto.AuthResponse.new(
          success: false,
          message: format_errors(changeset)
        )
    end
  end

  @spec login(Proto.LoginRequest.t(), GRPC.Server.Stream.t()) :: Proto.AuthResponse.t()
  def login(request, _stream) do
    case Accounts.authenticate_user(request.email, request.password) do
      {:ok, user} ->
        {access_token, refresh_token, expires_in} = Token.generate_tokens(user)

        Proto.AuthResponse.new(
          success: true,
          message: "Login successful",
          user: user_to_proto(user),
          access_token: access_token,
          refresh_token: refresh_token,
          expires_in: expires_in
        )

      {:error, :invalid_credentials} ->
        Proto.AuthResponse.new(
          success: false,
          message: "Invalid email or password"
        )
    end
  end

  @spec validate_token(Proto.ValidateTokenRequest.t(), GRPC.Server.Stream.t()) ::
          Proto.ValidateTokenResponse.t()
  def validate_token(request, _stream) do
    case Token.validate_token(request.token) do
      {:ok, claims} ->
        case Accounts.get_user(claims["sub"]) do
          nil ->
            Proto.ValidateTokenResponse.new(
              valid: false,
              message: "User not found"
            )

          user ->
            Proto.ValidateTokenResponse.new(
              valid: true,
              message: "Token is valid",
              user: user_to_proto(user)
            )
        end

      {:error, :token_expired} ->
        Proto.ValidateTokenResponse.new(
          valid: false,
          message: "Token has expired"
        )

      {:error, _} ->
        Proto.ValidateTokenResponse.new(
          valid: false,
          message: "Invalid token"
        )
    end
  end

  @spec refresh_token(Proto.RefreshTokenRequest.t(), GRPC.Server.Stream.t()) ::
          Proto.AuthResponse.t()
  def refresh_token(request, _stream) do
    case Token.validate_refresh_token(request.refresh_token) do
      {:ok, claims} ->
        case Accounts.get_user(claims["sub"]) do
          nil ->
            Proto.AuthResponse.new(
              success: false,
              message: "User not found"
            )

          user ->
            {access_token, refresh_token, expires_in} = Token.generate_tokens(user)

            Proto.AuthResponse.new(
              success: true,
              message: "Token refreshed successfully",
              user: user_to_proto(user),
              access_token: access_token,
              refresh_token: refresh_token,
              expires_in: expires_in
            )
        end

      {:error, :token_expired} ->
        Proto.AuthResponse.new(
          success: false,
          message: "Refresh token has expired"
        )

      {:error, _} ->
        Proto.AuthResponse.new(
          success: false,
          message: "Invalid refresh token"
        )
    end
  end

  @spec get_user(Proto.GetUserRequest.t(), GRPC.Server.Stream.t()) :: Proto.UserResponse.t()
  def get_user(request, _stream) do
    case Accounts.get_user(request.user_id) do
      nil ->
        Proto.UserResponse.new(
          success: false,
          message: "User not found"
        )

      user ->
        Proto.UserResponse.new(
          success: true,
          message: "User found",
          user: user_to_proto(user)
        )
    end
  end

  @spec get_user_by_email(Proto.GetUserByEmailRequest.t(), GRPC.Server.Stream.t()) ::
          Proto.UserResponse.t()
  def get_user_by_email(request, _stream) do
    case Accounts.get_user_by_email(request.email) do
      nil ->
        Proto.UserResponse.new(
          success: false,
          message: "User not found"
        )

      user ->
        Proto.UserResponse.new(
          success: true,
          message: "User found",
          user: user_to_proto(user)
        )
    end
  end

  # Helpers

  defp user_to_proto(user) do
    Proto.User.new(
      id: user.id,
      email: user.email,
      name: user.name || "",
      created_at: DateTime.to_iso8601(user.inserted_at),
      updated_at: DateTime.to_iso8601(user.updated_at)
    )
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {k, v} -> "#{k}: #{Enum.join(v, ", ")}" end)
    |> Enum.join("; ")
  end
end
