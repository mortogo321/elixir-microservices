defmodule ApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :api

  @session_options [
    store: :cookie,
    key: "_api_key",
    signing_salt: "secret_salt",
    same_site: "Lax"
  ]

  socket "/socket", ApiWeb.UserSocket,
    websocket: true,
    longpoll: false

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug CORSPlug,
    origin: ["http://localhost:3000", "http://localhost:5173"],
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    headers: ["Authorization", "Content-Type", "Accept"]

  plug ApiWeb.Router
end
