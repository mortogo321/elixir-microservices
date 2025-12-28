defmodule Api.Grpc.AuthClientBehaviour do
  @callback register(String.t(), String.t(), String.t() | nil) ::
              {:ok, map()} | {:error, any()}

  @callback login(String.t(), String.t()) ::
              {:ok, map()} | {:error, any()}

  @callback validate_token(String.t()) ::
              {:ok, map()} | {:error, any()}

  @callback refresh_token(String.t()) ::
              {:ok, map()} | {:error, any()}

  @callback get_user(String.t()) ::
              {:ok, map()} | {:error, any()}

  @callback get_user_by_email(String.t()) ::
              {:ok, map()} | {:error, any()}
end
