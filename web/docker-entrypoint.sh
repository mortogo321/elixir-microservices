#!/bin/sh
set -e

# Store hash of package.json for change detection
PACKAGE_HASH_FILE="/tmp/.package-hash"

get_package_hash() {
  md5sum /app/package.json 2>/dev/null | cut -d' ' -f1
}

# Initial install
echo "📦 Installing dependencies..."
bun install

# Store initial hash
get_package_hash > "$PACKAGE_HASH_FILE"

# Watch for package.json changes in background
(
  while true; do
    sleep 2
    CURRENT_HASH=$(get_package_hash)
    STORED_HASH=$(cat "$PACKAGE_HASH_FILE" 2>/dev/null || echo "")

    if [ "$CURRENT_HASH" != "$STORED_HASH" ]; then
      echo "📦 package.json changed, reinstalling dependencies..."
      bun install
      echo "$CURRENT_HASH" > "$PACKAGE_HASH_FILE"
      echo "✅ Dependencies updated! Hot reload will pick up changes."
    fi
  done
) &

# Start the app with hot reload
echo "🦊 Starting Bun server with hot reload..."
exec bun run --hot src/index.ts
