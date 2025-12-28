# =============================================================================
# Multi-stage Dockerfile for Bun Web Service
# Supports: development (hot reload) and production builds
# =============================================================================

# -----------------------------------------------------------------------------
# Stage: base - Common base image with Bun
# -----------------------------------------------------------------------------
FROM oven/bun:1-alpine AS base

WORKDIR /app

# -----------------------------------------------------------------------------
# Stage: development - For hot reload during development
# -----------------------------------------------------------------------------
FROM base AS development

ENV NODE_ENV=development

# Copy package files first for better layer caching (support both lockfile formats)
COPY package.json bun.lock* bun.lockb* ./

# Install dependencies (will be overwritten by volume mount but cached in image)
RUN bun install

# Copy entrypoint script that watches for package.json changes
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# The source code will be mounted as a volume for hot reload
# This allows editing on host and auto-reload in container

EXPOSE 3000

# Use entrypoint that watches package.json and runs hot reload
CMD ["/usr/local/bin/docker-entrypoint.sh"]

# -----------------------------------------------------------------------------
# Stage: deps - Install production dependencies
# -----------------------------------------------------------------------------
FROM base AS deps

COPY package.json bun.lock* bun.lockb* ./
RUN bun install --production

# -----------------------------------------------------------------------------
# Stage: build - Build application for production
# -----------------------------------------------------------------------------
FROM base AS build

COPY package.json bun.lock* bun.lockb* ./
RUN bun install

COPY tsconfig.json biome.json ./
COPY src src

# Type check and build
RUN bun run typecheck
RUN bun build src/index.ts --outdir ./dist --target bun --minify

# -----------------------------------------------------------------------------
# Stage: production - Minimal runtime image
# -----------------------------------------------------------------------------
FROM oven/bun:1-alpine AS production

WORKDIR /app

# bun user already exists in oven/bun image, just use it
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
