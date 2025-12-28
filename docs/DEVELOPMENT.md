# Development Guide

## Prerequisites

- **Elixir** 1.16+ with OTP 26+
- **Bun** 1.0+
- **PostgreSQL** 16+
- **Docker** & **Docker Compose** (for containerized development)

## Quick Start

### Option 1: Docker Development (Recommended)

Hot reload is fully supported with Docker. Changes made on your host machine are immediately reflected in the containers.

```bash
# Start all services with hot reload
cd docker
docker compose -f compose.development.yml up --build

# Services:
# - API: http://localhost:4000
# - Web: http://localhost:3000
# - PostgreSQL: localhost:5432
```

### Option 2: Local Development

#### 1. Start PostgreSQL

```bash
# Using Docker
docker run -d --name postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=api_dev \
  -p 5432:5432 \
  postgres:16-alpine

# Or use your local PostgreSQL installation
```

#### 2. Start Elixir API

```bash
cd api

# Install dependencies
mix deps.get

# Create and migrate database
mix ecto.setup

# Start server with IEx
iex -S mix phx.server
```

API will be available at http://localhost:4000

#### 3. Start Bun Web Service

```bash
cd web

# Install dependencies
bun install

# Start with hot reload
bun run dev
```

Web service will be available at http://localhost:3000

---

## Hot Reload Details

### Elixir (Phoenix)

Phoenix provides automatic code reloading in development:

- **Endpoint code reloader**: Recompiles code on each request
- **File watcher**: Uses `inotify-tools` (Linux) or `fsevents` (macOS)

In Docker, source code is mounted as a volume:
```yaml
volumes:
  - ../api/lib:/app/lib:delegated
  - ../api/config:/app/config:delegated
```

### Bun

Bun's `--hot` flag enables instant hot reload:

```bash
bun run --hot src/index.ts
```

Changes are reflected without full restart.

---

## Database Management

### Migrations

```bash
cd api

# Create a new migration
mix ecto.gen.migration create_some_table

# Run migrations
mix ecto.migrate

# Rollback last migration
mix ecto.rollback

# Reset database
mix ecto.reset
```

### Seeds

```bash
# Run seeds
mix run priv/repo/seeds.exs

# Default test accounts:
# - demo@example.com / password123
# - admin@example.com / password123
```

### Database Console

```bash
# Using Docker
docker exec -it elixir-demo-postgres psql -U postgres -d api_dev

# Local
psql -U postgres -d api_dev
```

---

## Testing

### Elixir Tests

```bash
cd api

# Run all tests
mix test

# Run with coverage
mix coveralls

# Run specific test file
mix test test/api/accounts_test.exs

# Run tests matching a pattern
mix test --only accounts
```

### Bun Tests

```bash
cd web

# Run all tests
bun test

# Watch mode
bun test --watch
```

---

## Code Quality

### Elixir

```bash
cd api

# Format code
mix format

# Check formatting
mix format --check-formatted

# Run Credo (linter)
mix credo

# Run Dialyzer (static analysis)
mix dialyzer
```

### TypeScript/Bun

```bash
cd web

# Lint with Biome
bun run lint

# Fix lint issues
bun run lint:fix

# Format code
bun run format

# Type check
bun run typecheck
```

---

## API Documentation

### Elixir (OpenApiSpex)

- Swagger UI: http://localhost:4000/swaggerui
- OpenAPI JSON: http://localhost:4000/api/openapi

### Bun (Elysia Swagger)

- Swagger UI: http://localhost:3000/swagger

---

## Debugging

### Elixir IEx

```elixir
# In IEx session
iex -S mix phx.server

# Inspect a user
Api.Accounts.get_user(1)

# Run a query
Api.Repo.all(Api.Accounts.User)

# Debug with IEx.pry
require IEx; IEx.pry
```

### Bun

```bash
# Debug mode
bun --inspect src/index.ts
```

---

## Environment Variables

### API (.env)

```bash
# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_DB=api_dev

# Phoenix
PHX_HOST=localhost
SECRET_KEY_BASE=your_64_char_secret_key
GUARDIAN_SECRET_KEY=your_guardian_secret

# Optional
POOL_SIZE=10
PORT=4000
```

### Web (.env)

```bash
# API connection
API_URL=http://localhost:4000/api

# Environment
NODE_ENV=development
```

---

## Common Issues

### Port Already in Use

```bash
# Find process using port
lsof -i :4000
lsof -i :3000

# Kill process
kill -9 <PID>
```

### Database Connection Failed

```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Check connection
psql -h localhost -U postgres -d api_dev
```

### Dependencies Out of Sync

```bash
# Elixir
cd api && mix deps.get && mix deps.compile

# Bun
cd web && rm -rf node_modules && bun install
```

### Docker Volume Issues

```bash
# Remove all volumes and rebuild
cd docker
docker compose -f compose.development.yml down -v
docker compose -f compose.development.yml up --build
```
