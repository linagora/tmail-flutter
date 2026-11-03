#!/usr/bin/env python3
"""Checks for the frozen-tab diagnostics: native stacks (native.sh) and browser-level debugger state (debugger.js)."""
import base64
import hashlib
import json
import os
import shutil
import socketserver
import subprocess
import tempfile
import threading
import time
import unittest

SCRIPTS = os.path.dirname(os.path.abspath(__file__))
NATIVE = os.path.join(SCRIPTS, "ci-web-boot-stall-native.sh")
DEBUGGER = os.path.join(SCRIPTS, "ci-web-boot-stall-debugger.js")
GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
PAGE_URL = "http://localhost:3000/"


class BrowserHandler(socketserver.StreamRequestHandler):
    """Browser-level DevTools socket. The last path segment picks the mode: paused, running or silent."""

    def handle(self):
        request_line = self.rfile.readline().decode()
        headers = self.read_headers()
        self.upgrade(headers["sec-websocket-key"])
        self.serve(request_line.split()[1].rsplit("/", 1)[1])

    def read_headers(self):
        headers = {}
        for line in iter(lambda: self.rfile.readline().decode().strip(), ""):
            name, value = line.split(":", 1)
            headers[name.lower()] = value.strip()
        return headers

    def upgrade(self, key):
        accept = base64.b64encode(hashlib.sha1((key + GUID).encode()).digest()).decode()
        self.wfile.write(("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\n"
                          f"Connection: Upgrade\r\nSec-WebSocket-Accept: {accept}\r\n\r\n").encode())

    def serve(self, mode):
        try:
            while True:
                self.answer(mode, json.loads(self.read_client_frame()))
        except (EOFError, ConnectionError, ValueError):
            return

    def read_client_frame(self):
        head = self.rfile.read(2)
        if len(head) < 2:
            raise EOFError
        length = head[1] & 0x7F
        if length == 126:
            length = int.from_bytes(self.rfile.read(2), "big")
        mask = self.rfile.read(4)
        return bytes(b ^ mask[i % 4] for i, b in enumerate(self.rfile.read(length)))

    def send_text(self, text):
        data = text.encode()
        header = bytes([0x81, len(data)]) if len(data) < 126 else bytes([0x81, 126]) + len(data).to_bytes(2, "big")
        self.wfile.write(header + data)

    def reply(self, message_id, result):
        self.send_text(json.dumps({"id": message_id, "result": result}))

    def event(self, method, params, session_id=None):
        message = {"method": method, "params": params}
        if session_id:
            message["sessionId"] = session_id
        self.send_text(json.dumps(message))

    def answer(self, mode, message):
        method, message_id, session_id = message["method"], message["id"], message.get("sessionId")
        if method == "Target.getTargets":
            self.reply(message_id, {"targetInfos": [
                {"targetId": "T1", "type": "page", "url": PAGE_URL},
                {"targetId": "T2", "type": "page", "url": "about:blank"},
            ]})
        elif method == "Target.attachToTarget":
            self.event("Target.attachedToTarget", {"sessionId": "S1", "waitingForDebugger": mode == "paused"})
            self.reply(message_id, {"sessionId": "S1"})
        elif mode == "silent" and session_id:
            return
        elif method == "Debugger.enable":
            if mode == "paused":
                self.event("Debugger.paused", {"reason": "other", "callFrames": [
                    {"url": PAGE_URL + "app.js", "location": {"lineNumber": 5}}]}, session_id)
            self.reply(message_id, {})
        else:
            self.reply(message_id, {"result": {"type": "number", "value": 1}})


class Server(socketserver.ThreadingTCPServer):
    daemon_threads = True
    allow_reuse_address = True


class DebuggerProbeTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = Server(("127.0.0.1", 0), BrowserHandler)
        threading.Thread(target=cls.server.serve_forever, daemon=True).start()
        cls.root = tempfile.mkdtemp(prefix="boot-stall-debugger-test-")

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        shutil.rmtree(cls.root, ignore_errors=True)

    def probe(self, mode, with_port=True):
        profile = tempfile.mkdtemp(dir=self.root)
        if with_port:
            with open(os.path.join(profile, "DevToolsActivePort"), "w") as f:
                f.write(f"{self.server.server_address[1]}\n/devtools/browser/{mode}\n")
        env = dict(os.environ, DEBUGGER_COMMAND_TIMEOUT_MS="300", DEBUGGER_SETTLE_MS="100")
        started = time.time()
        proc = subprocess.run(["node", DEBUGGER, profile], env=env, text=True, capture_output=True, timeout=30)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        return proc.stdout, time.time() - started

    def test_reports_the_pause_of_a_tab_waiting_for_the_debugger(self):
        out, _ = self.probe("paused")
        self.assertIn("Target.attachedToTarget event waitingForDebugger=true", out)
        self.assertIn(f"Debugger.paused event reason=other top={PAGE_URL}app.js:5", out)
        self.assertIn("Runtime.evaluate ok", out)
        self.assertNotIn("about:blank", out)

    def test_reports_no_pause_for_a_running_tab(self):
        out, _ = self.probe("running")
        self.assertIn("waitingForDebugger=false", out)
        self.assertIn("Debugger.paused none", out)

    def test_reports_timeouts_when_the_tab_never_answers(self):
        out, elapsed = self.probe("silent")
        self.assertIn("Target.attachToTarget ok", out)
        self.assertIn("Debugger.enable timeout", out)
        self.assertIn("Runtime.evaluate timeout", out)
        self.assertLess(elapsed, 10)

    def test_reports_a_missing_endpoint_file(self):
        out, _ = self.probe("paused", with_port=False)
        self.assertRegex(out, r"DBG \S+ probe error .*DevToolsActivePort")


class NativeStacksTest(unittest.TestCase):
    def run_native(self, call):
        proc = subprocess.run(["bash", "-c", f'. "{NATIVE}"; {call}'], text=True, capture_output=True, timeout=30)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        return proc.stdout

    def test_preflight_line_names_gdb_sudo_and_ptrace_scope(self):
        self.assertRegex(self.run_native("native_preflight").strip(),
                         r"^NATIVE preflight gdb=\S+ sudo=(ok|no) ptrace_scope=\S+$")

    def test_exited_pid_is_reported_and_not_fatal(self):
        out = self.run_native("native_stacks 999999")
        self.assertTrue(out.startswith("NATIVE preflight"), out)
        self.assertIn("NATIVE 999999 unavailable: exited", out)

    def test_preflight_is_printed_once_per_probe(self):
        out = self.run_native("native_stacks 999999; native_stacks 999998")
        self.assertEqual(out.count("NATIVE preflight"), 1)
        self.assertIn("NATIVE 999998 unavailable: exited", out)

    def test_owns_only_descendants_of_the_job_script(self):
        out = self.run_native(
            'sleep 30 & child=$!; '
            'NATIVE_OWNER_PID=$$ native_owned "$child" && echo child-owned; '
            'NATIVE_OWNER_PID=999999 native_owned "$child" || echo stranger-skipped; '
            'native_owned "" || echo empty-skipped; kill "$child"')
        self.assertEqual(out.split(), ["child-owned", "stranger-skipped", "empty-skipped"])

    def test_no_pids_print_nothing(self):
        self.assertEqual(self.run_native("native_stacks"), "")


if __name__ == "__main__":
    unittest.main()
