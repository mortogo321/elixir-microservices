import Config

config :alert,
  rabbitmq_host: System.get_env("RABBITMQ_HOST", "localhost"),
  rabbitmq_user: System.get_env("RABBITMQ_USER", "guest"),
  rabbitmq_pass: System.get_env("RABBITMQ_PASS", "guest")

config :alert, Alert.Mailer,
  relay: System.get_env("SMTP_HOST", "localhost"),
  port: String.to_integer(System.get_env("SMTP_PORT", "1025")),
  ssl: false,
  tls: :never,
  auth: :never
