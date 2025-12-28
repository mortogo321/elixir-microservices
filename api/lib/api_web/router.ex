defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: ApiWeb.ApiSpec
  end

  pipeline :auth do
    plug ApiWeb.Plugs.AuthPipeline
  end

  scope "/api" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/swaggerui" do
    pipe_through :api

    get "/", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  scope "/api", ApiWeb do
    pipe_through :api

    # Health check
    get "/health", HealthController, :index

    # Auth routes (via gRPC to auth service)
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/refresh", AuthController, :refresh
    get "/auth/validate", AuthController, :validate

    # Public messages (read only)
    get "/messages", MessageController, :index
  end

  scope "/api", ApiWeb do
    pipe_through [:api, :auth]

    # Protected user routes
    get "/users/me", UserController, :me
    resources "/users", UserController, except: [:new, :edit]

    # Protected message routes
    post "/messages", MessageController, :create
    get "/messages/:id", MessageController, :show
    put "/messages/:id", MessageController, :update
    delete "/messages/:id", MessageController, :delete
  end

  if Application.compile_env(:api, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: ApiWeb.Telemetry
    end
  end
end
