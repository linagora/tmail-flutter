#!/usr/bin/env python3
"""
HTTP server that resets tmail-backend to a clean provisioned state.

The Android emulator reaches the host at 10.0.2.2, so Dart tests call:
  POST http://10.0.2.2:9999/reset

Reset strategy: call the James WebAdmin `deleteData` action for every test
user, which runs all DeleteUserDataTaskStep hooks (clearing mailboxes, emails,
JMAP settings, and identities) without restarting the JVM. User accounts are
preserved so the mailbox restore can re-import data immediately.

After deletion, bob's mailbox is restored from backup.zip via the
WebAdmin restore endpoint, then team mailboxes and quota are recreated.

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
BACKUP_ZIP    = "/root/conf/integration_test/backup.zip"

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

_BOB_USER = "bob@example.com"


def _run(cmd: list[str], check: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=check, capture_output=True, text=True)


def _webadmin(method: str, path: str, data: str | None = None) -> dict:
    """Call the James WebAdmin API inside the container via docker exec curl."""
    cmd = [
        "curl", "-s", "-X", method,
        f"http://localhost:{WEBADMIN_PORT}{path}",
    ]
    if data is not None:
        cmd += ["-d", data, "-H", "Content-Type: application/json"]
    result = _run(cmd)
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
    """Submit a vault deletion task. Returns taskId or None if vault is empty."""
    resp = _webadmin("DELETE", f"/deletedMessages?scope=expired")
    print(f"[reset-server] delete_user_vault response: {resp}", flush=True)
    task_id = resp.get("taskId")
    if not task_id:
        raise RuntimeError(f"delete vault for domain {domain} returned no taskId: {resp}")
    return task_id


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


def _restore_user_backup(user_email: str) -> str:
    """Submit a restore task for a user's mailbox backup. Returns taskId."""
    result = _run([
        "docker", "exec", "tmail-backend",
        "curl", "-s", "-X", "POST",
        f"http://localhost:{WEBADMIN_PORT}/users/{user_email}/mailboxes?task=restore&force=true",
        "--data-binary", f"@{BACKUP_ZIP}",
        "-H", "Content-Type: application/zip"
    ])
    resp = json.loads(result.stdout) if result.stdout.strip() else {}
    task_id = resp.get("taskId")
    if not task_id:
        raise RuntimeError(f"restore for {user_email} returned no taskId: {resp}")
    return task_id


def _recreate_team_mailboxes() -> None:
    """Recreate team mailbox and members after data deletion."""
    _webadmin("PUT", f"/domains/{_TEST_DOMAIN}/team-mailboxes/bob-guests")
    _webadmin("PUT", f"/domains/{_TEST_DOMAIN}/team-mailboxes/bob-guests/members/bob@{_TEST_DOMAIN}?role=member")
    _webadmin("PUT", f"/domains/{_TEST_DOMAIN}/team-mailboxes/bob-guests/members/alice@{_TEST_DOMAIN}?role=member")


def _set_quota() -> None:
    """Set quota for bob after data deletion."""
    _webadmin("PUT", f"/quota/users/bob@{_TEST_DOMAIN}",
              data=json.dumps({"count": 200, "size": 50000000}))


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

    # Restore mailbox backup for bob.
    print(f"[reset-server]   restoring {_BOB_USER}...", flush=True)
    task_id = _restore_user_backup(_BOB_USER)
    _wait_for_task(task_id)
    print(f"[reset-server]   restored {_BOB_USER}", flush=True)

    # Recreate team mailbox and quota (these are not restored by mailbox restore).
    print("[reset-server] Recreating team mailboxes and quota...", flush=True)
    _recreate_team_mailboxes()
    _set_quota()

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
