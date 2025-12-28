defmodule ApiWeb.HealthControllerTest do
  use ApiWeb.ConnCase

  describe "GET /api/health" do
    test "returns health status", %{conn: conn} do
      conn = get(conn, "/api/health")
      response = json_response(conn, 200)

      assert response["status"] == "ok"
      assert response["service"] == "elixir-api"
      assert response["timestamp"] != nil
    end
  end
end
