import Config

config :auth, Auth.Repo,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :logger, :console, format: "[$level] $message\n"
