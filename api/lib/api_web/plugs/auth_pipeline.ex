defmodule ApiWeb.Plugs.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :api,
    module: Api.Guardian,
    error_handler: ApiWeb.Plugs.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
