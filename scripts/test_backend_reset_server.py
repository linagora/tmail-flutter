import http.server
import importlib.util
import json
import os
import re
import tempfile
import threading
import time
import unittest
import urllib.error
import urllib.request

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
        self.assertEqual(attempts.count(0), 2)
        pool.release(leased["token"])
        self.assertEqual(pool.lease(1)["url"], "http://h:2")

    def test_all_backends_dropped_fails_fast(self):
        def recycle(n):
            raise RuntimeError("boom")

        pool, _ = make_pool(2, recycle)
        start = time.time()
        self.assertTrue(wait_until(lambda: pool.lease(0) is None))
        self.assertLess(time.time() - start, 2)

    def test_expired_lease_is_reclaimed(self):
        pool, _ = make_pool(1, ttl=0.05)
        pool.lease(1)
        time.sleep(0.1)
        self.assertIsNotNone(pool.lease(1))

    def test_wait_ready_counts_free_backends(self):
        pool, _ = make_pool(2)
        self.assertEqual(pool.wait_ready(2), 2)

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
    def test_slot_properties_advertise_the_slot_url(self):
        server._JMAP_PROPERTIES = os.path.join(ROOT, "backend-docker", "jmap.properties")
        server._slot_dir = tempfile.mkdtemp()
        env = server._slot_env(1)
        with open(env["SLOT_JMAP_PROPERTIES"]) as f:
            text = f.read()
        self.assertIn("url.prefix=http://h:2\n", text)
        self.assertIn("websocket.url.prefix=ws://h:2", text)
        self.assertEqual(env["SLOT_JMAP_PORT"], "8101")
        self.assertEqual(env["SLOT_WEBADMIN_PORT"], "8201")


    def test_concurrent_first_calls_share_one_slot_dir(self):
        server._JMAP_PROPERTIES = os.path.join(ROOT, "backend-docker", "jmap.properties")
        server._slot_dir = None
        envs = []
        threads = [threading.Thread(target=lambda n=n: envs.append(server._slot_env(n))) for n in (0, 1)]
        [t.start() for t in threads]
        [t.join() for t in threads]
        dirs = {os.path.dirname(e["SLOT_JMAP_PROPERTIES"]) for e in envs}
        self.assertEqual(len(dirs), 1)


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
