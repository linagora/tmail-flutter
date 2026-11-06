#!/usr/bin/env python3
"""The Jenkins Flutter check accepts only FLUTTER_VERSION."""
import os
import stat
import subprocess
import tempfile
import unittest

ROOT = os.path.join(os.path.dirname(__file__), "..")
SCRIPT = os.path.join(ROOT, "scripts", "ci-assert-flutter-version.sh")


def _flutter(body: str) -> str:
    directory = tempfile.mkdtemp()
    path = os.path.join(directory, "flutter")
    with open(path, "w", encoding="utf-8") as handle:
        handle.write("#!/bin/sh\n" + body + "\n")
    os.chmod(path, os.stat(path).st_mode | stat.S_IEXEC)
    return directory


def _run(path, version="3.47.9"):
    env = os.environ.copy()
    env["FLUTTER_VERSION"] = version
    env["FLUTTER_ROOT"] = "/opt/flutter-" + version
    env["PATH"] = path + os.pathsep + "/usr/bin:/bin"
    return subprocess.run(
        ["bash", SCRIPT],
        env=env,
        text=True,
        capture_output=True,
    )


class AssertFlutterVersionTest(unittest.TestCase):
    def test_accepts_the_required_version(self):
        path = _flutter('echo "Flutter 3.47.9 • channel stable"')
        result = _run(path)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Flutter 3.47.9", result.stdout)

    def test_rejects_a_different_version(self):
        path = _flutter('echo "Flutter 3.38.9 • channel stable"')
        result = _run(path)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Found: 3.38.9", result.stderr)

    def test_rejects_a_missing_flutter(self):
        result = _run("/tmp/no-such-flutter-bin")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("not on PATH", result.stderr)


if __name__ == "__main__":
    unittest.main()
