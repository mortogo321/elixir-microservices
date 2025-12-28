# Elixir Microservices Demo

Event-driven microservices with Elixir, Phoenix, gRPC, RabbitMQ, and Bun.

## Architecture

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│     Web     │─────▶│     API     │─────▶│    Auth     │
│  Bun:3000   │ HTTP │ Phoenix:4000│ gRPC │ Elixir:50051│
└─────────────┘      └─────────────┘      └──────┬──────┘
                            │                     │
                            ▼                     ▼
                     ┌─────────────┐       ┌─────────────┐
                     │  PostgreSQL │       │  RabbitMQ   │
                     │    :5432    │       │    :5672    │
                     └─────────────┘       └──────┬──────┘
                                                  │
                                                  ▼
                                           ┌─────────────┐
                                           │    Alert    │
                                           │   Consumer  │
                                           └──────┬──────┘
                                                  │
                                                  ▼
                                           ┌─────────────┐
                                           │   Mailpit   │
                                           │    :8025    │
                                           └─────────────┘
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| Web | 3000 | Bun/Elysia frontend |
| API | 4000 | Phoenix REST API |
| Auth | 50051 | gRPC authentication |
| Alert | - | RabbitMQ consumer (emails) |
| PostgreSQL | 5432 | Database |
| RabbitMQ | 5672, 15672 | Message broker |
| Mailpit | 8025 | Email testing |

## Quick Start

```bash
cd docker
docker compose -f compose.development.yml up --build
```

## URLs

- Web: http://localhost:3000
- API Docs: http://localhost:4000/swaggerui
- RabbitMQ: http://localhost:15672 (guest/guest)
- Mailpit: http://localhost:8025

## Project Structure

```
├── api/          # Phoenix REST API
├── auth/         # gRPC auth service
├── alert/        # RabbitMQ consumer
├── web/          # Bun frontend
├── shared/       # Shared Elixir library
├── docker/       # Docker configs
└── scripts/      # Dev scripts
```

## Scripts

```bash
./scripts/deps.sh      # Install dependencies
./scripts/format.sh    # Format code
./scripts/lint.sh      # Run Credo
./scripts/check.sh     # Format + lint
./scripts/test.sh      # Run tests
```

## Tech Stack

- Elixir 1.18, OTP 27, Phoenix 1.7
- gRPC, Protobuf
- RabbitMQ (AMQP 4.0)
- PostgreSQL 16
- Bun, TypeScript
