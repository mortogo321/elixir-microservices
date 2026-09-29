defmodule Auth.GRPC.Server do
  @moduledoc """
  gRPC server implementation for AuthService.

  Uses grpc_server 1.x stream-based API: every RPC (even unary) is a
  `GRPC.Stream` pipeline terminated with `run/1`.
  """

  use GRPC.Server, service: Auth.Proto.AuthService.Service

  alias Auth.Accounts
  alias Auth.Events.Publisher
  alias Auth.Proto
  alias Auth.Token

  def register(request, materializer) do
    request
    |> GRPC.Stream.unary(materializer: materializer)
    |> GRPC.Stream.map(&do_register/1)
    |> GRPC.Stream.run()
  end

  def login(request, materializer) do
    request
    |> GRPC.Stream.unary(materializer: materializer)
    |> GRPC.Stream.map(&do_login/1)
    |> GRPC.Stream.run()
  end

  def validate_token(request, materializer) do
    request
    |> GRPC.Stream.unary(materializer: materializer)
    |> GRPC.Stream.map(&do_validate_token/1)
    |> GRPC.Stream.run()
  end

  def refresh_token(request, materializer) do
    request
    |> GRPC.Stream.unary(materializer: materializer)
    |> GRPC.Stream.map(&do_refresh_token/1)
    |> GRPC.Stream.run()
  end

  def get_user(request, materializer) do
    request
    |> GRPC.Stream.unary(materializer: materializer)
    |> GRPC.Stream.map(&do_get_user/1)
    |> GRPC.Stream.run()
  end

  def get_user_by_email(request, materializer) do
    request
    |> GRPC.Stream.unary(materializer: materializer)
    |> GRPC.Stream.map(&do_get_user_by_email/1)
    |> GRPC.Stream.run()
  end

  # Handlers (pure request -> response; executed inside the stream)

  defp do_register(request) do
    attrs = %{
      email: request.email,
      password: request.password,
      name: request.name
    }

    case Accounts.create_user(attrs) do
      {:ok, user} ->
        {access_token, refresh_token, expires_in} = Token.generate_tokens(user)

        # Publish signup event to RabbitMQ
        Publisher.publish_user_signup(user)

        %Proto.AuthResponse{
          success: true,
          message: "User registered successfully",
          user: user_to_proto(user),
          access_token: access_token,
          refresh_token: refresh_token,
          expires_in: expires_in
        }

      {:error, changeset} ->
        %Proto.AuthResponse{
          success: false,
          message: format_errors(changeset)
        }
    end
  end

  defp do_login(request) do
    case Accounts.authenticate_user(request.email, request.password) do
      {:ok, user} ->
        {access_token, refresh_token, expires_in} = Token.generate_tokens(user)

        %Proto.AuthResponse{
          success: true,
          message: "Login successful",
          user: user_to_proto(user),
          access_token: access_token,
          refresh_token: refresh_token,
          expires_in: expires_in
        }

      {:error, :invalid_credentials} ->
        %Proto.AuthResponse{
          success: false,
          message: "Invalid email or password"
        }
    end
  end

  defp do_validate_token(request) do
    case Token.validate_token(request.token) do
      {:ok, claims} ->
        case Accounts.get_user(claims["sub"]) do
          nil ->
            %Proto.ValidateTokenResponse{
              valid: false,
              message: "User not found"
            }

          user ->
            %Proto.ValidateTokenResponse{
              valid: true,
              message: "Token is valid",
              user: user_to_proto(user)
            }
        end

      {:error, :token_expired} ->
        %Proto.ValidateTokenResponse{
          valid: false,
          message: "Token has expired"
        }

      {:error, _} ->
        %Proto.ValidateTokenResponse{
          valid: false,
          message: "Invalid token"
        }
    end
  end

  defp do_refresh_token(request) do
    case Token.validate_refresh_token(request.refresh_token) do
      {:ok, claims} ->
        case Accounts.get_user(claims["sub"]) do
          nil ->
            %Proto.AuthResponse{
              success: false,
              message: "User not found"
            }

          user ->
            {access_token, refresh_token, expires_in} = Token.generate_tokens(user)

            %Proto.AuthResponse{
              success: true,
              message: "Token refreshed successfully",
              user: user_to_proto(user),
              access_token: access_token,
              refresh_token: refresh_token,
              expires_in: expires_in
            }
        end

      {:error, :token_expired} ->
        %Proto.AuthResponse{
          success: false,
          message: "Refresh token has expired"
        }

      {:error, _} ->
        %Proto.AuthResponse{
          success: false,
          message: "Invalid refresh token"
        }
    end
  end

  defp do_get_user(request) do
    case Accounts.get_user(request.user_id) do
      nil ->
        %Proto.UserResponse{
          success: false,
          message: "User not found"
        }

      user ->
        %Proto.UserResponse{
          success: true,
          message: "User found",
          user: user_to_proto(user)
        }
    end
  end

  defp do_get_user_by_email(request) do
    case Accounts.get_user_by_email(request.email) do
      nil ->
        %Proto.UserResponse{
          success: false,
          message: "User not found"
        }

      user ->
        %Proto.UserResponse{
          success: true,
          message: "User found",
          user: user_to_proto(user)
        }
    end
  end

  # Helpers

  defp user_to_proto(user) do
    %Proto.User{
      id: user.id,
      email: user.email,
      name: user.name || "",
      created_at: DateTime.to_iso8601(user.inserted_at),
      updated_at: DateTime.to_iso8601(user.updated_at)
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map_join("; ", fn {k, v} -> "#{k}: #{Enum.join(v, ", ")}" end)
  end
end
