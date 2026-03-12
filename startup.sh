#!/bin/bash
# ============================================================
# Sentinel Gateway — First-Boot Startup Script
# Fetches .env from GCP instance metadata and starts the gateway.
# ============================================================
set -euo pipefail

GATEWAY_DIR="/opt/sentinel-gateway"
LOG="/var/log/sentinel-startup.log"

exec > "$LOG" 2>&1
echo "[$(date)] Sentinel Gateway startup script running..."

# ----------------------------------------------------------
# 1. Fetch .env from GCP instance metadata
# ----------------------------------------------------------
ENV_DATA=$(curl -sf \
  -H "Metadata-Flavor: Google" \
  "http://metadata.google.internal/computeMetadata/v1/instance/attributes/sentinel-env" || true)

if [ -z "$ENV_DATA" ]; then
  echo "[$(date)] WARNING: No sentinel-env metadata found. Skipping .env write."
else
  echo "$ENV_DATA" > "$GATEWAY_DIR/.env"
  chmod 600 "$GATEWAY_DIR/.env"
  echo "[$(date)] .env written from metadata ($(wc -l < "$GATEWAY_DIR/.env") lines)"
fi

# ----------------------------------------------------------
# 2. Inject ACME email into traefik.yml (if configured)
# ----------------------------------------------------------
if [ -f "$GATEWAY_DIR/.env" ]; then
  ACME_EMAIL=$(grep -oP '^SENTINEL_ACME_EMAIL=\K.*' "$GATEWAY_DIR/.env" || true)
  if [ -n "$ACME_EMAIL" ]; then
    sed -i "s/SENTINEL_ACME_EMAIL_PLACEHOLDER/$ACME_EMAIL/g" "$GATEWAY_DIR/traefik.yml"
    echo "[$(date)] ACME email set to: $ACME_EMAIL"
  else
    echo "[$(date)] No ACME email configured, using placeholder (SSL disabled)"
  fi
fi

# ----------------------------------------------------------
# 3. Ensure acme directory exists with correct permissions
# ----------------------------------------------------------
mkdir -p "$GATEWAY_DIR/acme"
touch "$GATEWAY_DIR/acme/acme.json"
chmod 600 "$GATEWAY_DIR/acme/acme.json"

# ----------------------------------------------------------
# 4. Start the gateway
# ----------------------------------------------------------
cd "$GATEWAY_DIR"
docker compose up -d

echo "[$(date)] Sentinel Gateway started successfully."
echo "[$(date)] Containers:"
docker compose ps
