import Config

config :alert,
  rabbitmq_host: System.get_env("RABBITMQ_HOST", "localhost"),
  rabbitmq_user: System.get_env("RABBITMQ_USER", "guest"),
  rabbitmq_pass: System.get_env("RABBITMQ_PASS", "guest")
