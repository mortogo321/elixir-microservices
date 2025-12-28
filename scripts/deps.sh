#!/bin/bash
# Install dependencies for all Elixir services

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Installing dependencies..."

for service in shared api auth alert; do
  echo "  -> $service"
  cd "$ROOT_DIR/$service"
  mix deps.get
done

echo "Done!"
