#!/bin/bash
set -e

DOMAIN="${MONGO_TLS_DOMAIN:-mongo.makerverse.app}"
CERT_DEST="/data/configdb/certs"
MONGO_PEM="${CERT_DEST}/mongo.pem"

echo "Using TLS domain: $DOMAIN"
mkdir -p "$CERT_DEST"

# Locate correct certificate directory dynamically
CERT_SRC=$(find /caddy-certs -type d -name "$DOMAIN" | head -n 1)

if [ -z "$CERT_SRC" ]; then
  echo "❌ ERROR: Certificate path for domain '$DOMAIN' not found in /caddy-certs"
  exit 1
fi

echo "Found cert path: $CERT_SRC"

# Wait up to 120 seconds for the cert files
WAIT_TIMEOUT=120
WAIT_INTERVAL=2
WAITED=0

while [ ! -f "$CERT_SRC/$DOMAIN.crt" ] || [ ! -f "$CERT_SRC/$DOMAIN.key" ]; do
  if [ "$WAITED" -ge "$WAIT_TIMEOUT" ]; then
    echo "❌ ERROR: Timed out waiting for certificates for $DOMAIN"
    exit 1
  fi
  echo "Waiting for Caddy certificates for $DOMAIN... (${WAITED}s elapsed)"
  sleep "$WAIT_INTERVAL"
  WAITED=$((WAITED + WAIT_INTERVAL))
done

echo "✅ Certificates found, combining into PEM..."
cp "$CERT_SRC/$DOMAIN.crt" "$CERT_DEST/cert.pem"
cp "$CERT_SRC/$DOMAIN.key" "$CERT_DEST/privkey.pem"
cat "$CERT_DEST/cert.pem" "$CERT_DEST/privkey.pem" > "$MONGO_PEM"
chmod 600 "$MONGO_PEM"

echo "🚀 Starting MongoDB with TLS for $DOMAIN..."
exec mongod \
  --tlsMode requireTLS \
  --tlsCertificateKeyFile "$MONGO_PEM" \
  --auth \
  --bind_ip_all
