#!/bin/bash
# Run Credo linting on all Elixir services

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Running Credo..."

for service in api auth alert; do
  echo "  -> $service"
  cd "$ROOT_DIR/$service"
  mix credo --strict
done

echo "Done!"
