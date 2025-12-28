import Config

config :api, Api.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "api_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :api, ApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_that_is_at_least_64_characters_long_for_testing",
  server: false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime

# Use mock for auth client in tests
config :api, :auth_client, Api.Grpc.AuthClientMock
