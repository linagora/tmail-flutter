#!/bin/bash
# CI integration test script.
# Runs Patrol tests on Firebase Test Lab via bore tunnels.
#
# Required environment variables:
#   GOOGLE_APPLICATION_CREDENTIALS   Path to GCP service account JSON key
#   FIREBASE_PROJECT_ID              GCP project ID
#
# Usage:
#   ./scripts/patrol-integration-test-with-docker.sh
set -e

ROOT_DIR="$PWD"
CI_LOGS="$ROOT_DIR/ci-logs"
mkdir -p "$CI_LOGS"
# Per-run paths: /tmp is host-wide, a neighbor job must never read our tunnel ports.
RESET_SERVER_LOG="$CI_LOGS/backend-reset-server.log"
BORE_BACKEND_LOG="$CI_LOGS/bore-backend.log"
BORE_RESET_LOG="$CI_LOGS/bore-reset.log"

bash "$ROOT_DIR/scripts/ci-wait-agent-backend-free.sh"

cleanup() {
    echo "Cleaning up..."
    kill "$BORE_BACKEND_PID" 2>/dev/null || true
    kill "$BORE_RESET_PID" 2>/dev/null || true
    kill "$RESET_SERVER_PID" 2>/dev/null || true
    # Reap them so their ports are free before the agent lock is released.
    wait "$BORE_BACKEND_PID" "$BORE_RESET_PID" "$RESET_SERVER_PID" 2>/dev/null || true
    bash "$ROOT_DIR/scripts/ci-backend-teardown.sh" "$CI_LOGS/backend.log"
}
trap cleanup EXIT

echo "Installing patrol CLI..."
dart pub global activate patrol_cli 4.3.1

# ── bore tunnel setup ─────────────────────────────────────────────────────────
echo "Starting bore tunnels..."
nohup bore local 80 --to bore.pub > "$BORE_BACKEND_LOG" 2>&1 &
BORE_BACKEND_PID=$!
nohup bore local 9999 --to bore.pub > "$BORE_RESET_LOG" 2>&1 &
BORE_RESET_PID=$!

bore_port() {
    grep -oE 'listening at bore\.pub:[0-9]+' "$1" 2>/dev/null | head -1 | cut -d: -f2
}

echo "Waiting for bore tunnels..."
BORE_BACKEND_PORT=""
BORE_RESET_PORT=""
deadline=$(( SECONDS + 20 ))
until [ -n "$BORE_BACKEND_PORT" ] && [ -n "$BORE_RESET_PORT" ]; do
    if (( SECONDS >= deadline )); then
        echo "ERROR: bore tunnels did not connect within 20s."
        echo "--- backend log ---"
        cat "$BORE_BACKEND_LOG"
        echo "--- reset log ---"
        cat "$BORE_RESET_LOG"
        exit 1
    fi

    BORE_BACKEND_PORT=$(bore_port "$BORE_BACKEND_LOG")
    BORE_RESET_PORT=$(bore_port "$BORE_RESET_LOG")

    sleep 1
done

BORE_BACKEND_URL="http://bore.pub:$BORE_BACKEND_PORT"
BORE_RESET_URL="http://bore.pub:$BORE_RESET_PORT"
BORE_WS_URL="ws://bore.pub:$BORE_BACKEND_PORT"

echo "bore backend tunnel:   $BORE_BACKEND_URL"
echo "bore reset tunnel:     $BORE_RESET_URL"

# ── Backend ──────────────────────────────────────────────────────────────────

cd backend-docker

openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey 2>/dev/null
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey 2>/dev/null

sed -i.bak "s|url.prefix=.*|url.prefix=${BORE_BACKEND_URL}|" jmap.properties
sed -i.bak "s|websocket.url.prefix=.*|websocket.url.prefix=${BORE_WS_URL}|" jmap.properties

echo "Starting tmail-backend..."
docker compose up -d tmail-backend --quiet-pull
deadline=$(( SECONDS + 180 ))
until docker compose logs tmail-backend 2>/dev/null | grep -qi "JAMES server started"; do
    if (( SECONDS >= deadline )); then
        echo "tmail-backend did not start within 180s; recent logs:"
        docker compose logs --tail=200 tmail-backend
        exit 1
    fi
    echo "Waiting for tmail-backend..."
    sleep 2
done

export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"

docker exec tmail-backend /root/conf/integration_test/provisioning.sh >/dev/null 2>&1

cd ..

export BASIC_AUTH_URL="$BORE_BACKEND_URL"
export RESET_PORT=9999

echo "Starting backend reset server on port $RESET_PORT (logs: $RESET_SERVER_LOG)..."
BACKUP_ZIP="$PWD/provisioning/integration_test/backup.zip" \
    RESET_PORT="$RESET_PORT" \
    python3 scripts/backend-reset-server.py > "$RESET_SERVER_LOG" 2>&1 &
RESET_SERVER_PID=$!

deadline=$(( SECONDS + 15 ))
until grep -q 'Listening on port' "$RESET_SERVER_LOG"; do
    if ! kill -0 "$RESET_SERVER_PID" 2>/dev/null || (( SECONDS >= deadline )); then
        echo "ERROR: backend reset server did not start:"
        cat "$RESET_SERVER_LOG"
        exit 1
    fi
    sleep 1
done

echo "Running Patrol tests..."
flutter build apk --config-only --quiet
patrol build android -v \
    --tags=android \
    --dart-define=USERNAME="$BOB" \
    --dart-define=PASSWORD="$BOB" \
    --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
    --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
    --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" \
    --dart-define=RESET_SERVER_URL="$BORE_RESET_URL"

echo "google cli auth"
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
gcloud config set project "$FIREBASE_PROJECT_ID"

# AGP 8.12 puts the APKs under android/app/build, not ../build
APP_APK=$(find build android/app/build -path '*/apk/debug/app-debug.apk' 2>/dev/null | head -1)
TEST_APK=$(find build android/app/build -path '*/apk/androidTest/debug/app-debug-androidTest.apk' 2>/dev/null | head -1)
if [ ! -f "$APP_APK" ] || [ ! -f "$TEST_APK" ]; then
    echo "ERROR: APKs not found (app: '$APP_APK', test: '$TEST_APK'). APKs present:"
    find . -name '*.apk' -not -path './.pub-cache/*'
    exit 1
fi

echo "start firebase tests"
FTL_OUTPUT=$(mktemp)
# BUILD_TAG holds the job name, so PR jobs with the same build number do not share a GCS dir.
RESULTS_DIR="jenkins/$(printf '%s' "${BUILD_TAG:-local-$(date +%s)}" | tr -c 'A-Za-z0-9._-' '_')"

set +e
gcloud firebase test android run \
    --type instrumentation \
    --app "$APP_APK" \
    --test "$TEST_APK" \
    --device model=MediumPhone.arm,version=34 \
    --timeout 60m \
    --use-orchestrator \
    --environment-variables clearPackageData=true \
    --no-record-video \
    --results-bucket="gs://$RESULTS_BUCKET" \
    --results-dir="$RESULTS_DIR" \
    2>&1 | tee "$FTL_OUTPUT"
TEST_EXIT_CODE=${PIPESTATUS[0]}
set -e

bash "$ROOT_DIR/scripts/ci-ftl-download-results.sh" "$FTL_OUTPUT" "$RESULTS_DIR" "$FIREBASE_PROJECT_ID"

exit $TEST_EXIT_CODE