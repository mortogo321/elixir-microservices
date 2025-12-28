#!/bin/sh
set -e

# Store hash of mix.exs for change detection
MIX_HASH_FILE="/tmp/.mix-hash"

get_mix_hash() {
  md5sum /app/mix.exs 2>/dev/null | cut -d' ' -f1
}

# Initial setup
echo "📦 Installing dependencies..."
mix deps.get

# Run migrations if ecto is available
if mix help ecto.migrate > /dev/null 2>&1; then
  echo "🗄️  Running database setup..."
  mix ecto.setup || mix ecto.migrate || true
fi

# Store initial hash
get_mix_hash > "$MIX_HASH_FILE"

# Watch for mix.exs changes in background
(
  while true; do
    sleep 3
    CURRENT_HASH=$(get_mix_hash)
    STORED_HASH=$(cat "$MIX_HASH_FILE" 2>/dev/null || echo "")

    if [ "$CURRENT_HASH" != "$STORED_HASH" ]; then
      echo "📦 mix.exs changed, fetching dependencies..."
      mix deps.get
      echo "$CURRENT_HASH" > "$MIX_HASH_FILE"
      echo "✅ Dependencies updated!"
    fi
  done
) &

# Start the application
echo "🚀 Starting ${APP_NAME:-app}..."
if mix help phx.server > /dev/null 2>&1; then
  exec mix phx.server
else
  exec mix run --no-halt
fi
