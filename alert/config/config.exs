import Config

config :alert,
  rabbitmq_host: System.get_env("RABBITMQ_HOST", "localhost"),
  rabbitmq_user: System.get_env("RABBITMQ_USER", "guest"),
  rabbitmq_pass: System.get_env("RABBITMQ_PASS", "guest"),
  rabbitmq_exchange: "events",
  rabbitmq_queue: "alert.user_signup"

config :alert, Alert.Mailer,
  adapter: Swoosh.Adapters.Local

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{config_env()}.exs"
