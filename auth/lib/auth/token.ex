defmodule Auth.Token do
  @moduledoc """
  JWT token generation and validation using JOSE.
  """

  def generate_tokens(user) do
    config = Application.get_env(:auth, :jwt)
    secret_key = config[:secret_key]
    access_ttl = config[:access_token_ttl]
    refresh_ttl = config[:refresh_token_ttl]

    now = System.system_time(:second)

    access_token = generate_token(user, secret_key, now, access_ttl, "access")
    refresh_token = generate_token(user, secret_key, now, refresh_ttl, "refresh")

    {access_token, refresh_token, access_ttl}
  end

  def validate_token(token) do
    config = Application.get_env(:auth, :jwt)
    secret_key = config[:secret_key]

    jwk = JOSE.JWK.from_oct(secret_key)

    case JOSE.JWT.verify(jwk, token) do
      {true, %JOSE.JWT{fields: claims}, _jws} ->
        now = System.system_time(:second)

        cond do
          claims["exp"] < now ->
            {:error, :token_expired}

          true ->
            {:ok, claims}
        end

      {false, _, _} ->
        {:error, :invalid_token}
    end
  end

  def validate_refresh_token(token) do
    case validate_token(token) do
      {:ok, claims} ->
        if claims["type"] == "refresh" do
          {:ok, claims}
        else
          {:error, :invalid_token_type}
        end

      error ->
        error
    end
  end

  defp generate_token(user, secret_key, now, ttl, type) do
    claims = %{
      "sub" => to_string(user.id),
      "email" => user.email,
      "type" => type,
      "iat" => now,
      "exp" => now + ttl
    }

    jwk = JOSE.JWK.from_oct(secret_key)
    jws = %{"alg" => "HS256"}

    {_, token} = JOSE.JWT.sign(jwk, jws, claims) |> JOSE.JWS.compact()
    token
  end
end
