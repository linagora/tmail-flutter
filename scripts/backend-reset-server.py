#!/usr/bin/env python3
"""
HTTP server that resets tmail-backend to a clean provisioned state.

The Android emulator reaches the host at 10.0.2.2, so Dart tests call:
  POST http://10.0.2.2:9999/reset

Reset strategy: call the James WebAdmin `deleteData` action for every test
user, which runs all DeleteUserDataTaskStep hooks (clearing mailboxes, emails,
JMAP settings, and identities) without restarting the JVM. User accounts are
preserved so provisioning.sh can re-import mailboxes/emails immediately.
The AddUser calls in provisioning.sh print "already exists" errors but are
harmless — everything else (CreateMailbox, ImportEml, team-mailboxes, quota)
proceeds normally.

Returns 200 OK only once all deleteData tasks complete and provisioning
finishes, so Dart tearDown blocks until the next test can safely start.

Environment variables:
  RESET_PORT      Listening port (default: 9999)
  WORK_DIR        Repo root, used to resolve the compose file (default: cwd)
  WEBADMIN_PORT   James WebAdmin port inside the container (default: 8000)
"""

import http.server
import json
import os
import subprocess
import sys
import time
from typing import Optional

RESET_PORT    = int(os.environ.get("RESET_PORT", "9999"))
WEBADMIN_PORT = int(os.environ.get("WEBADMIN_PORT", "8000"))
PROVISION     = "/root/conf/integration_test/provisioning.sh"

# Must match the users created by provisioning.sh
_TEST_USERS = [
    "alice@example.com",
    "bob@example.com",
    "brian@example.com",
    "charlotte@example.com",
    "david@example.com",
    "emma@example.com",
]

_TEST_DOMAIN = "example.com"


def _run(cmd: list[str], check: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=check, capture_output=True, text=True)


def _webadmin(method: str, path: str) -> dict:
    """Call the James WebAdmin API inside the container via docker exec curl."""
    result = _run([
        "docker", "exec", "tmail-backend",
        "curl", "-s", "-X", method,
        f"http://localhost:{WEBADMIN_PORT}{path}",
    ])
    if not result.stdout.strip():
        return {}
    return json.loads(result.stdout)


def _delete_domain_data(domain: str) -> str:
    """Submit a deleteData task for all users of a domain and return the task ID."""
    resp = _webadmin("POST", f"/domains/{domain}?action=deleteData")
    print(f"[reset-server] delete_domain_data response: {resp}", flush=True)
    task_id = resp.get("taskId")
    if not task_id:
        raise RuntimeError(f"deleteData for domain {domain} returned no taskId: {resp}")
    return task_id

def _delete_user_vault() -> Optional[str]:
    """Submit a vault deletion task for one user. Returns taskId or None if vault is empty."""
    resp = _webadmin("DELETE", f"/deletedMessages?scope=expired")
    print(f"[reset-server] delete_user_vault response: {resp}", flush=True)
    return resp.get("taskId")


def _wait_for_task(task_id: str, timeout: float = 30.0) -> None:
    """Poll until the James task reaches completed or failed status."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        resp = _webadmin("GET", f"/tasks/{task_id}")
        status = resp.get("status")
        if status == "completed":
            print(f"[reset-server] task completed with response: {resp}", flush=True)
            return
        if status == "failed":
            raise RuntimeError(f"James task {task_id} failed: {resp}")
        time.sleep(0.2)
    raise TimeoutError(f"James task {task_id} did not complete within {timeout}s")


def reset_backend() -> None:
    print("[reset-server] Deleting user data for all test users...", flush=True)

    task_id = _delete_domain_data(_TEST_DOMAIN)
    _wait_for_task(task_id)
    print(f"[reset-server]   cleared {_TEST_DOMAIN}", flush=True)

    # Clear deleted message vault for all test users.
    print("[reset-server] Clearing deleted message vault for all test users...", flush=True)
    task_id = _delete_user_vault()
    _wait_for_task(task_id)
    print(f"[reset-server]   cleared vault for {_TEST_DOMAIN}", flush=True)

    print("[reset-server] Re-running provisioning...", flush=True)
    # AddUser calls will log "already exists" errors — expected and harmless.
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
