defmodule ApiWeb.AuthControllerTest do
  use ApiWeb.ConnCase

  import Mox

  setup :verify_on_exit!

  describe "POST /api/auth/register" do
    test "creates user and returns token", %{conn: conn} do
      Api.Grpc.AuthClientMock
      |> expect(:register, fn "new@example.com", "password123", "New User" ->
        {:ok,
         %{
           success: true,
           message: "User registered successfully",
           user: %{
             id: "1",
             email: "new@example.com",
             name: "New User",
             created_at: "2024-01-01T00:00:00Z",
             updated_at: "2024-01-01T00:00:00Z"
           },
           access_token: "test_access_token",
           refresh_token: "test_refresh_token",
           expires_in: 3600
         }}
      end)

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
      assert response["access_token"] == "test_access_token"
    end

    test "returns error for invalid data", %{conn: conn} do
      Api.Grpc.AuthClientMock
      |> expect(:register, fn "invalid", "short", nil ->
        {:ok,
         %{
           success: false,
           message: "email: has invalid format; password: should be at least 8 character(s)"
         }}
      end)

      conn =
        post(conn, "/api/auth/register", %{
          user: %{
            email: "invalid",
            password: "short"
          }
        })

      response = json_response(conn, 422)
      assert response["error"] != nil
    end
  end

  describe "POST /api/auth/login" do
    test "returns token for valid credentials", %{conn: conn} do
      Api.Grpc.AuthClientMock
      |> expect(:login, fn "login@example.com", "password123" ->
        {:ok,
         %{
           success: true,
           message: "Login successful",
           user: %{
             id: "1",
             email: "login@example.com",
             name: "Login User",
             created_at: "2024-01-01T00:00:00Z",
             updated_at: "2024-01-01T00:00:00Z"
           },
           access_token: "test_access_token",
           refresh_token: "test_refresh_token",
           expires_in: 3600
         }}
      end)

      conn =
        post(conn, "/api/auth/login", %{
          email: "login@example.com",
          password: "password123"
        })

      response = json_response(conn, 200)
      assert response["user"]["email"] == "login@example.com"
      assert response["access_token"] == "test_access_token"
    end

    test "returns error for invalid credentials", %{conn: conn} do
      Api.Grpc.AuthClientMock
      |> expect(:login, fn "nonexistent@example.com", "wrongpassword" ->
        {:ok,
         %{
           success: false,
           message: "Invalid email or password"
         }}
      end)

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
