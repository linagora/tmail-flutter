#!/bin/bash

## Pre-requisites
# Install ngrok
# Install patrol CLI
# Open android emulator

# Stoping previous environment if any
killall ngrok || true
cd backend-docker
docker compose down || true
cd ..

# Forward traffic to tmail-backend
ngrok http http://localhost:80 --log=stdout >/dev/null &
until [[ $(curl localhost:4040/api/status | jq -r ".status") == "online" ]]; do
    echo "Waiting for ngrok to connect..."
    sleep 2
done

export BASIC_AUTH_URL=$(curl -s localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

cd backend-docker

# Generate keys for tmail backend
echo "Generating keys for tmail-backend..."
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey

# Replace content of jmap.properties with url.prefix=$BASIC_AUTH_URL
sed -i '' "s|url.prefix=.*|url.prefix=$BASIC_AUTH_URL|" jmap.properties

echo "Starting services and adding users..."
docker compose up -d
# Wait till the service is started to add users
until (docker compose logs tmail-backend | grep -i "JAMES server started"); do
    echo "Waiting for tmail-backend to start..."
    sleep 2
done
export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"
docker exec tmail-backend james-cli AddUser "$BOB@$DOMAIN" "$BOB"
docker exec tmail-backend james-cli AddUser "$ALICE@$DOMAIN" "$ALICE"

cd ..

echo "Building the app and running tests..."
flutter build apk --config-only
patrol test -v \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL"

# Clean up
echo "Cleaning up test environment..."
killall ngrok
cd backend-docker
docker compose down
cd ..