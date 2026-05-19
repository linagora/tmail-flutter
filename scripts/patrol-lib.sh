#!/bin/bash
# Shared utilities sourced by patrol test scripts.
# Provides: portable ms timestamps, phase timing, Docker lifecycle helpers, HTML report generation.
#
# Callers must set BACKEND_DIR before sourcing if it differs from the default.
# Callers must define LOG_FILE and REPORT_FILE before calling patrol_finalize_report.

BACKEND_DIR="${BACKEND_DIR:-backend-docker}"

# --- Timing ---

# Portable millisecond timestamp — macOS stock date lacks %3N.
_now_ms() {
  if date +%s%3N 2>/dev/null | grep -qE '^[0-9]+$'; then
    date +%s%3N
  else
    python3 -c 'import time; print(int(time.time() * 1000))'
  fi
}

_PHASE_LOG=()
_ABSOLUTE_TS_LOG=()
SCRIPT_START=$(_now_ms)

_record_phase() {
  local name=$1 start_ms=$2 end_ms elapsed
  end_ms=$(_now_ms)
  elapsed=$(( end_ms - start_ms ))
  _PHASE_LOG+=("${name}=${elapsed}")
  echo "[SCRIPT_TIMING] ${name}=${elapsed}ms"
}

_record_phase_ms() {
  local name=$1 elapsed=$2
  _PHASE_LOG+=("${name}=${elapsed}")
  echo "[SCRIPT_TIMING] ${name}=${elapsed}ms"
}

# Record an absolute wall-clock timestamp (ms since epoch) for a named event.
# Used to correlate shell-side timing with server-side [EVENT] timestamps.
_record_abs_ts() {
  local name=$1 ts_ms=$2
  _ABSOLUTE_TS_LOG+=("${name}=${ts_ms}")
  echo "[SCRIPT_ABS_TS] ${name}=${ts_ms}"
}

# --- Docker lifecycle ---

patrol_docker_cleanup() {
  local _T
  _T=$(_now_ms)
  (cd "$BACKEND_DIR" && docker compose down) || true
  _record_phase "docker_cleanup" "$_T"
}

# Generates JWT keys under $BACKEND_DIR if they do not already exist.
patrol_jwt_keygen() {
  local _T
  _T=$(_now_ms)
  if [[ ! -f "$BACKEND_DIR/jwt_privatekey" ]]; then
    echo "Generating keys for tmail-backend..."
    openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -out "$BACKEND_DIR/jwt_privatekey"
    openssl rsa -in "$BACKEND_DIR/jwt_privatekey" -pubout -out "$BACKEND_DIR/jwt_publickey"
    _record_phase "jwt_keygen" "$_T"
  else
    echo "[SCRIPT_TIMING] jwt_keygen=0ms (keys already exist)"
    _PHASE_LOG+=("jwt_keygen=0")
  fi
}

# Patches jmap.properties with the correct public URLs for this environment.
# Usage: patrol_patch_jmap_urls <basic_url> <websocket_url>
patrol_patch_jmap_urls() {
  local basic_url=$1 ws_url=$2
  sed -i '' "s|url.prefix=.*|url.prefix=$basic_url|" "$BACKEND_DIR/jmap.properties"
  sed -i '' "s|websocket.url.prefix=.*|websocket.url.prefix=$ws_url|" "$BACKEND_DIR/jmap.properties"
}

# Starts Docker Compose and waits until JAMES reports it has started.
# Usage: patrol_docker_startup [service]
# If [service] is omitted, all services are started.
patrol_docker_startup() {
  local service="${1:-}" _T
  _T=$(_now_ms)
  if [[ -n "$service" ]]; then
    (cd "$BACKEND_DIR" && docker compose up -d "$service")
  else
    (cd "$BACKEND_DIR" && docker compose up -d)
  fi
  until (cd "$BACKEND_DIR" && docker compose logs tmail-backend | grep -i "JAMES server started"); do
    echo "Waiting for tmail-backend to start..."
    sleep 2
  done
  _record_phase "docker_startup" "$_T"
}

patrol_initial_provisioning() {
  local _T
  _T=$(_now_ms)
  docker exec tmail-backend /root/conf/integration_test/provisioning.sh >/dev/null 2>&1
  _record_phase "initial_provisioning" "$_T"
}

# --- Report generation ---

# Prints timing summary, merges logs, generates HTML report.
# Usage: patrol_finalize_report <log_file> <report_file> [reset_server_log]
patrol_finalize_report() {
  local log_file=$1 report_file=$2 reset_server_log="${3:-}"
  local script_end script_total
  script_end=$(_now_ms)
  script_total=$(( script_end - SCRIPT_START ))

  echo ""
  echo "[SCRIPT_TIMING_SUMMARY] total=${script_total}ms"
  for entry in "${_PHASE_LOG[@]}"; do
    echo "  [SCRIPT_TIMING_DETAIL] ${entry}ms"
  done

  {
    echo "[SCRIPT_TIMING_SUMMARY] total=${script_total}ms"
    for entry in "${_PHASE_LOG[@]}"; do
      echo "[SCRIPT_TIMING_DETAIL] ${entry}ms"
    done
    for entry in "${_ABSOLUTE_TS_LOG[@]+"${_ABSOLUTE_TS_LOG[@]}"}"; do
      echo "[SCRIPT_ABS_TS_DETAIL] ${entry}"
    done
    [[ -n "$reset_server_log" && -f "$reset_server_log" ]] && cat "$reset_server_log"
    [[ -n "${_PATROL_OUTPUT_FILE:-}" && -f "$_PATROL_OUTPUT_FILE" ]] && cat "$_PATROL_OUTPUT_FILE"
  } > "$log_file"
  rm -f "${_PATROL_OUTPUT_FILE:-}"

  echo "Generating HTML timing report..."
  if python3 scripts/patrol-timing-report.py "$log_file" "$report_file" 2>/dev/null; then
    echo "Report: $report_file"
    open "$report_file" 2>/dev/null || true
  else
    echo "Report generation failed — check: pip install plotly jinja2"
  fi
}

# Runs patrol test with stdout monitoring to split timing into patrol_build vs patrol_run.
# "Executing tests of" in patrol host output marks the build→execution boundary.
# Usage: patrol_run_timed <patrol_args...>
# Sets _PATROL_EXIT to the patrol exit code.
patrol_run_timed() {
  local _TIMING_TMP _T_PATROL _T_PATROL_END _TEST_START
  _TIMING_TMP=$(mktemp)
  _PATROL_OUTPUT_FILE=$(mktemp)
  _T_PATROL=$(_now_ms)
  _PATROL_EXIT=0

  patrol test "$@" 2>&1 | tee "$_PATROL_OUTPUT_FILE" | while IFS= read -r _LINE; do
    printf '%s\n' "$_LINE"
    if [[ "$_LINE" == *"Executing tests of"* ]]; then
      if ! grep -q "^test_start=" "$_TIMING_TMP" 2>/dev/null; then
        local _ts
        _ts=$(_now_ms)
        printf 'test_start=%s\n' "$_ts" >> "$_TIMING_TMP"
        # Absolute wall-clock timestamp when patrol execution phase begins.
        # Stored for correlation with server-side [EVENT] timestamps in the report.
        printf 'patrol_run_start_ts=%s\n' "$_ts" >> "$_TIMING_TMP"
      fi
    fi
  done || _PATROL_EXIT=$?

  _T_PATROL_END=$(_now_ms)
  _TEST_START=$(grep "^test_start=" "$_TIMING_TMP" 2>/dev/null | head -1 | cut -d= -f2) || true
  _PATROL_RUN_START_TS=$(grep "^patrol_run_start_ts=" "$_TIMING_TMP" 2>/dev/null | head -1 | cut -d= -f2) || true
  rm -f "$_TIMING_TMP"

  if [[ -n "${_TEST_START:-}" ]]; then
    _record_phase_ms "patrol_build" "$(( _TEST_START - _T_PATROL ))"
    _record_phase_ms "patrol_run"   "$(( _T_PATROL_END - _TEST_START ))"
    [[ -n "${_PATROL_RUN_START_TS:-}" ]] && _record_abs_ts "patrol_run_start" "$_PATROL_RUN_START_TS"
    _record_abs_ts "patrol_run_end" "$_T_PATROL_END"
  else
    _record_phase_ms "test_run" "$(( _T_PATROL_END - _T_PATROL ))"
  fi
}
