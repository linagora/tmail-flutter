#!/bin/bash
# Usage: ci-web-boot-stall-probe.sh <patrol-console-log> <dump-file> <dev-server-url>
# Every tab boot logs one "DDC is about to load 1/2 scripts" first and one "Starting application" last.
# While a boot stays pending past BOOT_STALL_SECONDS, dump the dev server and socket state
# so a stalled page.goto shows whether the server starved or dwds dropped the connection.
# A failed boot never logs "Starting application", so the count can stay above 0: keep dumping at a fixed rate.
PATROL_LOG="$1"
DUMP_FILE="$2"
SERVER_URL="$3"
BOOT_STALL_SECONDS="${BOOT_STALL_SECONDS:-90}"
DUMP_EVERY_SECONDS="${DUMP_EVERY_SECONDS:-120}"
POLL_SECONDS="${POLL_SECONDS:-10}"
SERVER_PORT="${SERVER_URL##*:}"

count_log() {
    LC_ALL=C grep -acE "$1" "$PATROL_LOG" 2>/dev/null || true
}

pending_boots() {
    local started finished
    started=$(count_log 'DDC is about to load 1/2 scripts')
    finished=$(count_log 'Starting application from main method')
    echo $(( ${started:-0} - ${finished:-0} ))
}

dump_state() {
    local pages src
    {
        echo "=== boot stall $(date -u +%FT%TZ): $1 boot(s) pending > ${BOOT_STALL_SECONDS}s ==="
        echo "--- boot markers: started=$(count_log 'DDC is about to load 1/2 scripts') connected=$(count_log 'App connection established') running=$(count_log 'Starting application from main method') isolate-exits=$(count_log 'Isolate exit handled')"
        echo "--- last dwds/boot lines"
        LC_ALL=C grep -aE 'DDC is about to load|App connection established|Starting application from main method|Isolate exit handled|DevHandler|Playwright: .*(rror|ailed)' "$PATROL_LOG" | tail -15 | cut -c1-240
        echo "--- load"
        uptime
        free -m
        echo "--- processes by cpu"
        ps -eo pid,ppid,stat,etime,pcpu,pmem,rss,comm --sort=-pcpu | head -25
        echo "--- browser and dev server processes"
        echo "chrome processes: $(pgrep -fc 'chrom.*(headless|--remote-debugging)')"
        ps -o pid,stat,etime,pcpu,rss,args -p "$(pgrep -f 'flutter_tools.*snapshot.*run' | paste -sd, -)" 2>/dev/null | cut -c1-200
        echo "--- dev server sockets (port ${SERVER_PORT}) by state"
        ss -tan "( sport = :${SERVER_PORT} )" 2>/dev/null | awk 'NR>1 {n[$1]++} END {for (s in n) print s, n[s]}'
        echo "--- dev server sockets with queued bytes (Recv-Q Send-Q)"
        ss -tan "( sport = :${SERVER_PORT} )" 2>/dev/null | awk 'NR>1 && ($2>0 || $3>0)' | head -40
        echo "--- dev server responsiveness"
        curl -sS -m 20 -o /dev/null -w 'GET main.dart.js http=%{http_code} connect=%{time_connect}s ttfb=%{time_starttransfer}s total=%{time_total}s bytes=%{size_download}\n' "${SERVER_URL}/main.dart.js"
        curl -sS -m 20 -o /dev/null -w 'GET / http=%{http_code} total=%{time_total}s\n' "${SERVER_URL}/"
        echo "--- tabs still booting (CDP)"
        if [ -n "${WEB_RUNNER_DIR:-}" ]; then
            pages=$(timeout 40 node "$(dirname "$0")/ci-web-boot-stall-pages.js" "$WEB_RUNNER_DIR" 2>&1) || true
            printf '%s\n' "$pages"
        else
            echo "SKIP CDP: WEB_RUNNER_DIR unset"
        fi
        echo "--- pending and last script responsiveness"
        while IFS= read -r src; do
            [ -n "$src" ] || continue
            curl -gsS -m 20 -o /dev/null -w 'http=%{http_code} connect=%{time_connect}s ttfb=%{time_starttransfer}s total=%{time_total}s bytes=%{size_download} ' -- "$src" || true
            echo "$src"
        done < <(printf '%s\n' "$pages" | sed -n 's/^\(PENDING\|LAST_SCRIPT\) //p' | awk '!seen[$0]++' | head -20) || true
        echo "--- last finished test before the stall"
        LC_ALL=C grep -a 'PatrolBinding: finished test' "$PATROL_LOG" | tail -1 | cut -c1-240 || true
    } >> "$DUMP_FILE" 2>&1
}

pending_since=0
last_dump=0
while sleep "$POLL_SECONDS"; do
    now=$(date +%s)
    pending=$(pending_boots)
    if [ "$pending" -le 0 ]; then
        pending_since=0
        continue
    fi
    [ "$pending_since" -gt 0 ] || pending_since="$now"
    if [ $((now - pending_since)) -ge "$BOOT_STALL_SECONDS" ] &&
        [ $((now - last_dump)) -ge "$DUMP_EVERY_SECONDS" ]; then
        dump_state "$pending"
        last_dump="$now"
    fi
done
