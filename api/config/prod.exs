import Config

config :api, Api.Repo,
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: System.get_env("POSTGRES_HOST"),
  database: System.get_env("POSTGRES_DB"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "10"))

config :api, ApiWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST", "localhost"), port: 443, scheme: "https"],
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT", "4000"))],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :logger, level: :info
