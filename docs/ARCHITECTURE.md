# Architecture Overview

## System Components

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Client Layer                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │   Browser   │  │  Mobile App │  │   CLI/SDK   │                 │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                 │
└─────────┼────────────────┼────────────────┼─────────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        Gateway Layer (Bun)                          │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                    Elysia Web Server                          │ │
│  │  • REST API Gateway (proxies to Elixir API)                   │ │
│  │  • Swagger/OpenAPI Documentation                              │ │
│  │  • Request validation with TypeBox                            │ │
│  │  • CORS handling                                              │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                              Port: 3000                             │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        API Layer (Elixir/Phoenix)                   │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                    Phoenix Framework                          │ │
│  │  • REST API Controllers                                       │ │
│  │  • Phoenix Channels (WebSocket real-time)                     │ │
│  │  • Guardian JWT Authentication                                │ │
│  │  • OpenAPI/Swagger Documentation                              │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                              Port: 4000                             │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        Data Layer (PostgreSQL)                      │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                    PostgreSQL 16                              │ │
│  │  • Users table                                                │ │
│  │  • Messages table                                             │ │
│  │  • Managed by Ecto migrations                                 │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                              Port: 5432                             │
└─────────────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
elixir/
├── api/                          # Elixir Phoenix API
│   ├── config/                   # Environment configurations
│   │   ├── config.exs           # Base config
│   │   ├── dev.exs              # Development config
│   │   ├── prod.exs             # Production config
│   │   ├── test.exs             # Test config
│   │   └── runtime.exs          # Runtime config (prod)
│   ├── lib/
│   │   ├── api/                 # Business logic
│   │   │   ├── accounts.ex      # User management context
│   │   │   ├── accounts/        # User schema
│   │   │   ├── messages.ex      # Messages context
│   │   │   ├── messages/        # Message schema
│   │   │   ├── guardian.ex      # JWT configuration
│   │   │   └── repo.ex          # Database repository
│   │   └── api_web/             # Web layer
│   │       ├── channels/        # Phoenix Channels
│   │       ├── controllers/     # REST controllers
│   │       ├── plugs/           # Auth plugs
│   │       ├── endpoint.ex      # HTTP endpoint
│   │       └── router.ex        # Routes
│   ├── priv/
│   │   └── repo/
│   │       ├── migrations/      # Ecto migrations
│   │       └── seeds.exs        # Database seeds
│   ├── test/                    # Tests
│   ├── Dockerfile               # Multi-stage Docker build
│   └── mix.exs                  # Dependencies
│
├── web/                          # Bun Web Service
│   ├── src/
│   │   ├── lib/
│   │   │   ├── api-client.ts    # HTTP client for API
│   │   │   └── socket.ts        # Phoenix socket client
│   │   ├── routes/
│   │   │   ├── api.ts           # API proxy routes
│   │   │   └── health.ts        # Health check
│   │   └── index.ts             # Entry point
│   ├── Dockerfile               # Multi-stage Docker build
│   ├── package.json             # Dependencies
│   └── tsconfig.json            # TypeScript config
│
├── docker/                       # Docker configurations
│   ├── compose.development.yml  # Dev compose with hot reload
│   ├── compose.production.yml   # Production compose
│   └── init-db.sql              # Database initialization
│
├── docs/                         # Documentation
│   ├── ARCHITECTURE.md          # This file
│   ├── API.md                   # API reference
│   ├── DEVELOPMENT.md           # Development guide
│   └── DEPLOYMENT.md            # Deployment guide
│
└── .github/
    └── workflows/
        └── ci.yml               # CI/CD pipeline
```

## Data Flow

### REST API Request Flow

```
Client Request
     │
     ▼
┌─────────────┐
│  Bun/Elysia │ ◄─── Validation, CORS, Swagger
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Phoenix   │ ◄─── Authentication (Guardian JWT)
│   Router    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Controller  │ ◄─── Business Logic
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Context   │ ◄─── Data Access (Ecto)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ PostgreSQL  │
└─────────────┘
```

### Real-time WebSocket Flow

```
Client WebSocket Connection
        │
        ▼
┌───────────────┐
│  UserSocket   │ ◄─── JWT Authentication
└───────┬───────┘
        │
        ▼
┌───────────────┐
│   Channel     │ ◄─── room:lobby, messages:lobby
└───────┬───────┘
        │
        ├─────────────────┐
        ▼                 ▼
┌───────────────┐  ┌───────────────┐
│    PubSub     │  │   Broadcast   │
│ (in-process)  │  │ (to clients)  │
└───────────────┘  └───────────────┘
```

## Technology Choices

| Component | Technology | Reason |
|-----------|------------|--------|
| API | Elixir/Phoenix | Excellent concurrency, fault tolerance, real-time support |
| Gateway | Bun/Elysia | Fast startup, TypeScript, modern DX |
| Database | PostgreSQL | Reliable, ACID compliant, great with Ecto |
| Auth | Guardian/JWT | Stateless, scalable authentication |
| Real-time | Phoenix Channels | Built-in WebSocket support, PubSub |
| Containers | Docker | Consistent environments, easy deployment |
| CI/CD | GitHub Actions | Integrated with GitHub, free for public repos |

## Security Considerations

1. **Authentication**: JWT tokens via Guardian
2. **Authorization**: User-based message ownership
3. **Input Validation**: Ecto changesets + Elysia TypeBox
4. **CORS**: Configured for specific origins
5. **SQL Injection**: Prevented by Ecto parameterized queries
6. **Password Storage**: Bcrypt hashing
