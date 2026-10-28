#!/bin/bash
# Waits while a job without the agent lock still holds the backend; exits 1 after 45 min.

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

# An aborted job whose workspace is gone leaves no one to remove its backend.
# Owner is <workspace-root>/<job>/backend-docker; the visible root proves we see the same filesystem.
remove_orphaned_backend() {
    local id owner job_dir
    read -r id owner < <(docker inspect tmail-backend --format '{{.Id}} {{ index .Config.Labels "com.docker.compose.project.working_dir" }}' 2>/dev/null) || return 0
    [ -n "$id" ] && [ -n "$owner" ] || return 0
    job_dir=$(dirname "$owner")
    if [ -d "$(dirname "$job_dir")" ] && [ ! -e "$job_dir" ]; then
        echo "Removing tmail-backend orphaned by deleted workspace $job_dir"
        docker rm -f "$id" >/dev/null || true
    fi
}

# Wait while a job without the agent lock still holds the backend.
deadline=$(( SECONDS + 2700 ))
remove_orphaned_backend
while agent_busy; do
    if (( SECONDS >= deadline )); then
        echo "ERROR: agent backend still busy after 45 min:"
        ss -Hltnp "$BACKEND_PORTS_FILTER" || true
        docker ps -a --filter 'name=^tmail-backend$' --format '{{.Names}} {{.Status}} {{.Label "com.docker.compose.project.working_dir"}}' || true
        exit 1
    fi
    echo "Agent backend busy (ports 80/8000/9999 or tmail-backend); waiting..."
    sleep 15
    remove_orphaned_backend
done
