# =============================================================================
# Multi-stage Dockerfile for Bun Web Service
# Supports: development (hot reload) and production builds
# =============================================================================

# -----------------------------------------------------------------------------
# Stage: base - Common base image with Bun
# -----------------------------------------------------------------------------
FROM oven/bun:1.0-alpine AS base

WORKDIR /app

# -----------------------------------------------------------------------------
# Stage: development - For hot reload during development
# -----------------------------------------------------------------------------
FROM base AS development

ENV NODE_ENV=development

# Copy package files first for better layer caching
COPY package.json bun.lockb* ./

# Install dependencies (will be overwritten by volume mount but cached in image)
RUN bun install

# The source code will be mounted as a volume for hot reload
# This allows editing on host and auto-reload in container

EXPOSE 3000

# Use bun --hot for hot reload
CMD ["sh", "-c", "bun install && bun run --hot src/index.ts"]

# -----------------------------------------------------------------------------
# Stage: deps - Install production dependencies
# -----------------------------------------------------------------------------
FROM base AS deps

COPY package.json bun.lockb* ./
RUN bun install --production --frozen-lockfile

# -----------------------------------------------------------------------------
# Stage: build - Build application for production
# -----------------------------------------------------------------------------
FROM base AS build

COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile

COPY tsconfig.json biome.json ./
COPY src src

# Type check and build
RUN bun run typecheck
RUN bun build src/index.ts --outdir ./dist --target bun --minify

# -----------------------------------------------------------------------------
# Stage: production - Minimal runtime image
# -----------------------------------------------------------------------------
FROM oven/bun:1.0-alpine AS production

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1000 bun && \
    adduser -u 1000 -G bun -s /bin/sh -D bun

# Copy production dependencies
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./

USER bun

ENV NODE_ENV=production

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["bun", "run", "dist/index.js"]
