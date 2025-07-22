#!/bin/bash

set -e

CERT_PATH="/caddy-certs/acme-v02.api.letsencrypt.org-directory/mongo.example.com"
MONGO_PEM="/tmp/mongo.pem"

# Wait for cert files to exist
while [ ! -f "$CERT_PATH/cert.pem" ] || [ ! -f "$CERT_PATH/privkey.pem" ]; do
    echo "Waiting for Caddy certificates..."
    sleep 2
done

echo "Combining cert.pem and privkey.pem into mongo.pem"
cat "$CERT_PATH/cert.pem" "$CERT_PATH/privkey.pem" > "$MONGO_PEM"
chmod 600 "$MONGO_PEM"

echo "Starting MongoDB with TLS on port 27017 (host:27018)..."
exec mongod \
--tlsMode requireTLS \
--tlsCertificateKeyFile "$MONGO_PEM" \
--auth \
--bind_ip 127.0.0.1


