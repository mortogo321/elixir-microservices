#!/bin/bash
# Run tests for all Elixir services

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Running tests..."

for service in api auth alert; do
  echo "  -> $service"
  cd "$ROOT_DIR/$service"
  mix test
done

echo "Done!"
