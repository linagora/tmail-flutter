#!/bin/bash
set -euo pipefail
# Throwaway spike: single backend on host port 80, patrol profile run on the emulator.
cd backend-docker
[[ -f jwt_privatekey ]] || {
  openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey
  openssl rsa -in jwt_privatekey -pubout -out jwt_publickey
}
sed -i "s|url.prefix=.*|url.prefix=http://10.0.2.2|" jmap.properties
sed -i "s|websocket.url.prefix=.*|websocket.url.prefix=ws://10.0.2.2|" jmap.properties
docker compose up -d tmail-backend
until docker compose logs tmail-backend | grep -qi "JAMES server started"; do sleep 2; done
docker exec tmail-backend /root/conf/integration_test/provisioning.sh >/dev/null 2>&1
cd ..
RESET_PORT=9999 python3 scripts/backend-reset-server.py > /tmp/backend-reset-server.log 2>&1 &
RESET_PID=$!
trap 'kill "$RESET_PID" 2>/dev/null || true' EXIT
export PATH="$PATH:$HOME/.pub-cache/bin"
dart pub global activate patrol_cli 4.3.1
export ANDROID_TEST_BUILD_TYPE=profile
for target in integration_test/tests/spike/vm_service_spike_test.dart; do
  timeout 900 patrol test --profile --device emulator-5554 --target "$target" \
    --dart-define=USERNAME=bob --dart-define=PASSWORD=bob \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT=alice@example.com \
    --dart-define=BASIC_AUTH_EMAIL=bob@example.com \
    --dart-define=BASIC_AUTH_URL=http://10.0.2.2 \
    --dart-define=RESET_SERVER_URL=http://10.0.2.2:9999
done
