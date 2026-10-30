#!/bin/bash
# Sourced by patrol-integration-test-with-docker.sh: tunnels from FTL devices to this agent via a bore relay.
# Limits and debugging: docs/dev/ci-mobile-tunnels.md

BORE_HOST="${BORE_HOST:-bore.pub}"
# Seconds a dropped tunnel may keep failing to rebind before its supervisor gives up.
BORE_RECONNECT_WINDOW="${BORE_RECONNECT_WINDOW:-120}"

bore_port() {
    grep -oE "listening at ${BORE_HOST//./\\.}:[0-9]+" "$1" 2>/dev/null | head -1 | cut -d: -f2
}

bore_event() {
    echo "[bore-supervisor $(date -u '+%Y-%m-%dT%H:%M:%SZ')] $2" >> "$1"
}

# bore exits 0 without a log line when the relay drops the control connection; rebind the same public port.
supervise_bore() {
    local local_port=$1 log=$2 remote_port="" child="" status started down_since="" owner=$$
    trap - EXIT INT
    trap '[ -z "$child" ] || kill "$child" 2>/dev/null || true; exit 0' TERM
    while :; do
        started=$SECONDS
        bore local "$local_port" --to "$BORE_HOST" ${remote_port:+--port "$remote_port"} >> "$log" 2>&1 &
        child=$!
        status=0
        # Poll instead of waiting so a hard-killed script (no cleanup) does not leave a tunnel behind.
        while kill -0 "$child" 2>/dev/null; do
            if ! kill -0 "$owner" 2>/dev/null; then
                kill "$child" 2>/dev/null || true
                bore_event "$log" "script $owner is gone; stopping"
                exit 0
            fi
            sleep 2
        done
        wait "$child" || status=$?
        child=""
        [ -n "$remote_port" ] || remote_port=$(bore_port "$log")
        bore_event "$log" "exited status=$status after $(( SECONDS - started ))s (local $local_port, remote ${remote_port:-none})"
        # A client that ran 10s+ had a working tunnel, so the outage starts now.
        (( SECONDS - started < 10 )) || down_since=""
        down_since=${down_since:-$SECONDS}
        if (( SECONDS - down_since >= BORE_RECONNECT_WINDOW )); then
            bore_event "$log" "gave up: remote ${remote_port:-none} not rebound within ${BORE_RECONNECT_WINDOW}s"
            exit 1
        fi
        bore_event "$log" "reconnecting to $BORE_HOST:${remote_port:-any}"
        sleep 2
    done
}

# kill -0 with several PIDs succeeds while any one lives, so check each tunnel alone.
check_bore_supervisors() {
    local n dead=0
    for n in "${!BORE_SLOT_PIDS[@]}"; do
        kill -0 "${BORE_SLOT_PIDS[$n]}" 2>/dev/null || { echo "ERROR: bore tunnel slot$n is down (ci-logs/bore-slot$n.log)"; dead=1; }
    done
    kill -0 "$BORE_RESET_PID" 2>/dev/null || { echo "ERROR: bore reset tunnel is down (ci-logs/bore-reset.log)"; dead=1; }
    return "$dead"
}

# Any HTTP status through the relay proves the tunnel end to end; 000 means unreachable.
probe_bore_url() {
    local code
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$1" || true)
    [ -n "$code" ] && [ "$code" != "000" ]
}

# The reset server accepts a pool with FTL_SHARDS free backends, so only that many slot tunnels must answer.
probe_bore_tunnels() {
    local n reachable=0 slot_urls
    if ! probe_bore_url "$BORE_RESET_URL"; then
        echo "ERROR: reset tunnel $BORE_RESET_URL unreachable through $BORE_HOST"
        return 1
    fi
    IFS=, read -ra slot_urls <<< "$POOL_URLS"
    for n in "${!slot_urls[@]}"; do
        if probe_bore_url "${slot_urls[$n]}"; then
            reachable=$(( reachable + 1 ))
        else
            echo "WARN: slot$n tunnel ${slot_urls[$n]} unreachable through $BORE_HOST (backend dropped from the pool, or the relay dropped it)"
        fi
    done
    if (( reachable < FTL_SHARDS )); then
        echo "ERROR: only $reachable of ${#slot_urls[@]} slot tunnels answer through $BORE_HOST, FTL needs $FTL_SHARDS"
        return 1
    fi
}

# One row per tunnel: which relay ports dropped, whether they came back, how much traffic they carried.
bore_summary() {
    local log name
    {
        echo "tunnel  remote  connections  conn_errors  exits  gave_up"
        for log in "$CI_LOGS"/bore-slot*.log "$BORE_RESET_LOG"; do
            [ -f "$log" ] || continue
            name=$(basename "$log" .log)
            printf '%-7s %-7s %-12s %-12s %-6s %s\n' "${name#bore-}" "$(bore_port "$log")" \
                "$(grep -c 'new connection' "$log")" \
                "$(grep -c 'connection exited with error' "$log")" \
                "$(grep -c 'bore-supervisor.*exited' "$log")" \
                "$(grep -q 'gave up' "$log" && echo yes || echo no)"
        done
    } | tee "$CI_LOGS/bore-summary.txt"
}
