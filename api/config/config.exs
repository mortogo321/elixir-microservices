import Config

config :api,
  ecto_repos: [Api.Repo],
  generators: [timestamp_type: :utc_datetime]

config :api, ApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: ApiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Api.PubSub,
  live_view: [signing_salt: "secret_salt"]

config :api, Api.Guardian,
  issuer: "api",
  secret_key: "dev_secret_key_change_in_production"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
