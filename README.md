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
                                           │   Service   │
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
| Web | 3000 | Bun/Elysia gateway with Auth UI |
| API | 4000 | Phoenix REST API |
| Auth | 50051 | gRPC authentication service |
| Alert | - | Event consumer (welcome emails) |
| PostgreSQL | 5432 | Database |
| RabbitMQ | 5672, 15672 | Message broker |
| Mailpit | 8025 | Email testing UI |

## Quick Start

```bash
cd docker
docker compose -f compose.development.yml up --build
```

**URLs:**
- Web UI: http://localhost:3000
- Auth UI: http://localhost:3000/auth/login
- API Swagger: http://localhost:4000/swaggerui
- RabbitMQ: http://localhost:15672 (guest/guest)
- Mailpit: http://localhost:8025

## Project Structure

```
├── api/          # Phoenix REST API
├── auth/         # gRPC auth service
├── alert/        # RabbitMQ consumer (emails)
├── web/          # Bun gateway
├── shared/       # Shared Elixir library
└── docker/       # Docker compose files
```

## Event Flow

```
Signup → Auth → RabbitMQ → Alert → Welcome Email
```

## Tech Stack

- Elixir 1.16, Phoenix 1.7
- gRPC, Protobuf
- RabbitMQ (AMQP)
- PostgreSQL 16
- Bun, Elysia, TypeScript
- Docker
