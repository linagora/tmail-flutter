import contextlib
import http.client
import http.server
import importlib.util
import io
import json
import os
import re
import shutil
import subprocess
import tempfile
import threading
import time
import unittest
import urllib.error
import urllib.request
from unittest import mock

os.environ["POOL_URLS"] = "http://h:1,http://h:2"
os.environ["POOL_SIZE"] = "2"

_spec = importlib.util.spec_from_file_location(
    "reset_server", os.path.join(os.path.dirname(__file__), "backend-reset-server.py"))
server = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(server)

ROOT = os.path.join(os.path.dirname(__file__), "..")


def make_pool(size=2, recycle_fn=None, ttl=600.0):
    recycled = []

    def default_recycle(n):
        recycled.append(n)

    urls = [f"http://h:{n + 1}" for n in range(size)]
    pool = server.Pool(size, recycle_fn or default_recycle, urls, lease_ttl=ttl, poll=0.01)
    pool.start()
    return pool, recycled


def wait_until(predicate, seconds=2.0):
    end = time.time() + seconds
    while time.time() < end:
        if predicate():
            return True
        time.sleep(0.01)
    return False


class PoolTest(unittest.TestCase):
    def test_lease_returns_distinct_backend_urls(self):
        pool, _ = make_pool(2)
        a = pool.lease(1)
        b = pool.lease(1)
        self.assertEqual(a["url"], "http://h:1")
        self.assertEqual(b["url"], "http://h:2")
        self.assertNotEqual(a["token"], b["token"])

    def test_lease_times_out_when_pool_is_empty(self):
        pool, _ = make_pool(1)
        self.assertIsNotNone(pool.lease(1))
        self.assertIsNone(pool.lease(0.05))

    def test_release_recycles_backend_then_makes_it_leasable(self):
        pool, recycled = make_pool(1)
        first = pool.lease(1)
        self.assertTrue(pool.release(first["token"]))
        second = pool.lease(1)
        self.assertEqual(second["url"], first["url"])
        self.assertEqual(recycled, [0, 0])

    def test_lease_waits_until_the_released_backend_is_recycled(self):
        entered, held = threading.Event(), threading.Event()
        calls = []

        def recycle(n):
            calls.append(n)
            if len(calls) == 2:
                entered.set()
                held.wait(10)

        pool, _ = make_pool(1, recycle)
        try:
            pool.release(pool.lease(1)["token"])
            self.assertTrue(entered.wait(2))  # handshake: recycle is in flight
            self.assertIsNone(pool.lease(0.1))
        finally:
            held.set()
        self.assertIsNotNone(pool.lease(5))

    def test_stale_or_repeated_release_is_a_no_op(self):
        pool, recycled = make_pool(1)
        leased = pool.lease(1)
        self.assertTrue(pool.release(leased["token"]))
        self.assertFalse(pool.release(leased["token"]))
        self.assertFalse(pool.release("unknown"))
        self.assertTrue(wait_until(lambda: len(recycled) == 2))
        self.assertEqual(recycled, [0, 0])

    def test_failed_recycle_is_retried_once_then_dropped(self):
        attempts = []

        def recycle(n):
            attempts.append(n)
            if n == 0:
                raise RuntimeError("boom")

        pool, _ = make_pool(2, recycle)
        leased = pool.lease(1)
        self.assertEqual(leased["url"], "http://h:2")
        self.assertTrue(wait_until(lambda: attempts.count(0) == 2))
        pool.release(leased["token"])
        self.assertEqual(pool.lease(1)["url"], "http://h:2")

    def test_all_backends_dropped_fails_fast(self):
        def recycle(n):
            raise RuntimeError("boom")

        pool, _ = make_pool(2, recycle)
        start = time.time()
        self.assertIsNone(pool.lease(30))
        self.assertLess(time.time() - start, 2)

    def test_expired_lease_is_reclaimed(self):
        pool, recycled = make_pool(1, ttl=0.05)
        pool.lease(1)
        time.sleep(0.1)
        self.assertIsNotNone(pool.lease(1))
        self.assertEqual(recycled, [0, 0])

    def test_wait_ready_counts_free_backends(self):
        pool, _ = make_pool(2)
        self.assertEqual(pool.wait_ready(2, 2), 2)

    def test_wait_ready_returns_once_enough_backends_are_free(self):
        stalled = threading.Event()

        def recycle(n):
            if n == 1:
                stalled.wait(5)

        pool, _ = make_pool(2, recycle)
        try:
            start = time.time()
            self.assertEqual(pool.wait_ready(5, 1), 1)
            self.assertLess(time.time() - start, 2)
        finally:
            stalled.set()

    def test_release_while_stopping_starts_no_recycle(self):
        pool, recycled = make_pool(1)
        leased = pool.lease(1)
        server._stopping.set()
        try:
            self.assertTrue(pool.release(leased["token"]))
            time.sleep(0.1)
            self.assertEqual(recycled, [0])
            self.assertIsNone(pool.lease(0.05))
        finally:
            server._stopping.clear()


class SlotEnvTest(unittest.TestCase):
    def setUp(self):
        self.root = tempfile.mkdtemp()
        shutil.copy(os.path.join(ROOT, "backend-docker", "jmap.properties"), self.root)
        self.saved = (server._JMAP_PROPERTIES, server._slot_dir)
        server._JMAP_PROPERTIES = os.path.join(self.root, "jmap.properties")
        server._slot_dir = None

    def tearDown(self):
        server._JMAP_PROPERTIES, server._slot_dir = self.saved
        shutil.rmtree(self.root)

    def test_slot_properties_advertise_the_slot_url(self):
        env = server._slot_env(1)
        with open(env["SLOT_JMAP_PROPERTIES"]) as f:
            text = f.read()
        self.assertIn("url.prefix=http://h:2\n", text)
        self.assertIn("websocket.url.prefix=ws://h:2", text)
        self.assertEqual(env["SLOT_JMAP_PORT"], "8101")
        self.assertEqual(env["SLOT_WEBADMIN_PORT"], "8201")


    def test_slot_dir_sits_beside_the_compose_mounts(self):
        props = server._slot_env(0)["SLOT_JMAP_PROPERTIES"]
        self.assertEqual(os.path.dirname(os.path.dirname(props)), self.root)

    def test_concurrent_first_calls_share_one_slot_dir(self):
        envs = []
        threads = [threading.Thread(target=lambda n=n: envs.append(server._slot_env(n))) for n in (0, 1)]
        [t.start() for t in threads]
        [t.join() for t in threads]
        dirs = {os.path.dirname(e["SLOT_JMAP_PROPERTIES"]) for e in envs}
        self.assertEqual(len(dirs), 1)


class _FixedPool:
    def __init__(self, free):
        self.free = free

    def wait_ready(self, timeout, min_free):
        return self.free


class WatchReadyTest(unittest.TestCase):
    def _watch(self, free, min_free):
        out = io.StringIO()
        with mock.patch.object(server, "POOL_MIN_FREE", min_free), \
                mock.patch.object(server, "stop_all") as stop, \
                mock.patch.object(server.os, "_exit", side_effect=SystemExit) as exit_, \
                contextlib.redirect_stdout(out), contextlib.redirect_stderr(io.StringIO()):
            try:
                server._watch_ready(_FixedPool(free))
            except SystemExit:
                pass
        return out.getvalue(), stop, exit_

    def test_logs_ready_when_enough_backends_are_free(self):
        out, stop, exit_ = self._watch(free=2, min_free=2)
        self.assertIn("pool ready free=2", out)
        stop.assert_not_called()
        exit_.assert_not_called()

    def test_exits_without_ready_when_too_few_backends_are_free(self):
        out, stop, exit_ = self._watch(free=0, min_free=1)
        self.assertNotIn("pool ready", out)
        stop.assert_called_once()
        exit_.assert_called_once_with(1)


class RecycleAfterStopTest(unittest.TestCase):
    def test_recycle_finishing_after_stop_removes_its_own_container(self):
        calls = []
        saved = (server._compose, server._save_logs, server.provision)

        def compose(n, *args):
            calls.append(args[0])
            if args[0] == "up":
                server._stopping.set()  # stop_all ran while `up` was in flight
            return type("R", (), {"returncode": 0, "stdout": "", "stderr": ""})()

        server._compose, server._save_logs = compose, lambda n: None
        server.provision = lambda port: calls.append("provision")
        try:
            server.recycle_slot(0)
        finally:
            server._compose, server._save_logs, server.provision = saved
            server._stopping.clear()
        self.assertEqual(calls, ["up", "down"])


class RunTimeoutTest(unittest.TestCase):
    def test_hung_command_raises_timeout(self):
        with self.assertRaises(subprocess.TimeoutExpired):
            server._run(["sleep", "5"], timeout=0.2)

    def test_timeout_kills_the_children_of_the_command(self):
        marker = os.path.join(tempfile.mkdtemp(), "child-survived")
        self.addCleanup(shutil.rmtree, os.path.dirname(marker), ignore_errors=True)
        with self.assertRaises(subprocess.TimeoutExpired):
            server._run(["sh", "-c", f"(sleep 1; touch {marker}) & wait"], timeout=0.3)
        time.sleep(1.5)
        self.assertFalse(os.path.exists(marker))

    def test_stop_all_cleans_every_slot_when_one_call_hangs(self):
        downs = []

        def compose(n, *args):
            if n == 0:
                raise subprocess.TimeoutExpired("docker", 1)
            downs.append(n)

        try:
            with mock.patch.object(server, "_compose", compose), \
                    mock.patch.object(server, "_save_logs", lambda n: None), \
                    mock.patch.object(server, "_stopped", False), \
                    mock.patch.object(server, "_slot_dir", None), \
                    contextlib.redirect_stderr(io.StringIO()):
                server.stop_all()
        finally:
            server._stopping.clear()
        self.assertEqual(downs, [1])


class HttpTest(unittest.TestCase):
    def setUp(self):
        self.saved_timeout = server.LEASE_TIMEOUT
        server.LEASE_TIMEOUT = 0.2

    def tearDown(self):
        server.LEASE_TIMEOUT = self.saved_timeout
        self.httpd.shutdown()
        self.httpd.server_close()

    def start(self, recycle_fn=None):
        pool, self.recycled = make_pool(1, recycle_fn)
        server.ResetHandler.pool = pool
        self.httpd = http.server.ThreadingHTTPServer(("127.0.0.1", 0), server.ResetHandler)
        threading.Thread(target=self.httpd.serve_forever, daemon=True).start()
        self.base = f"http://127.0.0.1:{self.httpd.server_address[1]}"
        return pool

    def post(self, path, body=b""):
        req = urllib.request.Request(self.base + path, data=body, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=5) as r:
                return r.status, r.read()
        except urllib.error.HTTPError as e:
            return e.code, e.read()

    def test_lease_then_release_round_trip(self):
        self.start()
        code, body = self.post("/lease")
        self.assertEqual(code, 200)
        leased = json.loads(body)
        self.assertEqual(leased["url"], "http://h:1")
        self.assertEqual(self.post("/release", json.dumps({"token": leased["token"]}).encode())[0], 202)

    def test_failed_lease_reply_releases_the_slot(self):
        pool = self.start()
        real_reply = server.ResetHandler._reply

        def failing_reply(handler, code, *args):
            if code == 200:
                raise TimeoutError("reply failed")
            return real_reply(handler, code, *args)

        with mock.patch.object(server.ResetHandler, "_reply", failing_reply):
            with self.assertRaises(http.client.RemoteDisconnected):
                self.post("/lease")
        replacement = pool.lease(2)
        self.assertIsNotNone(replacement)

    def test_lease_answers_503_when_every_backend_is_dropped(self):
        def recycle(n):
            raise RuntimeError("boom")

        self.start(recycle)
        self.assertTrue(wait_until(lambda: self.post("/lease")[0] == 503))

    def test_release_with_malformed_body_answers_400(self):
        self.start()
        self.assertEqual(self.post("/release", b"{not json")[0], 400)


class ComposeParityTest(unittest.TestCase):
    def test_pool_compose_uses_the_backend_image_of_the_main_compose(self):
        def image(name):
            with open(os.path.join(ROOT, "backend-docker", name)) as f:
                return re.search(r"^\s*image:\s*(\S+)", f.read(), re.M).group(1)

        self.assertEqual(image("docker-compose.pool.yaml"), image("docker-compose.yaml"))


if __name__ == "__main__":
    unittest.main()
