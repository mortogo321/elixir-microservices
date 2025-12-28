import Config

config :auth,
  ecto_repos: [Auth.Repo]

config :auth, Auth.Repo,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: System.get_env("POSTGRES_DB", "auth_dev"),
  pool_size: 10

config :auth, :grpc, port: String.to_integer(System.get_env("GRPC_PORT", "50051"))

config :auth, :jwt,
  secret_key: System.get_env("JWT_SECRET_KEY", "dev_jwt_secret_key_min_32_chars_long"),
  # 1 hour
  access_token_ttl: 3600,
  # 7 days
  refresh_token_ttl: 604_800

config :auth,
  rabbitmq_host: System.get_env("RABBITMQ_HOST", "localhost"),
  rabbitmq_user: System.get_env("RABBITMQ_USER", "guest"),
  rabbitmq_pass: System.get_env("RABBITMQ_PASS", "guest"),
  rabbitmq_exchange: "events"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{config_env()}.exs"
