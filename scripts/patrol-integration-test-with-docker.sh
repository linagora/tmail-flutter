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

SCRIPT_STARTED=$SECONDS
timing() {
    echo "[timing $(date -u '+%Y-%m-%dT%H:%M:%SZ')] +$(( SECONDS - SCRIPT_STARTED ))s $*"
}

ROOT_DIR="$PWD"
CI_LOGS="$ROOT_DIR/ci-logs"
mkdir -p "$CI_LOGS"
# Per-run paths: /tmp is host-wide, a neighbor job must never read our tunnel ports.
RESET_SERVER_LOG="$CI_LOGS/backend-reset-server.log"
BORE_RESET_LOG="$CI_LOGS/bore-reset.log"

FTL_SHARDS="${FTL_SHARDS:-4}"
POOL_SIZE="${POOL_SIZE:-6}"
if ! [[ "$FTL_SHARDS" =~ ^[1-9][0-9]*$ && "$POOL_SIZE" =~ ^[1-9][0-9]*$ ]] || [ "$FTL_SHARDS" -gt "$POOL_SIZE" ] || [ "$POOL_SIZE" -gt 16 ]; then
    echo "ERROR: FTL_SHARDS ($FTL_SHARDS) and POOL_SIZE ($POOL_SIZE) must be positive integers with FTL_SHARDS <= POOL_SIZE <= 16."
    exit 1
fi

timing "agent backend wait start"
bash "$ROOT_DIR/scripts/ci-wait-agent-backend-free.sh"
timing "agent backend wait end"

PATROL_BUILD_PID=""
BACKEND_TEARDOWN_PID=""
BACKEND_TORN_DOWN=0
BORE_SLOT_PIDS=()
BORE_RESET_PID=""
RESET_SERVER_PID=""

stop_services() {
    local pid
    for pid in "${BORE_SLOT_PIDS[@]}" "$BORE_RESET_PID" "$RESET_SERVER_PID"; do
        [ -z "$pid" ] || kill "$pid" 2>/dev/null || true
    done
    # Reap services before releasing the backend lock.
    for pid in "${BORE_SLOT_PIDS[@]}" "$BORE_RESET_PID" "$RESET_SERVER_PID"; do
        [ -z "$pid" ] || wait "$pid" 2>/dev/null || true
    done
    BORE_SLOT_PIDS=()
    BORE_RESET_PID=""
    RESET_SERVER_PID=""
}

cleanup() {
    local exit_code=$?
    echo "Cleaning up..."
    if [ -n "$PATROL_BUILD_PID" ]; then
        # Stop the whole build group before releasing the backend lock.
        kill -- "-$PATROL_BUILD_PID" 2>/dev/null || true
        wait "$PATROL_BUILD_PID" 2>/dev/null || true
    fi
    if [ -n "$BACKEND_TEARDOWN_PID" ]; then
        kill -- "-$BACKEND_TEARDOWN_PID" 2>/dev/null || true
        wait "$BACKEND_TEARDOWN_PID" 2>/dev/null || true
    fi
    stop_services
    if [ "$BACKEND_TORN_DOWN" -ne 1 ]; then
        bash "$ROOT_DIR/scripts/ci-backend-teardown.sh" "$CI_LOGS/backend.log"
    fi
    timing "cleanup end (exit $exit_code)"
    exit "$exit_code"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# ── bore tunnel setup ─────────────────────────────────────────────────────────
echo "Starting bore tunnels..."
timing "bore tunnels start"
# One tunnel per backend slot; the reset server hands each lease the slot's public URL.
for (( n = 0; n < POOL_SIZE; n++ )); do
    nohup bore local $(( 8100 + n )) --to bore.pub > "$CI_LOGS/bore-slot$n.log" 2>&1 &
    BORE_SLOT_PIDS+=($!)
done
nohup bore local 9999 --to bore.pub > "$BORE_RESET_LOG" 2>&1 &
BORE_RESET_PID=$!

bore_port() {
    grep -oE 'listening at bore\.pub:[0-9]+' "$1" 2>/dev/null | head -1 | cut -d: -f2
}

echo "Waiting for bore tunnels..."
BORE_RESET_PORT=""
BORE_SLOT_PORTS=()
deadline=$(( SECONDS + 40 ))
until [ -n "$BORE_RESET_PORT" ] && [ "${#BORE_SLOT_PORTS[@]}" -eq "$POOL_SIZE" ]; do
    if (( SECONDS >= deadline )); then
        echo "ERROR: bore tunnels did not connect within 40s."
        for f in "$CI_LOGS"/bore-slot*.log "$BORE_RESET_LOG"; do
            echo "--- $f ---"
            cat "$f"
        done
        exit 1
    fi

    BORE_RESET_PORT=$(bore_port "$BORE_RESET_LOG")
    BORE_SLOT_PORTS=()
    for (( n = 0; n < POOL_SIZE; n++ )); do
        port=$(bore_port "$CI_LOGS/bore-slot$n.log")
        [ -z "$port" ] || BORE_SLOT_PORTS+=("$port")
    done

    sleep 1
done

BORE_RESET_URL="http://bore.pub:$BORE_RESET_PORT"
POOL_URLS=$(python3 -c 'import sys; print(",".join(f"http://bore.pub:{p}" for p in sys.argv[1:]))' "${BORE_SLOT_PORTS[@]}")
# Slots are numbered by their local port, so keep tunnel order = slot order.
echo "bore backend tunnels:  $POOL_URLS"
echo "bore reset tunnel:     $BORE_RESET_URL"
timing "bore tunnels ready"

export BOB="bob"
export ALICE="alice"
export DOMAIN="example.com"
export BASIC_AUTH_URL="${POOL_URLS%%,*}"
export RESET_PORT=9999

# Job control gives cleanup a process group containing Patrol and its build children.
set -m
(
    trap - EXIT INT TERM
    timing "patrol CLI check start"
    if command -v patrol >/dev/null 2>&1 && [ "$(CI=true PATROL_ANALYTICS_ENABLED=false patrol --version 2>/dev/null)" = 'patrol_cli v4.3.1' ]; then
        echo "Using installed patrol_cli 4.3.1."
    else
        dart pub global activate patrol_cli 4.3.1
    fi
    timing "patrol CLI ready"
    timing "Patrol/Gradle build start (android-arm64)"
    build_started=$SECONDS
    # Patrol runs config-only itself and forwards inherited JVM options to both Gradle builds.
    GRADLE_OPTS="${GRADLE_OPTS:-} -Dorg.gradle.project.target-platform=android-arm64" \
        patrol build android -v \
        --tags=android \
        --dart-define=USERNAME="$BOB" \
        --dart-define=PASSWORD="$BOB" \
        --dart-define=ADDITIONAL_MAIL_RECIPIENT="$ALICE@$DOMAIN" \
        --dart-define=BASIC_AUTH_EMAIL="$BOB@$DOMAIN" \
        --dart-define=BASIC_AUTH_URL="$BASIC_AUTH_URL" \
        --dart-define=RESET_SERVER_URL="$BORE_RESET_URL"
    timing "Patrol/Gradle build end ($(( SECONDS - build_started ))s)"
) &
PATROL_BUILD_PID=$!
set +m

# ── Backend ──────────────────────────────────────────────────────────────────

timing "backend setup start"
cd backend-docker

openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out jwt_privatekey 2>/dev/null
openssl rsa -in jwt_privatekey -pubout -out jwt_publickey 2>/dev/null

# The reset server starts a fresh backend container per lease slot.
cd ..
timing "backend keys generated"

echo "Starting backend reset server on port $RESET_PORT (logs: $RESET_SERVER_LOG)..."
BACKUP_ZIP="$PWD/provisioning/integration_test/backup.zip" \
    RESET_PORT="$RESET_PORT" \
    POOL_SIZE="$POOL_SIZE" \
    POOL_URLS="$POOL_URLS" \
    POOL_MIN_FREE="$FTL_SHARDS" \
    POOL_LOG_DIR="$CI_LOGS" \
    WORK_DIR="$ROOT_DIR" \
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

timing "backend reset server ready"
deadline=$(( SECONDS + 300 ))
until grep -q "pool ready" "$RESET_SERVER_LOG"; do
    if ! kill -0 "$RESET_SERVER_PID" 2>/dev/null || (( SECONDS >= deadline )); then
        echo "ERROR: backend pool did not become ready:"
        tail -n 50 "$RESET_SERVER_LOG"
        exit 1
    fi
    sleep 1
done
timing "backend pool ready"

echo "google cli auth"
timing "gcloud auth start"
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
timing "gcloud auth end"

wait "$PATROL_BUILD_PID"
PATROL_BUILD_PID=""
kill -0 "${BORE_SLOT_PIDS[@]}" "$BORE_RESET_PID" "$RESET_SERVER_PID"

# AGP 8.12 puts the APKs under android/app/build, not ../build
APP_APK=$(find build android/app/build -path '*/apk/debug/app-debug.apk' 2>/dev/null | head -1)
TEST_APK=$(find build android/app/build -path '*/apk/androidTest/debug/app-debug-androidTest.apk' 2>/dev/null | head -1)
if [ ! -f "$APP_APK" ] || [ ! -f "$TEST_APK" ]; then
    echo "ERROR: APKs not found (app: '$APP_APK', test: '$TEST_APK'). APKs present:"
    find . -name '*.apk' -not -path './.pub-cache/*'
    exit 1
fi

FTL_OUTPUT="$CI_LOGS/firebase-test-lab.log"
# BUILD_TAG holds the job name, so PR jobs with the same build number do not share a GCS dir.
RESULTS_DIR="jenkins/$(printf '%s' "${BUILD_TAG:-local-$(date +%s)}" | tr -c 'A-Za-z0-9._-' '_')"

# Seed the results path so result discovery does not depend on gcloud output.
printf 'Results GCS path: gs://%s/%s/\n' "$RESULTS_BUCKET" "$RESULTS_DIR" | tee "$FTL_OUTPUT"

timing "FTL start ($FTL_SHARDS shards)"
ftl_started=$SECONDS
set +e
gcloud beta firebase test android run \
    --project="$FIREBASE_PROJECT_ID" \
    --type instrumentation \
    --app "$APP_APK" \
    --test "$TEST_APK" \
    --device model=MediumPhone.arm,version=34 \
    --timeout 60m \
    --use-orchestrator \
    --num-uniform-shards="$FTL_SHARDS" \
    --environment-variables clearPackageData=true \
    --no-record-video \
    --no-performance-metrics \
    --num-flaky-test-attempts=0 \
    --results-bucket="gs://$RESULTS_BUCKET" \
    --results-dir="$RESULTS_DIR" \
    2>&1 | tee -a "$FTL_OUTPUT"
TEST_EXIT_CODE=${PIPESTATUS[0]}
set -e
timing "FTL end ($(( SECONDS - ftl_started ))s, exit $TEST_EXIT_CODE)"
SERVICES_EXIT_CODE=0
kill -0 "${BORE_SLOT_PIDS[@]}" "$BORE_RESET_PID" "$RESET_SERVER_PID" || SERVICES_EXIT_CODE=$?
stop_services

# Devices have finished, so backend teardown can overlap artifact downloads.
set -m
(
    trap - EXIT INT TERM
    timing "backend teardown start"
    bash "$ROOT_DIR/scripts/ci-backend-teardown.sh" "$CI_LOGS/backend.log"
    timing "backend teardown end"
) &
BACKEND_TEARDOWN_PID=$!
set +m

timing "result download start"
DOWNLOAD_EXIT_CODE=0
bash "$ROOT_DIR/scripts/ci-ftl-download-results.sh" "$FTL_OUTPUT" "$RESULTS_DIR" "$FIREBASE_PROJECT_ID" "$FTL_SHARDS" || DOWNLOAD_EXIT_CODE=$?
timing "result download end (exit $DOWNLOAD_EXIT_CODE)"

wait "$BACKEND_TEARDOWN_PID"
BACKEND_TEARDOWN_PID=""
BACKEND_TORN_DOWN=1

[ "$TEST_EXIT_CODE" -ne 0 ] && exit "$TEST_EXIT_CODE"
[ "$SERVICES_EXIT_CODE" -ne 0 ] && exit "$SERVICES_EXIT_CODE"
exit "$DOWNLOAD_EXIT_CODE"
