#!/bin/bash
# Sourced by ci-web-boot-stall-probe.sh. Linux /proc sampling of browser renderer and GPU processes.

# "<cpu ticks> <voluntary switches> <involuntary switches>" of one process, or "unreadable".
# The switch counters are the main thread's: /proc/<pid>/status reports the thread-group leader.
proc_counters() {
    local stat status fields vol nonvol
    if ! stat=$(cat "/proc/$1/stat" 2>/dev/null) || ! status=$(cat "/proc/$1/status" 2>/dev/null); then
        echo unreadable
        return
    fi
    # Drop "pid (comm) ": comm may hold spaces. Fields after it start at state, so utime/stime are 12 and 13.
    read -r -a fields <<< "${stat##*) }"
    vol=$(awk '/^voluntary_ctxt_switches:/ {print $2}' <<< "$status")
    nonvol=$(awk '/^nonvoluntary_ctxt_switches:/ {print $2}' <<< "$status")
    echo $(( fields[11] + fields[12] )) "${vol:-0}" "${nonvol:-0}"
}

# One line per thread (capped): a sleeping thread and a spinning one differ in state and wchan.
proc_threads() {
    local task stat
    for task in /proc/"$1"/task/*; do
        [ -d "$task" ] || continue
        stat=$(cat "$task/stat" 2>/dev/null) || continue
        stat=${stat##*) }
        printf 'THREAD %s tid=%s comm=%s state=%s wchan=%s\n' \
            "$1" "${task##*/}" "$(cat "$task/comm" 2>/dev/null)" "${stat%% *}" "$(cat "$task/wchan" 2>/dev/null)"
    done | head -40
}

# All pids are sampled together across one interval. A denied or exited pid is reported, never counted as idle.
renderer_thread_state() {
    local before pid old new
    [ "$#" -gt 0 ] || return 0
    before=$(for pid in "$@"; do echo "$pid $(proc_counters "$pid")"; done)
    sleep "${PROC_SAMPLE_SECONDS:-2}"
    for pid in "$@"; do
        old=$(awk -v p="$pid" '$1 == p {print $2, $3, $4}' <<< "$before")
        new=$(proc_counters "$pid")
        if [ "${old%% *}" = unreadable ] || [ "$new" = unreadable ]; then
            echo "PROC $pid unreadable|exited"
            continue
        fi
        read -r c0 v0 n0 <<< "$old"
        read -r c1 v1 n1 <<< "$new"
        echo "PROC $pid cpu_delta=$((c1 - c0)) main_vol_delta=$((v1 - v0)) main_nonvol_delta=$((n1 - n0)) interval=${PROC_SAMPLE_SECONDS:-2}s"
        proc_threads "$pid"
    done
}
