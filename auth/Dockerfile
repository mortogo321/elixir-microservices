# =============================================================================
# Multi-stage Dockerfile for Auth gRPC Service
# Supports: development (hot reload) and production builds
# =============================================================================

# -----------------------------------------------------------------------------
# Stage: base - Common base image with Elixir and dependencies
# -----------------------------------------------------------------------------
FROM elixir:1.16-otp-26-alpine AS base

RUN apk add --no-cache \
    build-base \
    git \
    inotify-tools \
    postgresql-client

WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# -----------------------------------------------------------------------------
# Stage: development - For hot reload during development
# -----------------------------------------------------------------------------
FROM base AS development

ENV MIX_ENV=dev

# Copy mix.exs (mix.lock may not exist initially)
COPY mix.exs ./
COPY mix.lock* ./

# Get dependencies
RUN mix deps.get || true

# Copy config and entrypoint
COPY config config
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 50051

# Use entrypoint that watches mix.exs and runs server with hot reload
CMD ["/usr/local/bin/docker-entrypoint.sh"]

# -----------------------------------------------------------------------------
# Stage: deps - Build dependencies for production
# -----------------------------------------------------------------------------
FROM base AS deps

ENV MIX_ENV=prod

COPY mix.exs ./
COPY mix.lock* ./
RUN mix deps.get --only prod
RUN mix deps.compile

# -----------------------------------------------------------------------------
# Stage: build - Compile application for production
# -----------------------------------------------------------------------------
FROM deps AS build

COPY config config
COPY lib lib
COPY priv priv

RUN mix compile
RUN mix release

# -----------------------------------------------------------------------------
# Stage: production - Minimal runtime image
# -----------------------------------------------------------------------------
FROM alpine:3.19 AS production

RUN apk add --no-cache \
    libstdc++ \
    openssl \
    ncurses-libs \
    postgresql-client

WORKDIR /app

# Create non-root user
RUN addgroup -g 1000 elixir && \
    adduser -u 1000 -G elixir -s /bin/sh -D elixir

COPY --from=build --chown=elixir:elixir /app/_build/prod/rel/auth ./

USER elixir

ENV MIX_ENV=prod

EXPOSE 50051

CMD ["bin/auth", "start"]
