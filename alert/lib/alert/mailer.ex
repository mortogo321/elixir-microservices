defmodule Alert.Mailer do
  @moduledoc """
  Email sending functionality using Swoosh.
  """

  use Swoosh.Mailer, otp_app: :alert
  import Swoosh.Email
  require Logger

  @from {"Elixir Demo", "noreply@example.com"}

  def send_welcome_email(%{"email" => email, "name" => name}) do
    name = if name && name != "", do: name, else: "User"

    email =
      new()
      |> to({name, email})
      |> from(@from)
      |> subject("Welcome to Elixir Demo!")
      |> html_body(welcome_html(name))
      |> text_body(welcome_text(name))

    case deliver(email) do
      {:ok, _} ->
        Logger.info("Welcome email sent to #{email}")
        :ok

      {:error, reason} ->
        Logger.error("Failed to send welcome email: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def send_welcome_email(%{"email" => email}) do
    send_welcome_email(%{"email" => email, "name" => nil})
  end

  defp welcome_html(name) do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px 8px 0 0; }
        .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
        .button { display: inline-block; background: #667eea; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin-top: 20px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>Welcome, #{name}!</h1>
        </div>
        <div class="content">
          <p>Thanks for signing up for Elixir Demo. We're excited to have you!</p>
          <p>You can now:</p>
          <ul>
            <li>Create and share messages</li>
            <li>Connect with other users</li>
            <li>Explore the API</li>
          </ul>
          <a href="http://localhost:3000/auth/profile" class="button">View Your Profile</a>
        </div>
      </div>
    </body>
    </html>
    """
  end

  defp welcome_text(name) do
    """
    Welcome, #{name}!

    Thanks for signing up for Elixir Demo. We're excited to have you!

    You can now:
    - Create and share messages
    - Connect with other users
    - Explore the API

    View your profile: http://localhost:3000/auth/profile
    """
  end
end
