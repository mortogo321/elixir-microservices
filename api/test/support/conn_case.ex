defmodule ApiWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import ApiWeb.ConnCase

      alias ApiWeb.Router.Helpers, as: Routes

      @endpoint ApiWeb.Endpoint
    end
  end

  setup tags do
    Api.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def create_user_and_token(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test#{System.unique_integer()}@example.com",
        password: "password123",
        name: "Test User"
      })
      |> Api.Accounts.create_user()

    {:ok, token, _claims} = Api.Guardian.encode_and_sign(user)
    {user, token}
  end

  def authenticate_conn(conn, token) do
    Plug.Conn.put_req_header(conn, "authorization", "Bearer #{token}")
  end
end
