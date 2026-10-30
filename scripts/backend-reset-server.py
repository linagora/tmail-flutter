#!/usr/bin/env python3
"""
HTTP server that leases isolated tmail-backend containers and replaces them.

The device (emulator, browser or Firebase Test Lab) reaches the host at the
configured URL. Every test leases a backend, runs against it, and releases it:
  POST /lease    -> {token,url}; waits for a free backend
  POST /release  -> {token}; answers 202, the container is replaced in the background

Each slot is one container of backend-docker/docker-compose.pool.yaml, provisioned
like provisioning/integration_test/provisioning.sh, so a leased backend always holds
the pristine bob/alice data. The James memory server has no full reset (deleteData
keeps team mailbox contents, change history and quota counters), so release recreates
the container. A slot whose replacement fails twice is dropped from the pool.

Environment variables:
  RESET_PORT                Listening port (default: 9999)
  POOL_SIZE                 Number of slots (default: 4)
  POOL_URLS                 Comma-separated public JMAP base URL per slot, POOL_SIZE entries (required)
  POOL_MIN_FREE             Startup fails when fewer slots are free once the pool settles (default: 1)
  POOL_RECYCLE_CONCURRENCY  Containers booting at once (default: 2)
  POOL_JMAP_BASE_PORT       Host port of slot 0's JMAP; slot n uses base + n (default: 8100)
  POOL_WEBADMIN_BASE_PORT   Host port of slot 0's WebAdmin; slot n uses base + n (default: 8200)
  POOL_PROJECT              Compose project prefix (default: tmail-pool)
  POOL_JAVA_TOOL_OPTIONS    JVM options of the backend containers (default: small, fast-start heap)
  POOL_LOG_DIR              Directory of the per-slot backend logs (default: cwd)
  BOOT_TIMEOUT              Seconds a container may take to start (default: 180)
  LEASE_TTL                 Seconds after which an unreleased lease is reclaimed (default: 600)
  LEASE_TIMEOUT             Seconds a /lease waits for a free backend; under the client's 3 min (default: 150)
  POOL_READY_TIMEOUT        Seconds startup waits for POOL_MIN_FREE free slots (default: 300)
  WORK_DIR                  Repo root, used to resolve the compose file (default: cwd)
  BACKUP_ZIP                Path to backup.zip on the host (default: provisioning/... relative to WORK_DIR)
"""

import http.server
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import time
import uuid
from typing import Callable, Dict, List, Optional

RESET_PORT              = int(os.environ.get("RESET_PORT", "9999"))
POOL_SIZE               = int(os.environ.get("POOL_SIZE", "4"))
POOL_URLS               = [u.strip() for u in os.environ.get("POOL_URLS", "").split(",") if u.strip()]
POOL_MIN_FREE           = int(os.environ.get("POOL_MIN_FREE", "1"))
POOL_RECYCLE_CONCURRENCY = int(os.environ.get("POOL_RECYCLE_CONCURRENCY", "2"))
POOL_JMAP_BASE_PORT     = int(os.environ.get("POOL_JMAP_BASE_PORT", "8100"))
POOL_WEBADMIN_BASE_PORT = int(os.environ.get("POOL_WEBADMIN_BASE_PORT", "8200"))
POOL_PROJECT            = os.environ.get("POOL_PROJECT", "tmail-pool")
# Measured on the memory image: ~4 s boot + provisioning and ~400 MiB per container.
POOL_JAVA_TOOL_OPTIONS  = os.environ.get("POOL_JAVA_TOOL_OPTIONS", "-Xmx512m -XX:TieredStopAtLevel=1 -XX:+UseSerialGC -Xshare:auto")
BOOT_TIMEOUT            = float(os.environ.get("BOOT_TIMEOUT", "180"))
LEASE_TTL               = float(os.environ.get("LEASE_TTL", "600"))
LEASE_TIMEOUT           = float(os.environ.get("LEASE_TIMEOUT", "150"))
POOL_READY_TIMEOUT      = float(os.environ.get("POOL_READY_TIMEOUT", "300"))
WORK_DIR                = os.environ.get("WORK_DIR", os.getcwd())
POOL_LOG_DIR            = os.environ.get("POOL_LOG_DIR", os.getcwd())
BACKUP_ZIP              = os.environ.get(
    "BACKUP_ZIP",
    os.path.join(WORK_DIR, "provisioning", "integration_test", "backup.zip")
)

_TEST_DOMAIN = "example.com"

# Must match provisioning/integration_test/provisioning.sh
_TEST_USERS = ["alice", "bob", "brian", "charlotte", "david", "emma"]

_COMPOSE = os.path.join(WORK_DIR, "backend-docker", "docker-compose.pool.yaml")
_JMAP_PROPERTIES = os.path.join(WORK_DIR, "backend-docker", "jmap.properties")

_stopping = threading.Event()
_recycle_slots = threading.BoundedSemaphore(POOL_RECYCLE_CONCURRENCY)
_slot_dir = None
_slot_lock = threading.Lock()
_stop_lock = threading.Lock()
_stopped = False


def _run(cmd: List[str], check: bool = False, env: Optional[dict] = None) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=check, capture_output=True, text=True, env=env)


def _webadmin(port: int, method: str, path: str, data: Optional[str] = None) -> dict:
    """Call the James WebAdmin API via HTTP on localhost:port."""
    cmd = ["curl", "-s", "-X", method, f"http://localhost:{port}{path}"]
    if data is not None:
        cmd += ["-d", data, "-H", "Content-Type: application/json"]
    result = _run(cmd)
    if not result.stdout.strip():
        return {}
    return json.loads(result.stdout)


def _webadmin_ok(port: int, method: str, path: str, data: Optional[str] = None, ok: tuple = (200, 204)) -> None:
    """Call WebAdmin and raise unless the HTTP status is one of `ok`."""
    cmd = ["curl", "-s", "-o", os.devnull, "-w", "%{http_code}", "-X", method,
           f"http://localhost:{port}{path}"]
    if data is not None:
        cmd += ["-d", data, "-H", "Content-Type: application/json"]
    code = _run(cmd).stdout.strip()
    if not code.isdigit() or int(code) not in ok:
        raise RuntimeError(f"{method} {path} answered {code or 'nothing'}")


def _wait_for_task(port: int, task_id: str, timeout: float = 30.0) -> None:
    """Poll until the James task reaches completed or failed status."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        status = _webadmin(port, "GET", f"/tasks/{task_id}").get("status")
        if status == "completed":
            return
        if status == "failed":
            raise RuntimeError(f"James task {task_id} failed")
        time.sleep(0.1)
    raise TimeoutError(f"James task {task_id} did not complete within {timeout}s")


def _restore_user_backup(port: int, user_email: str) -> str:
    """Submit a restore task for a user's mailbox backup. Returns taskId."""
    result = _run([
        "curl", "-s", "-X", "POST",
        f"http://localhost:{port}/users/{user_email}/mailboxes?task=restore&force=true",
        "--data-binary", f"@{BACKUP_ZIP}",
        "-H", "Content-Type: application/zip"
    ])
    resp = json.loads(result.stdout) if result.stdout.strip() else {}
    task_id = resp.get("taskId")
    if not task_id:
        raise RuntimeError(f"restore for {user_email} returned no taskId: {resp}")
    return task_id


def provision(port: int) -> None:
    """Create the test users and data on a fresh backend (mirrors provisioning.sh)."""
    _webadmin_ok(port, "PUT", f"/domains/{_TEST_DOMAIN}")
    for user in _TEST_USERS:
        _webadmin_ok(port, "PUT", f"/users/{user}@{_TEST_DOMAIN}",
                     data=json.dumps({"password": user}), ok=(200, 204, 409))
    _wait_for_task(port, _restore_user_backup(port, f"bob@{_TEST_DOMAIN}"))
    team = f"/domains/{_TEST_DOMAIN}/team-mailboxes/bob-guests"
    _webadmin_ok(port, "PUT", team)
    for member in ("bob", "alice"):
        _webadmin_ok(port, "PUT", f"{team}/members/{member}@{_TEST_DOMAIN}?role=member")
    _webadmin_ok(port, "PUT", f"/quota/users/bob@{_TEST_DOMAIN}",
                 data=json.dumps({"count": 200, "size": 50000000}))


def _slot_env(n: int) -> Dict[str, str]:
    """Compose variables of slot n; its jmap.properties advertises the slot's public URL."""
    global _slot_dir
    with _slot_lock:
        if _slot_dir is None:
            # Under backend-docker: a Docker daemon outside this agent sees the workspace, not its /tmp.
            _slot_dir = tempfile.mkdtemp(prefix="tmail-pool-", dir=os.path.dirname(_JMAP_PROPERTIES))
        props = os.path.join(_slot_dir, f"jmap-slot{n}.properties")
        if not os.path.exists(props):
            url = POOL_URLS[n]
            ws = "ws" + url[len("http"):]  # http -> ws, https -> wss
            with open(_JMAP_PROPERTIES) as src:
                text = re.sub(r"^url\.prefix=.*$", lambda _: f"url.prefix={url}", src.read(), flags=re.M)
            text = re.sub(r"^websocket\.url\.prefix=.*$", lambda _: f"websocket.url.prefix={ws}", text, flags=re.M)
            with open(props, "w") as dst:
                dst.write(text)
    return dict(os.environ,
                SLOT_JMAP_PROPERTIES=props,
                SLOT_JMAP_PORT=str(POOL_JMAP_BASE_PORT + n),
                SLOT_WEBADMIN_PORT=str(POOL_WEBADMIN_BASE_PORT + n),
                POOL_JAVA_TOOL_OPTIONS=POOL_JAVA_TOOL_OPTIONS)


def _compose(n: int, *args: str) -> subprocess.CompletedProcess:
    return _run(["docker", "compose", "-p", f"{POOL_PROJECT}-{n}", "-f", _COMPOSE, *args], env=_slot_env(n))


def _save_logs(n: int) -> None:
    logs = _compose(n, "logs", "--no-color", "--timestamps").stdout
    if logs:
        with open(os.path.join(POOL_LOG_DIR, f"backend-slot{n}.log"), "a") as out:
            out.write(logs)


def recycle_slot(n: int) -> None:
    """Replace slot n's container with a fresh, provisioned one."""
    with _recycle_slots:
        if _stopping.is_set():
            return
        print(f"[reset-server] recycle start {n} at {time.monotonic():.3f}", flush=True)
        started = time.monotonic()
        _save_logs(n)
        up = _compose(n, "up", "-d", "--force-recreate", "--no-deps", "--quiet-pull", "tmail-backend")
        if up.returncode != 0:
            raise RuntimeError(f"slot {n} up failed: {up.stderr[-500:]}")
        if _stopping.is_set():
            # stop_all may have run `down` before this container existed.
            _compose(n, "down", "--remove-orphans")
            return
        deadline = time.time() + BOOT_TIMEOUT
        while "JAMES server started" not in _compose(n, "logs", "tmail-backend").stdout:
            if time.time() > deadline:
                raise TimeoutError(f"slot {n} did not start within {BOOT_TIMEOUT}s")
            time.sleep(0.3)
        booted = time.monotonic()
        provision(POOL_WEBADMIN_BASE_PORT + n)
        print(f"[reset-server] recycle end {n} at {time.monotonic():.3f} "
              f"boot={booted - started:.1f}s prov={time.monotonic() - booted:.1f}s", flush=True)


class Pool:
    """Backends a test leases for its whole run; thread safe."""

    def __init__(self, size: int, recycle_fn: Callable[[int], None], urls: List[str],
                 lease_ttl: float = LEASE_TTL, poll: float = 1.0):
        self._recycle_fn = recycle_fn
        self._urls = urls
        self._ttl = lease_ttl
        self._poll = poll
        self._cond = threading.Condition()
        self._state = {n: "resetting" for n in range(size)}
        self._token: Dict[int, str] = {}
        self._leased_at: Dict[int, float] = {}
        self._threads: List[threading.Thread] = []

    def start(self) -> None:
        for n in self._state:
            self._begin_reset(n)

    def wait_ready(self, timeout: float) -> int:
        """Block until no slot is being replaced; returns the number of free slots."""
        deadline = time.time() + timeout
        with self._cond:
            while any(s == "resetting" for s in self._state.values()):
                left = deadline - time.time()
                if left <= 0:
                    break
                self._cond.wait(min(left, self._poll))
            return sum(1 for s in self._state.values() if s == "free")

    def join(self, timeout: float) -> None:
        deadline = time.time() + timeout
        for thread in list(self._threads):
            thread.join(max(0.0, deadline - time.time()))

    def lease(self, timeout: float) -> Optional[dict]:
        deadline = time.time() + timeout
        with self._cond:
            while True:
                self._expire()
                free = [n for n, s in self._state.items() if s == "free"]
                if free:
                    return self._take(free[0])
                if all(s == "dropped" for s in self._state.values()):
                    return None
                left = deadline - time.time()
                if left <= 0:
                    return None
                self._cond.wait(min(left, self._poll))

    def release(self, token: str) -> bool:
        with self._cond:
            self._expire()
            for n, t in self._token.items():
                if t == token:
                    print(f"[reset-server] release slot {n} at {time.monotonic():.3f}", flush=True)
                    self._begin_reset(n)
                    return True
        return False

    def _take(self, n: int) -> dict:
        token = uuid.uuid4().hex
        self._state[n] = "leased"
        self._token[n] = token
        self._leased_at[n] = time.time()
        print(f"[reset-server] lease slot {n} at {time.monotonic():.3f}", flush=True)
        return {"token": token, "url": self._urls[n]}

    def _expire(self) -> None:
        now = time.time()
        for n, at in list(self._leased_at.items()):
            if self._state[n] == "leased" and now - at > self._ttl:
                print(f"[reset-server] lease of slot {n} expired", flush=True)
                self._begin_reset(n)

    def _begin_reset(self, n: int) -> None:
        self._token.pop(n, None)
        self._leased_at.pop(n, None)
        if _stopping.is_set():
            self._state[n] = "dropped"
            return
        self._state[n] = "resetting"
        thread = threading.Thread(target=self._reset, args=(n,), daemon=True)
        self._threads.append(thread)
        thread.start()

    def _reset(self, n: int) -> None:
        state = "dropped"
        for attempt in (1, 2):
            try:
                self._recycle_fn(n)
                state = "free"
                break
            except Exception as exc:
                print(f"[reset-server] ERROR slot {n} attempt {attempt}: {exc}", file=sys.stderr, flush=True)
        with self._cond:
            self._state[n] = state if not _stopping.is_set() else "dropped"
            self._cond.notify_all()


def stop_all(pool: Optional[Pool] = None) -> None:
    """Stop admitting replacements, wait for running ones, then remove every container once."""
    global _stopped
    with _stop_lock:
        if _stopped:
            return
        _stopped = True
    _stopping.set()
    if pool is not None:
        pool.join(200)
    for n in range(len(POOL_URLS)):
        _save_logs(n)
        _compose(n, "down", "--remove-orphans")
    if _slot_dir is not None:
        shutil.rmtree(_slot_dir, ignore_errors=True)


class ResetHandler(http.server.BaseHTTPRequestHandler):
    pool: Pool

    def _send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "content-type")

    def _reply(self, code: int, body: bytes = b"", content_type: str = "text/plain"):
        self.send_response(code)
        self._send_cors_headers()
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _read_json(self) -> dict:
        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length) if length else b""
        return json.loads(raw) if raw.strip() else {}

    def do_OPTIONS(self):
        self._reply(204)

    def _handle_lease(self):
        print(f"[reset-server] lease request at {time.monotonic():.3f}", flush=True)
        leased = self.pool.lease(LEASE_TIMEOUT)
        if leased is None:
            self._reply(503, b"no free backend")
            return
        try:
            self._reply(200, json.dumps(leased).encode(), "application/json")
        except (BrokenPipeError, ConnectionResetError):
            # The client gave up while waiting; do not hold the slot until the TTL.
            self.pool.release(leased["token"])

    def _handle_release(self):
        self.pool.release(str(self._read_json().get("token", "")))
        self._reply(202, b"ok")

    def do_POST(self):
        routes = {"/lease": self._handle_lease, "/release": self._handle_release}
        handler = routes.get(self.path)
        if handler is None:
            self._reply(404)
            return
        try:
            handler()
        except json.JSONDecodeError:
            self._reply(400, b"invalid JSON body")
        except Exception as exc:
            print(f"[reset-server] ERROR: {exc}", file=sys.stderr, flush=True)
            self._reply(500, str(exc).encode())

    def log_message(self, fmt, *args):
        print(f"[reset-server] {self.address_string()} - {fmt % args}", flush=True)


def _watch_ready(pool: Pool) -> None:
    free = pool.wait_ready(POOL_READY_TIMEOUT)
    if free < POOL_MIN_FREE:
        print(f"[reset-server] ERROR only {free} of {POOL_SIZE} backends are free (need {POOL_MIN_FREE})",
              file=sys.stderr, flush=True)
        stop_all(pool)
        os._exit(1)
    print(f"[reset-server] pool ready free={free}", flush=True)


if __name__ == "__main__":
    if POOL_SIZE > 16:
        print(f"[reset-server] POOL_SIZE {POOL_SIZE} exceeds 16 (the agent port gate covers 16 slots)",
              file=sys.stderr, flush=True)
        sys.exit(2)
    if len(POOL_URLS) != POOL_SIZE:
        print(f"[reset-server] POOL_URLS has {len(POOL_URLS)} entries, POOL_SIZE is {POOL_SIZE}",
              file=sys.stderr, flush=True)
        sys.exit(2)
    pool = Pool(POOL_SIZE, recycle_slot, POOL_URLS)
    ResetHandler.pool = pool
    server = http.server.ThreadingHTTPServer(("0.0.0.0", RESET_PORT), ResetHandler)
    server.daemon_threads = True
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    print(f"[reset-server] Listening on port {RESET_PORT}", flush=True)
    pool.start()
    threading.Thread(target=_watch_ready, args=(pool,), daemon=True).start()
    try:
        server.serve_forever()
    finally:
        stop_all(pool)
