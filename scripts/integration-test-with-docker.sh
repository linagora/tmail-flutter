#!/bin/bash

set -eux

cd backend-docker

openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey

docker compose up -d
until (docker compose logs tmail-backend | grep -i "JAMES server started"); do
    echo "Waiting for tmail-backend to start..."
    sleep 2
done

export TEST_USER22_NAME="testuser22"
export TEST_USER22_PASSWORD="testuser22"
export TEST_USER21_NAME="testuser21"
export TEST_USER21_PASSWORD="testuser21"
docker exec -it tmail-backend james-cli AddUser $TEST_USER22_NAME@lin-saas.dev $TEST_USER22_PASSWORD
docker exec -it tmail-backend james-cli AddUser $TEST_USER21_NAME@lin-saas.dev $TEST_USER21_PASSWORD
cd ..

ngrok http http://localhost:80 --log=stdout >/dev/null &
until [[ $(curl localhost:4040/api/status | jq -r ".status") == "online" ]]; do
    echo "Waiting for ngrok to connect..."
    sleep 2
done

export BASIC_AUTH_URL=$(curl -s localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
# adb reverse tcp:80 tcp:80
patrol test \
    --dart-define=USERNAME="$TEST_USER22_NAME" \
    --dart-define=PASSWORD="$TEST_USER22_PASSWORD" \
    --dart-define=HOST_URL="trashed" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$TEST_USER21_NAME@lin-saas.dev" \
    --dart-define=BASIC_AUTH_EMAIL="$TEST_USER22_NAME@lin-saas.dev" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" || true
killall ngrok

cd backend-docker
docker compose down
