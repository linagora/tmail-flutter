#!/usr/bin/env python3
"""
HTTP server that resets tmail-backend to a clean provisioned state.

The Android emulator reaches the host at 10.0.2.2, so Dart tests call:
  POST http://10.0.2.2:9999/reset

On each reset the server restarts the container (wiping all in-memory
James state) and re-runs provisioning.sh to restore users/mailboxes/emails.
Returns 200 OK only once James reports "server started" and provisioning
completes, so Dart tearDown blocks until the next test can safely start.

Note: docker commit cannot capture JVM heap state, so the memory-based
backend must always be restored by re-running provisioning after restart.

Environment variables:
  RESET_PORT   Listening port (default: 9999)
  WORK_DIR     Repo root, used to resolve the compose file (default: cwd)
"""

import http.server
import os
import subprocess
import sys
import time
from datetime import datetime, timezone

RESET_PORT = int(os.environ.get("RESET_PORT", "9999"))
WORK_DIR   = os.environ.get("WORK_DIR", os.getcwd())
COMPOSE    = os.path.join(WORK_DIR, "backend-docker", "docker-compose.yaml")
PROVISION  = "/root/conf/integration_test/provisioning.sh"


def _run(cmd: list[str], check: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=check, capture_output=True, text=True)


def _backend_ready_since(since: str) -> bool:
    # Only inspect logs produced after `since` to avoid matching the previous run's startup message.
    result = _run(["docker", "logs", "--since", since, "tmail-backend"])
    combined = result.stdout + result.stderr
    return "JAMES server started" in combined


def reset_backend() -> None:
    print("[reset-server] Restarting tmail-backend...", flush=True)
    restart_time = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    _run(["docker", "compose", "-f", COMPOSE, "restart", "tmail-backend"], check=True)

    deadline = time.time() + 120
    while time.time() < deadline:
        if _backend_ready_since(restart_time):
            break
        time.sleep(2)
    else:
        raise TimeoutError("tmail-backend did not start within 120 seconds")

    print("[reset-server] Re-running provisioning...", flush=True)
    _run(["docker", "exec", "tmail-backend", PROVISION], check=True)
    print("[reset-server] Reset complete.", flush=True)


class ResetHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/reset":
            self.send_response(404)
            self.end_headers()
            return

        try:
            reset_backend()
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"ok")
        except Exception as exc:
            print(f"[reset-server] ERROR: {exc}", file=sys.stderr, flush=True)
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(exc).encode())

    def log_message(self, fmt, *args):
        print(f"[reset-server] {self.address_string()} - {fmt % args}", flush=True)


if __name__ == "__main__":
    server = http.server.HTTPServer(("0.0.0.0", RESET_PORT), ResetHandler)
    print(f"[reset-server] Listening on port {RESET_PORT}", flush=True)
    server.serve_forever()
