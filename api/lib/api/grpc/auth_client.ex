defmodule Api.Grpc.AuthClient do
  @moduledoc """
  gRPC client for the Auth service.
  Provides functions to communicate with the auth gRPC server.
  """

  @behaviour Api.Grpc.AuthClientBehaviour

  require Logger

  @doc """
  Get the gRPC channel to the auth service.
  """
  def get_channel do
    host = System.get_env("AUTH_GRPC_HOST", "localhost")
    port = System.get_env("AUTH_GRPC_PORT", "50051")

    case GRPC.Stub.connect("#{host}:#{port}") do
      {:ok, channel} ->
        {:ok, channel}

      {:error, reason} ->
        Logger.error("Failed to connect to auth service: #{inspect(reason)}")
        {:error, :connection_failed}
    end
  end

  defp safe_disconnect(channel) do
    # Spawn disconnect in a separate process to avoid blocking
    spawn(fn ->
      try do
        GRPC.Stub.disconnect(channel)
      rescue
        _ -> :ok
      catch
        :exit, _ -> :ok
      end
    end)

    :ok
  end

  @doc """
  Register a new user via gRPC.
  """
  def register(email, password, name) do
    with {:ok, channel} <- get_channel() do
      request = %Auth.RegisterRequest{
        email: email,
        password: password,
        name: name || ""
      }

      result =
        case Auth.AuthService.Stub.register(channel, request) do
          {:ok, response} ->
            {:ok, response}

          {:error, %GRPC.RPCError{} = error} ->
            Logger.error("gRPC register error: #{inspect(error)}")
            {:error, error.message}
        end

      safe_disconnect(channel)
      result
    end
  end

  @doc """
  Login a user via gRPC.
  """
  def login(email, password) do
    with {:ok, channel} <- get_channel() do
      request = %Auth.LoginRequest{
        email: email,
        password: password
      }

      result =
        case Auth.AuthService.Stub.login(channel, request) do
          {:ok, response} ->
            {:ok, response}

          {:error, %GRPC.RPCError{} = error} ->
            Logger.error("gRPC login error: #{inspect(error)}")
            {:error, error.message}
        end

      safe_disconnect(channel)
      result
    end
  end

  @doc """
  Validate a token via gRPC.
  """
  def validate_token(token) do
    with {:ok, channel} <- get_channel() do
      request = %Auth.ValidateTokenRequest{token: token}

      result =
        case Auth.AuthService.Stub.validate_token(channel, request) do
          {:ok, response} ->
            {:ok, response}

          {:error, %GRPC.RPCError{} = error} ->
            Logger.error("gRPC validate_token error: #{inspect(error)}")
            {:error, error.message}
        end

      safe_disconnect(channel)
      result
    end
  end

  @doc """
  Refresh a token via gRPC.
  """
  def refresh_token(refresh_token) do
    with {:ok, channel} <- get_channel() do
      request = %Auth.RefreshTokenRequest{refresh_token: refresh_token}

      result =
        case Auth.AuthService.Stub.refresh_token(channel, request) do
          {:ok, response} ->
            {:ok, response}

          {:error, %GRPC.RPCError{} = error} ->
            Logger.error("gRPC refresh_token error: #{inspect(error)}")
            {:error, error.message}
        end

      safe_disconnect(channel)
      result
    end
  end

  @doc """
  Get user by ID via gRPC.
  """
  def get_user(user_id) do
    with {:ok, channel} <- get_channel() do
      request = %Auth.GetUserRequest{user_id: user_id}

      result =
        case Auth.AuthService.Stub.get_user(channel, request) do
          {:ok, response} ->
            {:ok, response}

          {:error, %GRPC.RPCError{} = error} ->
            Logger.error("gRPC get_user error: #{inspect(error)}")
            {:error, error.message}
        end

      safe_disconnect(channel)
      result
    end
  end

  @doc """
  Get user by email via gRPC.
  """
  def get_user_by_email(email) do
    with {:ok, channel} <- get_channel() do
      request = %Auth.GetUserByEmailRequest{email: email}

      result =
        case Auth.AuthService.Stub.get_user_by_email(channel, request) do
          {:ok, response} ->
            {:ok, response}

          {:error, %GRPC.RPCError{} = error} ->
            Logger.error("gRPC get_user_by_email error: #{inspect(error)}")
            {:error, error.message}
        end

      safe_disconnect(channel)
      result
    end
  end
end
