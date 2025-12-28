# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias Api.Repo
alias Api.Accounts.User
alias Api.Messages.Message

# Create demo users
{:ok, user1} =
  Api.Accounts.create_user(%{
    email: "demo@example.com",
    name: "Demo User",
    password: "password123"
  })

{:ok, user2} =
  Api.Accounts.create_user(%{
    email: "admin@example.com",
    name: "Admin User",
    password: "password123"
  })

# Create some demo messages
messages = [
  %{content: "Hello, welcome to the chat!", user_id: user1.id},
  %{content: "Hi there! Thanks for having me.", user_id: user2.id},
  %{content: "This is a demo of real-time messaging with Phoenix Channels.", user_id: user1.id},
  %{content: "Pretty cool, right?", user_id: user2.id}
]

Enum.each(messages, fn msg ->
  %Message{}
  |> Message.changeset(msg)
  |> Repo.insert!()
end)

IO.puts("Seeds completed successfully!")
IO.puts("Demo accounts:")
IO.puts("  - email: demo@example.com, password: password123")
IO.puts("  - email: admin@example.com, password: password123")
