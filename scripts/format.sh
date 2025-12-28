#!/bin/bash
# Format all Elixir services

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Formatting Elixir code..."

for service in shared api auth alert; do
  echo "  -> $service"
  cd "$ROOT_DIR/$service"
  mix format
done

echo "Done!"
