# =============================================================================
# Makefile for Elixir + Bun Microservice
# =============================================================================

.PHONY: help dev dev-build dev-down dev-logs dev-shell-api dev-shell-web \
        prod prod-build prod-down test lint format clean setup

# Default target
help:
	@echo "Elixir + Bun Microservice"
	@echo ""
	@echo "Development Commands:"
	@echo "  make dev          - Start all services with hot reload"
	@echo "  make dev-build    - Rebuild and start all services"
	@echo "  make dev-down     - Stop all services"
	@echo "  make dev-logs     - View logs from all services"
	@echo "  make dev-shell-api - Shell into API container"
	@echo "  make dev-shell-web - Shell into Web container"
	@echo ""
	@echo "Production Commands:"
	@echo "  make prod         - Start production services"
	@echo "  make prod-build   - Build production images"
	@echo "  make prod-down    - Stop production services"
	@echo ""
	@echo "Quality Commands:"
	@echo "  make test         - Run all tests"
	@echo "  make lint         - Run linters"
	@echo "  make format       - Format all code"
	@echo ""
	@echo "Setup Commands:"
	@echo "  make setup        - Initial setup"
	@echo "  make clean        - Clean build artifacts"

# =============================================================================
# Development
# =============================================================================

dev:
	cd docker && docker compose -f compose.development.yml up

dev-build:
	cd docker && docker compose -f compose.development.yml up --build

dev-down:
	cd docker && docker compose -f compose.development.yml down

dev-logs:
	cd docker && docker compose -f compose.development.yml logs -f

dev-shell-api:
	docker exec -it elixir-demo-api sh

dev-shell-web:
	docker exec -it elixir-demo-web sh

dev-db:
	docker exec -it elixir-demo-postgres psql -U postgres -d api_dev

# =============================================================================
# Production
# =============================================================================

prod:
	cd docker && docker compose -f compose.production.yml up -d

prod-build:
	docker build -t elixir-api:latest --target production ./api
	docker build -t elixir-web:latest --target production ./web

prod-down:
	cd docker && docker compose -f compose.production.yml down

# =============================================================================
# Testing
# =============================================================================

test: test-api test-web

test-api:
	cd api && mix test

test-web:
	cd web && bun test

test-coverage:
	cd api && mix coveralls

# =============================================================================
# Code Quality
# =============================================================================

lint: lint-api lint-web

lint-api:
	cd api && mix format --check-formatted
	cd api && mix credo --strict

lint-web:
	cd web && bun run lint
	cd web && bun run typecheck

format: format-api format-web

format-api:
	cd api && mix format

format-web:
	cd web && bun run format

# =============================================================================
# Setup & Clean
# =============================================================================

setup: setup-api setup-web
	@echo "Setup complete!"

setup-api:
	cd api && mix deps.get

setup-web:
	cd web && bun install

clean:
	cd api && rm -rf _build deps
	cd web && rm -rf node_modules dist
	cd docker && docker compose -f compose.development.yml down -v

# =============================================================================
# Database
# =============================================================================

db-create:
	cd api && mix ecto.create

db-migrate:
	cd api && mix ecto.migrate

db-seed:
	cd api && mix run priv/repo/seeds.exs

db-reset:
	cd api && mix ecto.reset
