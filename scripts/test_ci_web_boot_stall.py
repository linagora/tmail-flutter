#!/usr/bin/env python3
"""Checks for the web boot stall probe: page DevTools sockets (pages.js) and /proc sampling (proc.sh)."""
import base64
import hashlib
import json
import os
import re
import shutil
import socketserver
import subprocess
import tempfile
import threading
import time
import unittest

SCRIPTS = os.path.dirname(os.path.abspath(__file__))
PAGES = os.path.join(SCRIPTS, "ci-web-boot-stall-pages.js")
PROC = os.path.join(SCRIPTS, "ci-web-boot-stall-proc.sh")
GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
STATE = {
    "url": "http://localhost:3000/",
    "scripts": 2,
    "lastScripts": ["http://localhost:3000/packages/a.js", "http://localhost:3000/packages/b.js"],
    "readyState": "loading",
    "resources": 3,
    "now": 1234,
    "origin": 1,
    "pending": ["http://localhost:3000/packages/b.js"],
}
MODES = ["ok", "silent", "close", "exception", "refuse"]


class DevToolsHandler(socketserver.StreamRequestHandler):
    def handle(self):
        request_line = self.rfile.readline().decode()
        headers = {}
        while True:
            line = self.rfile.readline().decode().strip()
            if not line:
                break
            name, value = line.split(":", 1)
            headers[name.lower()] = value.strip()
        path = request_line.split()[1]
        if headers.get("upgrade", "").lower() == "websocket":
            self.websocket(path.rsplit("/", 1)[1], headers["sec-websocket-key"])
        else:
            self.http(path)

    def http(self, path):
        port = self.server.server_address[1]
        if path == "/json/version":
            body = {"Browser": "HeadlessChrome/test"}
        else:
            body = [
                {"id": mode, "type": "page", "url": "http://localhost:3000/",
                 "webSocketDebuggerUrl": f"ws://127.0.0.1:{port}/devtools/page/{mode}"}
                for mode in MODES
            ] + [{"id": "dead", "type": "page", "url": "http://localhost:3000/",
                  "webSocketDebuggerUrl": "ws://127.0.0.1:1/devtools/page/dead"}]
        data = json.dumps(body).encode()
        self.wfile.write(b"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n"
                         + f"Content-Length: {len(data)}\r\nConnection: close\r\n\r\n".encode() + data)

    def read_client_frame(self):
        length = self.rfile.read(2)[1] & 0x7F
        if length == 126:
            length = int.from_bytes(self.rfile.read(2), "big")
        mask = self.rfile.read(4)
        return bytes(b ^ mask[i % 4] for i, b in enumerate(self.rfile.read(length)))

    def send_text(self, text):
        data = text.encode()
        header = bytes([0x81, len(data)]) if len(data) < 126 else bytes([0x81, 126]) + len(data).to_bytes(2, "big")
        self.wfile.write(header + data)

    def websocket(self, mode, key):
        if mode == "refuse":
            self.wfile.write(b"HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
            return
        accept = base64.b64encode(hashlib.sha1((key + GUID).encode()).digest()).decode()
        self.wfile.write(("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\n"
                          f"Connection: Upgrade\r\nSec-WebSocket-Accept: {accept}\r\n\r\n").encode())
        json.loads(self.read_client_frame())
        if mode == "silent":
            time.sleep(5)
        elif mode == "ok":
            self.send_text(json.dumps({"id": 1, "result": {"result": {"type": "object", "value": STATE}}}))
            time.sleep(0.2)
        elif mode == "exception":
            self.send_text(json.dumps({"id": 1, "result": {"result": {}, "exceptionDetails": {
                "text": "Uncaught", "exception": {"description": "ReferenceError: boom\n    at x"}}}}))
            time.sleep(0.2)


class Server(socketserver.ThreadingTCPServer):
    daemon_threads = True
    allow_reuse_address = True


class PagesProbeTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = Server(("127.0.0.1", 0), DevToolsHandler)
        threading.Thread(target=cls.server.serve_forever, daemon=True).start()
        cls.root = tempfile.mkdtemp(prefix="boot-stall-test-")
        runner = os.path.join(cls.root, "runner", "node_modules", "@playwright", "test")
        os.makedirs(runner)
        with open(os.path.join(runner, "index.js"), "w") as f:
            f.write("exports.chromium = { connectOverCDP: async () => { throw new Error('connect timeout'); } };\n")
        cls.profile = os.path.join(cls.root, "tmp", "playwright_chromiumdev_profile-test")
        os.makedirs(cls.profile)
        with open(os.path.join(cls.profile, "DevToolsActivePort"), "w") as f:
            f.write(f"{cls.server.server_address[1]}\n/devtools/browser/x\n")
        env = dict(os.environ, TMPDIR=os.path.join(cls.root, "tmp"), PAGE_WS_GAP_MS="100", PAGE_WS_TIMEOUT_MS="600")
        proc = subprocess.run(["node", PAGES, os.path.join(cls.root, "runner")],
                              env=env, text=True, capture_output=True, timeout=60)
        cls.out = proc.stdout

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        shutil.rmtree(cls.root, ignore_errors=True)

    def page_ws(self, target, sample):
        pattern = re.compile(rf"^PAGE_WS \S+boot-stall-test-\S+ id={target} sample={sample} (.*)$", re.M)
        match = pattern.search(self.out)
        self.assertIsNotNone(match, f"no PAGE_WS line for {target} sample {sample}:\n{self.out}")
        return match.group(1)

    def test_reports_node_version(self):
        self.assertRegex(self.out, r"(?m)^NODE version=v\d+")

    def test_answering_page_prints_boot_state_in_both_samples(self):
        for sample in (1, 2):
            self.assertRegex(self.page_ws("ok", sample), r"^phase=eval result=ok ms=\d+$")
        self.assertIn("PAGE_WS_STATE url=http://localhost:3000/ readyState=loading resources=3 now=1234 origin=1", self.out)
        # The probe counts each "PAGE " line as a tab read through Playwright and would dump on it.
        self.assertNotRegex(self.out, r"(?m)^PAGE ")
        self.assertIn("PENDING_COUNT 1", self.out)

    def test_silent_page_is_reported_as_timeout(self):
        self.assertRegex(self.page_ws("silent", 1), r"^phase=eval result=timeout ms=\d+$")

    def test_page_closing_its_socket_is_reported(self):
        self.assertRegex(self.page_ws("close", 1), r"^phase=eval result=closed ms=\d+$")

    def test_evaluation_exception_is_reported_with_first_line(self):
        self.assertRegex(self.page_ws("exception", 1), r"result=error ms=\d+ detail=ReferenceError: boom$")

    def test_refused_handshake_is_reported_in_connect_phase(self):
        self.assertRegex(self.page_ws("refuse", 1), r"^phase=connect result=error ms=\d+ detail=handshake http=400$")

    def test_unreachable_socket_is_reported_in_connect_phase(self):
        self.assertRegex(self.page_ws("dead", 1), r"^phase=connect result=error ms=\d+ detail=")


def run_bash(script):
    return subprocess.run(["bash", "-c", f'. "{PROC}"; {script}'], text=True, capture_output=True,
                          env=dict(os.environ, PROC_SAMPLE_SECONDS="0.2"), timeout=30).stdout


class ProcSamplingTest(unittest.TestCase):
    def test_unreadable_pid_is_reported_not_counted_as_idle(self):
        self.assertEqual(run_bash("renderer_thread_state 999999999").strip(), "PROC 999999999 unreadable|exited")

    @unittest.skipUnless(os.path.isdir("/proc/self/task"), "needs Linux /proc")
    def test_live_pid_reports_deltas_and_threads(self):
        out = run_bash("renderer_thread_state $$")
        self.assertRegex(out, r"PROC \d+ cpu_delta=\d+ main_vol_delta=\d+ main_nonvol_delta=\d+ interval=0\.2s")
        self.assertRegex(out, r"THREAD \d+ tid=\d+ comm=\S+ state=[A-Za-z] wchan=\S*")

    def test_no_pids_prints_nothing(self):
        self.assertEqual(run_bash("renderer_thread_state"), "")


if __name__ == "__main__":
    unittest.main()
