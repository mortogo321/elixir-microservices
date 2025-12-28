# API Reference

## Base URLs

- **Elixir API**: `http://localhost:4000/api`
- **Bun Gateway**: `http://localhost:3000/api`
- **Swagger UI (Elixir)**: `http://localhost:4000/swaggerui`
- **Swagger UI (Bun)**: `http://localhost:3000/swagger`

## Authentication

All protected endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

---

## Endpoints

### Health Check

#### GET /api/health

Check service health status.

**Response 200:**
```json
{
  "status": "ok",
  "timestamp": "2024-12-27T00:00:00Z",
  "service": "elixir-api"
}
```

---

### Authentication

#### POST /api/auth/register

Create a new user account.

**Request Body:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe"
  }
}
```

**Response 201:**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "inserted_at": "2024-12-27T00:00:00Z",
    "updated_at": "2024-12-27T00:00:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response 422 (Validation Error):**
```json
{
  "errors": {
    "email": ["has already been taken"],
    "password": ["should be at least 6 character(s)"]
  }
}
```

---

#### POST /api/auth/login

Authenticate and get a token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response 200:**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response 401:**
```json
{
  "error": "Invalid email or password"
}
```

---

### Users (Protected)

#### GET /api/users/me

Get the current authenticated user.

**Headers:** `Authorization: Bearer <token>`

**Response 200:**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

---

#### GET /api/users

List all users.

**Headers:** `Authorization: Bearer <token>`

**Response 200:**
```json
{
  "users": [
    {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe"
    }
  ]
}
```

---

#### GET /api/users/:id

Get a specific user.

**Headers:** `Authorization: Bearer <token>`

**Response 200:**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

---

### Messages

#### GET /api/messages (Public)

List all messages (most recent 50).

**Response 200:**
```json
{
  "messages": [
    {
      "id": 1,
      "content": "Hello, world!",
      "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
      },
      "inserted_at": "2024-12-27T00:00:00Z",
      "updated_at": "2024-12-27T00:00:00Z"
    }
  ]
}
```

---

#### POST /api/messages (Protected)

Create a new message.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "message": {
    "content": "Hello, world!"
  }
}
```

**Response 201:**
```json
{
  "message": {
    "id": 1,
    "content": "Hello, world!",
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    "inserted_at": "2024-12-27T00:00:00Z",
    "updated_at": "2024-12-27T00:00:00Z"
  }
}
```

---

#### PUT /api/messages/:id (Protected)

Update a message (owner only).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "message": {
    "content": "Updated content"
  }
}
```

**Response 200:**
```json
{
  "message": {
    "id": 1,
    "content": "Updated content",
    "user": {...}
  }
}
```

**Response 403:**
```json
{
  "error": "You can only update your own messages"
}
```

---

#### DELETE /api/messages/:id (Protected)

Delete a message (owner only).

**Headers:** `Authorization: Bearer <token>`

**Response 204:** No content

**Response 403:**
```json
{
  "error": "You can only delete your own messages"
}
```

---

## WebSocket API (Phoenix Channels)

### Connection

Connect to the WebSocket endpoint:

```
ws://localhost:4000/socket/websocket?token=<jwt_token>
```

### Channels

#### Room Channel (`room:lobby`)

Join:
```json
{"topic": "room:lobby", "event": "phx_join", "payload": {}, "ref": "1"}
```

Send message:
```json
{"topic": "room:lobby", "event": "shout", "payload": {"message": "Hello!"}, "ref": "2"}
```

Receive broadcast:
```json
{
  "topic": "room:lobby",
  "event": "shout",
  "payload": {
    "user": {"id": 1, "name": "John"},
    "message": "Hello!",
    "timestamp": "2024-12-27T00:00:00Z"
  }
}
```

---

#### Messages Channel (`messages:lobby`)

Join (receives message history):
```json
{"topic": "messages:lobby", "event": "phx_join", "payload": {}, "ref": "1"}
```

History response:
```json
{
  "topic": "messages:lobby",
  "event": "messages_history",
  "payload": {
    "messages": [...]
  }
}
```

Send new message:
```json
{"topic": "messages:lobby", "event": "new_message", "payload": {"content": "Hello!"}, "ref": "2"}
```

Events received:
- `new_message` - When a new message is created
- `message_updated` - When a message is updated
- `message_deleted` - When a message is deleted

---

## Error Responses

### 401 Unauthorized
```json
{
  "error": "unauthenticated"
}
```

### 403 Forbidden
```json
{
  "error": "You can only update your own messages"
}
```

### 404 Not Found
```json
{
  "errors": {
    "detail": "Not Found"
  }
}
```

### 422 Unprocessable Entity
```json
{
  "errors": {
    "field_name": ["error message"]
  }
}
```

### 500 Internal Server Error
```json
{
  "errors": {
    "detail": "Internal Server Error"
  }
}
```
