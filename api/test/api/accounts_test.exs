defmodule Api.AccountsTest do
  use Api.DataCase

  alias Api.Accounts
  alias Api.Accounts.User

  describe "users" do
    @valid_attrs %{email: "test@example.com", password: "password123", name: "Test User"}
    @update_attrs %{name: "Updated Name"}
    @invalid_attrs %{email: nil, password: nil}

    test "list_users/0 returns all users" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      users = Accounts.list_users()
      assert length(users) == 1
      assert hd(users).id == user.id
    end

    test "get_user/1 returns the user with given id" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert Accounts.get_user(user.id).id == user.id
    end

    test "get_user_by_email/1 returns the user with given email" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert Accounts.get_user_by_email(user.email).id == user.id
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "test@example.com"
      assert user.name == "Test User"
      assert user.password_hash != nil
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with duplicate email returns error" do
      {:ok, _user} = Accounts.create_user(@valid_attrs)
      assert {:error, changeset} = Accounts.create_user(@valid_attrs)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "update_user/2 with valid data updates the user" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.name == "Updated Name"
    end

    test "delete_user/1 deletes the user" do
      {:ok, user} = Accounts.create_user(@valid_attrs)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert Accounts.get_user(user.id) == nil
    end

    test "authenticate_user/2 with valid credentials returns user" do
      {:ok, user} = Accounts.create_user(@valid_attrs)

      assert {:ok, authenticated_user} =
               Accounts.authenticate_user("test@example.com", "password123")

      assert authenticated_user.id == user.id
    end

    test "authenticate_user/2 with invalid password returns error" do
      {:ok, _user} = Accounts.create_user(@valid_attrs)

      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user("test@example.com", "wrongpassword")
    end

    test "authenticate_user/2 with non-existent email returns error" do
      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user("nonexistent@example.com", "password123")
    end
  end
end
