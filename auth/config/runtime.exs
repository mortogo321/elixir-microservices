import Config

if config_env() == :prod do
  config :auth, Auth.Repo,
    username: System.get_env("POSTGRES_USER") || raise("POSTGRES_USER not set"),
    password: System.get_env("POSTGRES_PASSWORD") || raise("POSTGRES_PASSWORD not set"),
    hostname: System.get_env("POSTGRES_HOST") || raise("POSTGRES_HOST not set"),
    database: System.get_env("POSTGRES_DB") || raise("POSTGRES_DB not set"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

  config :auth, :grpc,
    port: String.to_integer(System.get_env("GRPC_PORT", "50051"))

  config :auth, :jwt,
    secret_key: System.get_env("JWT_SECRET_KEY") || raise("JWT_SECRET_KEY not set"),
    access_token_ttl: String.to_integer(System.get_env("ACCESS_TOKEN_TTL", "3600")),
    refresh_token_ttl: String.to_integer(System.get_env("REFRESH_TOKEN_TTL", "604800"))
end
