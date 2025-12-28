defmodule ApiWeb.ApiSpec do
  @moduledoc false
  alias OpenApiSpex.{Components, Info, OpenApi, SecurityScheme, Server}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(ApiWeb.Endpoint)
      ],
      info: %Info{
        title: "Elixir Phoenix API",
        version: "1.0.0",
        description: "REST API with real-time support via Phoenix Channels"
      },
      paths: OpenApiSpex.Paths.from_router(ApiWeb.Router),
      components: %Components{
        securitySchemes: %{
          "bearer" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT"
          }
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
