defmodule ApiWeb.AuthControllerTest do
  use ApiWeb.ConnCase

  describe "POST /api/auth/register" do
    test "creates user and returns token", %{conn: conn} do
      conn =
        post(conn, "/api/auth/register", %{
          user: %{
            email: "new@example.com",
            password: "password123",
            name: "New User"
          }
        })

      response = json_response(conn, 201)
      assert response["user"]["email"] == "new@example.com"
      assert response["token"] != nil
    end

    test "returns error for invalid data", %{conn: conn} do
      conn =
        post(conn, "/api/auth/register", %{
          user: %{
            email: "invalid",
            password: "short"
          }
        })

      response = json_response(conn, 422)
      assert response["errors"] != nil
    end
  end

  describe "POST /api/auth/login" do
    test "returns token for valid credentials", %{conn: conn} do
      {:ok, _user} =
        Api.Accounts.create_user(%{
          email: "login@example.com",
          password: "password123",
          name: "Login User"
        })

      conn =
        post(conn, "/api/auth/login", %{
          email: "login@example.com",
          password: "password123"
        })

      response = json_response(conn, 200)
      assert response["user"]["email"] == "login@example.com"
      assert response["token"] != nil
    end

    test "returns error for invalid credentials", %{conn: conn} do
      conn =
        post(conn, "/api/auth/login", %{
          email: "nonexistent@example.com",
          password: "wrongpassword"
        })

      response = json_response(conn, 401)
      assert response["error"] == "Invalid email or password"
    end
  end
end
