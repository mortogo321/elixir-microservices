# Elixir Microservices Demo

[![CI/CD Pipeline](https://github.com/mortogo321/elixir-microservices/actions/workflows/ci.yml/badge.svg)](https://github.com/mortogo321/elixir-microservices/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Elixir 1.20](https://img.shields.io/badge/Elixir-1.20-purple.svg)](https://elixir-lang.org)
[![Phoenix 1.8](https://img.shields.io/badge/Phoenix-1.8-orange.svg)](https://phoenixframework.org)
[![Bun 1.4.2](https://img.shields.io/badge/Bun-1.4.2-black.svg)](https://bun.sh)

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
| Web | 3000 | Bun/Elysia gateway + auth UI |
| API | 4000 | Phoenix REST API (OpenAPI/Swagger) |
| Auth | 50051 | gRPC authentication (grpc_server 1.x stream API) |
| Alert | - | RabbitMQ consumer (emails via Swoosh) |
| PostgreSQL | 5432 | Database (pg 17) |
| RabbitMQ | 5672, 15672 | Message broker (4.3) |
| Mailpit | 8025, 1025 | Email testing |

## Quick Start

```bash
cd docker
docker compose -f compose.development.yml up --build
```

Production (requires env: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`,
`SECRET_KEY_BASE`, `GUARDIAN_SECRET_KEY`, `JWT_SECRET_KEY`):

```bash
cd docker
docker compose -f compose.production.yml up --build -d
```

## URLs

- Web: http://localhost:3000
- API Docs: http://localhost:4000/swaggerui
- API Health: http://localhost:4000/api/health
- RabbitMQ: http://localhost:15672 (guest/guest)
- Mailpit: http://localhost:8025

## Project Structure

```
├── api/          # Phoenix REST API (client of auth gRPC)
├── auth/         # gRPC auth service (grpc_server 1.x)
├── alert/        # RabbitMQ consumer (Swoosh emails)
├── web/          # Bun/Elysia gateway + auth UI
├── shared/       # Shared Elixir library
├── docker/       # Docker + Compose configs
├── docs/         # API / architecture / dev guides
└── scripts/      # Dev scripts
```

## Quality

```bash
make lint        # mix format --check + credo --strict (×4) + biome + tsc
make test        # mix test (api, 16 tests) + bun test (web, 2 tests)
make format      # mix format + biome --write
```

CI (`ci.yml`): changes detection → quality (format/credo/biome/typecheck) →
tests (Postgres 17 service, coveralls, bun) → Docker builds (api/auth/alert/web)
on `ubuntu-24.04` with Elixir 1.20/OTP 28 + Bun 1.4.2.

## Scripts

```bash
./scripts/deps.sh      # Install dependencies
./scripts/format.sh    # Format code
./scripts/lint.sh      # Run Credo
./scripts/check.sh     # Format + lint
./scripts/test.sh      # Run tests
```

## Tech Stack

- Elixir 1.20, OTP 28, Phoenix 1.8.15, Ecto 3.14
- gRPC 1.x split: `grpc` (client) + `grpc_server` (stream API) + Protobuf 0.17
- RabbitMQ 4.3 (AMQP 4.2), PostgreSQL 17, Swoosh 1.28
- Bun 1.4.2, Elysia 1.4.30, Biome 2.5.14, TypeScript 5.9 strict
  (`noUncheckedIndexedAccess`; TS pinned at 5.9 — v7 has no verified Elysia build story)

## Notes

- **gRPC 1.0 migration**: the auth server was rewritten from the deprecated
  struct-return API to the `GRPC.Stream.unary/map/run` pipeline; the client
  supervisor child was dropped (1.x starts via its own OTP application).
- **Postgres 0.22**: `postgrex ~> 0.21` resolves to 0.22.x (required by
  Ecto 3.14/Decimal 3.x); the `live_dashboard` compile warning about
  `Postgrex.Interval` is upstream — CI compiles deps before applying
  `--warnings-as-errors` to project code.
- **Cowlib advisory** (EEF-CVE-2026-43966): upstream, no fixed release yet;
  HTTP transcoding is not enabled on the auth server.

## License

MIT — see [LICENSE](LICENSE).
