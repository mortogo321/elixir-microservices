defmodule ApiWeb.Schemas do
  @moduledoc false
  alias OpenApiSpex.Schema

  defmodule User do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "User",
      description: "A user of the application",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "User ID"},
        email: %Schema{type: :string, format: :email, description: "User email"},
        name: %Schema{type: :string, description: "User name"},
        inserted_at: %Schema{type: :string, format: :"date-time", description: "Created at"},
        updated_at: %Schema{type: :string, format: :"date-time", description: "Updated at"}
      },
      required: [:id, :email],
      example: %{
        id: 1,
        email: "demo@example.com",
        name: "Demo User",
        inserted_at: "2024-12-27T00:00:00Z",
        updated_at: "2024-12-27T00:00:00Z"
      }
    })
  end

  defmodule UserRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "UserRequest",
      description: "Request body for creating/updating a user",
      type: :object,
      properties: %{
        user: %Schema{
          type: :object,
          properties: %{
            email: %Schema{type: :string, format: :email},
            password: %Schema{type: :string, minLength: 6},
            name: %Schema{type: :string}
          },
          required: [:email, :password]
        }
      },
      required: [:user]
    })
  end

  defmodule LoginRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "LoginRequest",
      description: "Request body for user login",
      type: :object,
      properties: %{
        email: %Schema{type: :string, format: :email},
        password: %Schema{type: :string}
      },
      required: [:email, :password],
      example: %{
        email: "demo@example.com",
        password: "password123"
      }
    })
  end

  defmodule AuthResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "AuthResponse",
      description: "Authentication response with user and tokens",
      type: :object,
      properties: %{
        user: User,
        access_token: %Schema{type: :string, description: "JWT access token"},
        refresh_token: %Schema{type: :string, description: "JWT refresh token"},
        expires_in: %Schema{type: :integer, description: "Token expiration time in seconds"}
      },
      required: [:user, :access_token]
    })
  end

  defmodule RefreshRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "RefreshRequest",
      description: "Request body for token refresh",
      type: :object,
      properties: %{
        refresh_token: %Schema{type: :string, description: "Refresh token"}
      },
      required: [:refresh_token],
      example: %{
        refresh_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
      }
    })
  end

  defmodule ValidateResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ValidateResponse",
      description: "Token validation response",
      type: :object,
      properties: %{
        valid: %Schema{type: :boolean, description: "Whether the token is valid"},
        user: User
      },
      required: [:valid]
    })
  end

  defmodule Message do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Message",
      description: "A chat message",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Message ID"},
        content: %Schema{type: :string, description: "Message content"},
        user: User,
        inserted_at: %Schema{type: :string, format: :"date-time"},
        updated_at: %Schema{type: :string, format: :"date-time"}
      },
      required: [:id, :content, :user]
    })
  end

  defmodule MessageRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "MessageRequest",
      description: "Request body for creating/updating a message",
      type: :object,
      properties: %{
        message: %Schema{
          type: :object,
          properties: %{
            content: %Schema{type: :string, minLength: 1, maxLength: 1000}
          },
          required: [:content]
        }
      },
      required: [:message]
    })
  end

  defmodule MessagesResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "MessagesResponse",
      description: "Response containing a list of messages",
      type: :object,
      properties: %{
        messages: %Schema{type: :array, items: Message}
      },
      required: [:messages]
    })
  end

  defmodule Error do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Error",
      description: "Error response",
      type: :object,
      properties: %{
        error: %Schema{type: :string, description: "Error message"},
        errors: %Schema{type: :object, description: "Validation errors"}
      }
    })
  end

  defmodule HealthResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "HealthResponse",
      description: "Health check response",
      type: :object,
      properties: %{
        status: %Schema{type: :string},
        timestamp: %Schema{type: :string, format: :"date-time"},
        service: %Schema{type: :string}
      },
      required: [:status, :timestamp, :service],
      example: %{
        status: "ok",
        timestamp: "2024-12-27T00:00:00Z",
        service: "elixir-api"
      }
    })
  end
end
