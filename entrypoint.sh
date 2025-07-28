#!/bin/bash
set -e

# Load env if not already loaded (Docker does this, but safe for manual runs too)
export $(grep -v '^#' /etc/environment | xargs 2>/dev/null) || true

# Use domain from env or fallback to default
DOMAIN="${MONGO_TLS_DOMAIN:-mongo.makerverse.app}"

CERT_SRC="/caddy-certs/acme-v02.api.letsencrypt.org-directory/$DOMAIN"
CERT_DEST="/data/configdb/certs"
MONGO_PEM="$CERT_DEST/mongo.pem"

mkdir -p "$CERT_DEST"

echo "Using TLS domain: $DOMAIN"

# Wait for cert files to exist
while [ ! -f "$CERT_SRC/$DOMAIN.crt" ] || [ ! -f "$CERT_SRC/$DOMAIN.key" ]; do
    echo "Waiting for Caddy certificates for $DOMAIN..."
    sleep 2
done

echo "Copying and combining certificates..."
cp "$CERT_SRC/$DOMAIN.crt" "$CERT_DEST/cert.pem"
cp "$CERT_SRC/$DOMAIN.key" "$CERT_DEST/privkey.pem"
cat "$CERT_DEST/cert.pem" "$CERT_DEST/privkey.pem" > "$MONGO_PEM"
chmod 600 "$MONGO_PEM"

echo "Starting MongoDB with TLS for domain $DOMAIN..."
exec mongod \
--tlsMode requireTLS \
--tlsCertificateKeyFile "$MONGO_PEM" \
--auth \
--bind_ip_all
