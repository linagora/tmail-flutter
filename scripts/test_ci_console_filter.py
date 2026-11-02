#!/usr/bin/env python3
"""Adversarial checks for scripts/ci-console-filter.pl (noise drop vs signal keep)."""
import os
import subprocess
import unittest

ROOT = os.path.join(os.path.dirname(__file__), "..")
FILTER = os.path.join(ROOT, "scripts", "ci-console-filter.pl")


def run_filter(text: str) -> str:
    proc = subprocess.run(
        ["perl", FILTER, "ci-logs/example.log"],
        input=text,
        text=True,
        capture_output=True,
        check=True,
    )
    return proc.stdout


class ConsoleFilterTest(unittest.TestCase):
    def test_keeps_failed_gradle_and_non_2xx_status(self):
        out = run_filter(
            "\n".join(
                [
                    ": > Task :app:assembleDebug",
                    ": > Task :app:test FAILED",
                    "statusCode: 200",
                    "statusCode: 500",
                    "Loaded debug metadata abc",
                    "PatrolBinding: tearDown(): count 1",
                    "KEEP THIS LINE",
                    "",
                ]
            )
        )
        self.assertIn(": > Task :app:test FAILED\n", out)
        self.assertIn("statusCode: 500\n", out)
        self.assertIn("KEEP THIS LINE\n", out)
        self.assertNotIn("assembleDebug", out)
        self.assertNotIn("statusCode: 200", out)
        self.assertNotIn("Loaded debug metadata", out)
        self.assertNotIn("tearDown(): count", out)
        self.assertIn("[console-filter] dropped", out)

    def test_drops_spaced_dio_authorization_header_line(self):
        # Dio dumps indent header lines; those must not reach the CI console.
        out = run_filter(" authorization: Bearer secret\nvisible\n")
        self.assertNotIn("authorization:", out)
        self.assertIn("visible\n", out)


if __name__ == "__main__":
    unittest.main()
