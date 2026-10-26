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

# Ports the backend (80, 8000) and reset server (9999) bind on the host.
BACKEND_PORTS_FILTER='( sport = :80 or sport = :8000 or sport = :9999 )'
command -v ss >/dev/null || { echo "ERROR: ss not found; cannot check agent ports."; exit 1; }

# Busy if a port is bound, the container is running, or docker cannot answer.
# A stopped leftover shares nothing; compose recreates it.
agent_busy() {
    ss -Hltn "$BACKEND_PORTS_FILTER" | grep -q . && return 0
    local ids
    ids=$(docker ps -q --filter 'name=^tmail-backend$') || return 0
    [ -n "$ids" ]
}

# Wait while a job without the agent lock still holds the backend.
deadline=$(( SECONDS + 2700 ))
while agent_busy; do
    if (( SECONDS >= deadline )); then
        echo "ERROR: agent backend still busy after 45 min:"
        ss -Hltnp "$BACKEND_PORTS_FILTER" || true
        docker ps -a --filter 'name=^tmail-backend$' --format '{{.Names}} {{.Status}} {{.Label "com.docker.compose.project.working_dir"}}' || true
        exit 1
    fi
    echo "Agent backend busy (ports 80/8000/9999 or tmail-backend); waiting..."
    sleep 15
done

cleanup() {
    echo "Cleaning up..."
    kill "$BORE_BACKEND_PID" 2>/dev/null || true
    kill "$BORE_RESET_PID" 2>/dev/null || true
    kill "$RESET_SERVER_PID" 2>/dev/null || true
    # Reap them so their ports are free before the agent lock is released.
    wait "$BORE_BACKEND_PID" "$BORE_RESET_PID" "$RESET_SERVER_PID" 2>/dev/null || true
    cd "$ROOT_DIR/backend-docker" || return 0
    owner=$(docker inspect tmail-backend --format '{{ index .Config.Labels "com.docker.compose.project.working_dir" }}' 2>/dev/null || true)
    if [ -n "$owner" ] && [ "$(realpath "$owner" 2>/dev/null)" = "$(pwd -P)" ]; then
        docker compose logs --no-color --timestamps > "$CI_LOGS/backend.log" 2>&1 || true
        docker compose down --remove-orphans 2>/dev/null || true
    else
        echo "tmail-backend not owned by this workspace (${owner:-none}); skip teardown."
    fi
    cd "$ROOT_DIR"
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
        | grep -E '(test_result_.*\.xml|/logcat)$' \
        | while read -r gcs_file; do
            echo "  $gcs_file"
            # Keep the GCS sub-path so per-device files do not overwrite each other.
            rel="${gcs_file#"${GCS_PATH%/}"/}"
            [ "$rel" = "$gcs_file" ] && rel="${gcs_file#gs://}"
            mkdir -p "ftl-results/$(dirname "$rel")"
            gsutil cp "$gcs_file" "ftl-results/$rel" 2>/dev/null || true
          done || true

    xml_count=$(find ftl-results -name 'test_result_*.xml' | wc -l)
    if [ "$xml_count" -gt 0 ]; then
        echo "Downloaded $xml_count result file(s)"
    else
        echo "Warning: no test_result XML files found at $GCS_PATH"
    fi
else
    echo "Warning: could not determine GCS results path"
fi

exit $TEST_EXIT_CODE