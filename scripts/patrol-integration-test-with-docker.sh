#!/bin/bash

# Install ngrok
echo "Installing ngrok..."
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null &&
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list &&
    sudo apt update && sudo apt install ngrok

# Install patrol CLI
echo "Installing patrol CLI..."
dart pub global activate patrol_cli
flutter build apk --config-only

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
# and websocket.url.prefix=ws${BASIC_AUTH_URL:4}
sed -i "s|url.prefix=.*|url.prefix=$BASIC_AUTH_URL|" jmap.properties
sed -i '' "s|websocket.url.prefix=.*|websocket.url.prefix=ws${BASIC_AUTH_URL:4}|" jmap.properties

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

docker exec tmail-backend ./root/conf/integration_test/provisioning.sh

cd ..

echo "Building the app and running tests..."
flutter build apk --config-only
patrol build android -v \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL"
gcloud firebase test android run \
    --type instrumentation \
    --app build/app/outputs/apk/debug/app-debug.apk \
    --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
    --device 'model=oriole,version=33,locale=en,orientation=portrait' \
    --timeout 10m \
    --use-orchestrator \
    --environment-variables clearPackageData=true
