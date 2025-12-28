# Elixir + Bun Microservice

A production-ready microservice demo featuring Elixir/Phoenix API with real-time WebSocket support, gRPC auth service, and Bun gateway.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Client (Browser)                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Web Gateway (Bun/Elysia)                            │
│                            localhost:3000                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   /api/*    │  │  /swagger   │  │   /health   │  │  /auth/* (UI)       │ │
│  │  REST Proxy │  │    Docs     │  │   Checks    │  │  Login/Register     │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                    │
                    ▼ HTTP/REST
┌─────────────────────────────────────────────────────────────────────────────┐
│                         API Service (Phoenix)                                │
│                            localhost:4000                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   /api/*    │  │ /swaggerui  │  │  Channels   │  │   gRPC Client       │ │
│  │  REST API   │  │    Docs     │  │  WebSocket  │  │   (Auth calls)      │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
         │                                                    │
         ▼ Ecto                                               ▼ gRPC
┌─────────────────────────┐                    ┌─────────────────────────────┐
│   PostgreSQL (api_dev)  │                    │    Auth Service (Elixir)    │
│      localhost:5432     │                    │       localhost:50051       │
│  ┌───────────────────┐  │                    │  ┌───────────────────────┐  │
│  │      messages     │  │                    │  │   gRPC Server         │  │
│  └───────────────────┘  │                    │  │   JWT Token Gen       │  │
└─────────────────────────┘                    │  │   User Management     │  │
                                               │  └───────────────────────┘  │
                                               └─────────────────────────────┘
                                                              │
                                                              ▼ Ecto
                                               ┌─────────────────────────────┐
                                               │  PostgreSQL (auth_dev)      │
                                               │      localhost:5432         │
                                               │  ┌───────────────────────┐  │
                                               │  │        users          │  │
                                               │  └───────────────────────┘  │
                                               └─────────────────────────────┘
```

## Features

- **Elixir Phoenix API** - REST API with OpenAPI/Swagger documentation
- **gRPC Auth Service** - Dedicated authentication microservice with JWT tokens
- **Real-time** - Phoenix Channels for WebSocket communication
- **Bun Gateway** - Fast TypeScript API gateway with Elysia
- **Auth UI** - Built-in login/register pages at `/auth/login`
- **PostgreSQL** - Database with Ecto ORM
- **Docker** - Multi-stage builds with hot reload support
- **CI/CD** - GitHub Actions pipeline with code quality, testing, build, deploy

## Quick Start

### Docker (Recommended)

```bash
# Start all services with hot reload
make dev

# Or manually
cd docker && docker compose -f compose.development.yml up --build
```

### Local Development

```bash
# Setup dependencies
make setup

# Start PostgreSQL
docker run -d --name postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=api_dev \
  -p 5432:5432 \
  postgres:16-alpine

# Terminal 1: Start API
cd api && mix deps.get && mix ecto.setup && iex -S mix phx.server

# Terminal 2: Start Web
cd web && bun install && bun run dev
```

## Services

| Service | URL | Description |
|---------|-----|-------------|
| Web Gateway | http://localhost:3000 | Bun/Elysia gateway service |
| Auth UI | http://localhost:3000/auth/login | Login/Register pages |
| Web Swagger | http://localhost:3000/swagger | Gateway documentation |
| API | http://localhost:4000 | Elixir Phoenix REST API |
| API Swagger | http://localhost:4000/swaggerui | API documentation |
| Auth gRPC | localhost:50051 | Authentication gRPC service |
| PostgreSQL | localhost:5432 | Database (api_dev, auth_dev) |

## Demo Accounts

After running seeds:
- `demo@example.com` / `password123`
- `admin@example.com` / `password123`

## Project Structure

```
├── api/                 # Elixir Phoenix API
│   ├── lib/api/         # Business logic (contexts)
│   ├── lib/api/grpc/    # gRPC client for auth service
│   ├── lib/api_web/     # Web layer (controllers, channels)
│   └── priv/repo/       # Migrations and seeds
├── auth/                # Elixir Auth gRPC service
│   ├── lib/auth/        # Auth business logic
│   ├── lib/auth/grpc/   # gRPC server implementation
│   └── priv/protos/     # Protobuf definitions
├── web/                 # Bun gateway service
│   └── src/
│       ├── routes/      # API proxy, health, auth UI
│       └── lib/         # API client utilities
├── docker/              # Docker compose files
├── docs/                # Documentation
└── .github/workflows/   # CI/CD pipeline
```

## Commands

```bash
make dev          # Start development with hot reload
make dev-build    # Rebuild and start
make dev-down     # Stop services
make dev-logs     # View logs

make test         # Run all tests
make lint         # Run linters
make format       # Format code

make prod         # Start production
make prod-build   # Build production images
```

## Hot Reload

Changes made on your host machine are immediately reflected in Docker containers:

- **API**: Edit files in `api/lib/` - Phoenix auto-recompiles
- **Web**: Edit files in `web/src/` - Bun hot reloads instantly

## GitHub Secrets (CI/CD)

Set these in your repository secrets for production deployment:

| Secret | Description |
|--------|-------------|
| `DB_USER` | PostgreSQL username |
| `DB_PASSWORD` | PostgreSQL password |
| `DB_HOST` | PostgreSQL host |
| `DB_NAME` | PostgreSQL database name |
| `DATABASE_URL` | Full database URL (optional) |
| `APP_HOST` | Application hostname |
| `APP_PORT` | Application port |
| `SECRET_KEY_BASE` | Phoenix secret (use `mix phx.gen.secret`) |
| `GUARDIAN_SECRET_KEY` | JWT secret key |
| `DB_POOL_SIZE` | Database connection pool size |
| `API_URL` | Internal API URL for web service |

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - System design and components
- [API Reference](docs/API.md) - REST and WebSocket API documentation
- [Development](docs/DEVELOPMENT.md) - Development setup and workflow
- [Deployment](docs/DEPLOYMENT.md) - Production deployment guide

## Tech Stack

- **Backend**: Elixir 1.16, Phoenix 1.7, Ecto 3.10
- **Auth Service**: Elixir gRPC, JOSE (JWT)
- **Gateway**: Bun 1.0, Elysia, TypeScript
- **Database**: PostgreSQL 16
- **Communication**: REST (HTTP), gRPC (Protobuf)
- **Containers**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
