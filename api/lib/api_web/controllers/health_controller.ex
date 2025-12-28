defmodule ApiWeb.HealthController do
  use ApiWeb, :controller

  alias OpenApiSpex.Operation
  alias ApiWeb.Schemas.HealthResponse

  def open_api_operation(action), do: apply(__MODULE__, :"#{action}_operation", [])

  def index_operation do
    %Operation{
      tags: ["health"],
      summary: "Health check",
      description: "Returns the health status of the API",
      operationId: "HealthController.index",
      responses: %{
        200 => Operation.response("Health response", "application/json", HealthResponse)
      }
    }
  end

  def index(conn, _params) do
    json(conn, %{
      status: "ok",
      timestamp: DateTime.utc_now(),
      service: "elixir-api"
    })
  end
end
