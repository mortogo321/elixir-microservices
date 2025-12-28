#!/bin/bash
# Run all code quality checks (format + lint)

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Checking format ==="
for service in shared api auth alert; do
  echo "  -> $service"
  cd "$ROOT_DIR/$service"
  mix format --check-formatted
done

echo ""
echo "=== Running Credo ==="
for service in api auth alert; do
  echo "  -> $service"
  cd "$ROOT_DIR/$service"
  mix credo --strict
done

echo ""
echo "All checks passed!"
