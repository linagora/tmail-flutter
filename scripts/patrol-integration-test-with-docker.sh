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

echo "Installing patrol CLI..."
dart pub global activate patrol_cli 4.3.1

# ── bore tunnel setup ─────────────────────────────────────────────────────────
echo "Starting bore tunnels..."
nohup bore local 80 --to bore.pub > /tmp/bore-backend.log 2>&1 &
BORE_BACKEND_PID=$!
nohup bore local 9999 --to bore.pub > /tmp/bore-reset.log 2>&1 &
BORE_RESET_PID=$!

echo "Waiting for bore tunnels..."
BORE_BACKEND_PORT=""
BORE_RESET_PORT=""
deadline=$(( SECONDS + 20 ))
until [ -n "$BORE_BACKEND_PORT" ] && [ -n "$BORE_RESET_PORT" ]; do
    if (( SECONDS >= deadline )); then
        echo "ERROR: bore tunnels did not connect within 20s."
        echo "--- backend log ---"
        cat /tmp/bore-backend.log
        echo "--- reset log ---"
        cat /tmp/bore-reset.log
        exit 1
    fi

    BORE_BACKEND_PORT=$(python3 -c "
import os, re
path = '/tmp/bore-backend.log'
if os.path.exists(path):
    with open(path) as f:
        for line in f:
            m = re.search(r'listening at bore\.pub:(\d+)', line)
            if m:
                print(m.group(1))
                break
" 2>/dev/null)

    BORE_RESET_PORT=$(python3 -c "
import os, re
path = '/tmp/bore-reset.log'
if os.path.exists(path):
    with open(path) as f:
        for line in f:
            m = re.search(r'listening at bore\.pub:(\d+)', line)
            if m:
                print(m.group(1))
                break
" 2>/dev/null)

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

RESET_SERVER_LOG="/tmp/backend-reset-server.log"
echo "Starting backend reset server on port $RESET_PORT (logs: $RESET_SERVER_LOG)..."
BACKUP_ZIP="$PWD/provisioning/integration_test/backup.zip" \
    RESET_PORT="$RESET_PORT" \
    python3 scripts/backend-reset-server.py > "$RESET_SERVER_LOG" 2>&1 &
RESET_SERVER_PID=$!

cleanup() {
    echo "Cleaning up..."
    kill "$BORE_BACKEND_PID" 2>/dev/null || true
    kill "$BORE_RESET_PID" 2>/dev/null || true
    kill "$RESET_SERVER_PID" 2>/dev/null || true
    cd backend-docker
    docker compose down --remove-orphans 2>/dev/null
    cd ..
}
trap cleanup EXIT

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

echo "start firebase tests"
FTL_OUTPUT=$(mktemp)
RESULTS_DIR="jenkins/${BUILD_NUMBER:-local-$(date +%s)}"

set +e
gcloud firebase test android run \
    --type instrumentation \
    --app build/app/outputs/apk/debug/app-debug.apk \
    --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk \
    --device model=MediumPhone.arm,version=34 \
    --timeout 60m \
    --use-orchestrator \
    --environment-variables clearPackageData=true \
    --no-record-video \
    --results-dir="$RESULTS_DIR" \
    2>&1 | tee "$FTL_OUTPUT"
TEST_EXIT_CODE=${PIPESTATUS[0]}
set -e

echo "Downloading test results from Firebase Test Lab..."

# Strategy 1: parse gs:// URL directly from gcloud output
GCS_PATH=$(grep -oP "gs://[^\s\"'\[\]]+" "$FTL_OUTPUT" | head -1)

# Strategy 2: parse GCS browser URL and convert to gs://
if [ -z "$GCS_PATH" ]; then
    GCS_BROWSER=$(grep -oP "console\.(cloud|developers)\.google\.com/storage/browser/\K[^\s\"'\[\]]+" "$FTL_OUTPUT" | head -1)
    if [ -n "$GCS_BROWSER" ]; then
        GCS_PATH="gs://${GCS_BROWSER}"
        echo "Extracted GCS path from console URL: $GCS_PATH"
    fi
fi

# Strategy 3: fallback to listing project buckets
if [ -z "$GCS_PATH" ]; then
    echo "GCS path not in gcloud output, trying project bucket lookup..."
    FTL_BUCKET=$(gsutil ls -p "$FIREBASE_PROJECT_ID" 2>/dev/null \
        | grep 'test-lab' | head -1 || true)
    if [ -n "$FTL_BUCKET" ]; then
        GCS_PATH="${FTL_BUCKET}${RESULTS_DIR}"
    fi
fi

if [ -n "$GCS_PATH" ]; then
    mkdir -p ftl-results
    echo "Results GCS path: $GCS_PATH"
    gsutil ls -r "${GCS_PATH}" 2>/dev/null \
        | grep 'test_result_.*\.xml$' \
        | while read -r xml_file; do
            echo "  $xml_file"
            gsutil cp "$xml_file" ftl-results/ 2>/dev/null || true
          done || true

    if ls ftl-results/test_result_*.xml >/dev/null 2>&1; then
        echo "Downloaded $(ls ftl-results/test_result_*.xml | wc -l) result file(s)"
    else
        echo "Warning: no test_result XML files found at $GCS_PATH"
    fi
else
    echo "Warning: could not determine GCS results path"
fi

exit $TEST_EXIT_CODE