#!/bin/bash
set -e

# OSC_HOSTNAME → NEXTAUTH_URL and NEXTAUTH_TRUSTED_HOSTS
if [ -n "$OSC_HOSTNAME" ]; then
  export NEXTAUTH_URL="https://$OSC_HOSTNAME"
  export NEXTAUTH_TRUSTED_HOSTS="${OSC_HOSTNAME}"
elif [ -z "$NEXTAUTH_URL" ]; then
  # Fallback for local/non-OSC deployments
  export NEXTAUTH_URL="http://localhost:${PORT:-8080}"
fi

# Ensure PORT is set (OSC provides this; Next.js respects PORT env var)
export PORT="${PORT:-8080}"

# Validate required environment variables
if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is required (PostgreSQL connection string)"
  exit 1
fi

if [ -z "$CLICKHOUSE_URL" ]; then
  echo "ERROR: CLICKHOUSE_URL is required (e.g. http://clickhouse-host:8123)"
  exit 1
fi

if [ -z "$CLICKHOUSE_MIGRATION_URL" ]; then
  echo "ERROR: CLICKHOUSE_MIGRATION_URL is required (e.g. clickhouse://clickhouse-host:9000)"
  exit 1
fi

if [ -z "$NEXTAUTH_SECRET" ]; then
  echo "ERROR: NEXTAUTH_SECRET is required (generate with: openssl rand -base64 32)"
  exit 1
fi

if [ -z "$SALT" ]; then
  echo "ERROR: SALT is required (generate with: openssl rand -base64 32)"
  exit 1
fi

if [ -z "$ENCRYPTION_KEY" ]; then
  echo "ERROR: ENCRYPTION_KEY is required (generate with: openssl rand -hex 32)"
  exit 1
fi

# Set DIRECT_URL for migrations if not already set
export DIRECT_URL="${DIRECT_URL:-$DATABASE_URL}"

# Set default S3/storage bucket names if not already provided
# These default to "langfuse" bucket (can be overridden by user)
export LANGFUSE_S3_EVENT_UPLOAD_BUCKET="${LANGFUSE_S3_EVENT_UPLOAD_BUCKET:-langfuse}"
export LANGFUSE_S3_MEDIA_UPLOAD_BUCKET="${LANGFUSE_S3_MEDIA_UPLOAD_BUCKET:-langfuse}"
export LANGFUSE_S3_BATCH_EXPORT_BUCKET="${LANGFUSE_S3_BATCH_EXPORT_BUCKET:-langfuse}"

# Run PostgreSQL migrations unless disabled
if [ "$LANGFUSE_AUTO_POSTGRES_MIGRATION_DISABLED" != "true" ]; then
  echo "Running PostgreSQL migrations..."
  cd /app
  prisma db execute --url "$DIRECT_URL" --file "./packages/shared/scripts/cleanup.sql"
  prisma migrate deploy --schema=./packages/shared/prisma/schema.prisma
fi

# Run ClickHouse migrations unless disabled
if [ "$LANGFUSE_AUTO_CLICKHOUSE_MIGRATION_DISABLED" != "true" ]; then
  echo "Running ClickHouse migrations..."
  cd /app/packages/shared
  sh ./clickhouse/scripts/up.sh
  cd /app
fi

# Start the worker in the background
echo "Starting Langfuse worker..."
cd /opt/langfuse-worker
node worker/dist/index.js &
WORKER_PID=$!

echo "Worker started (PID: $WORKER_PID)"

# Return to web directory and start the web service in the foreground
cd /app
echo "Starting Langfuse web on port $PORT..."
exec "$@"
