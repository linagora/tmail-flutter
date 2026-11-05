"""Behavior tests for the memory report; all fixtures stay in temporary dirs."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
SCRIPT = Path(__file__).with_name("memory-leak-report.py")
spec = importlib.util.spec_from_file_location("memory_leak_report", SCRIPT)
report = importlib.util.module_from_spec(spec)
spec.loader.exec_module(report)


def android(options=None):
    values = dict(count=1, buffer=0, rss=100, heap=100, size=100)
    values.update(options or {})
    return {"case": "demo", "label": "before", "platform": "android",
            "heapUsage": values["heap"], "externalUsage": 0, "rss": values["rss"],
            "classes": [{"class": "ComposerController", "lib": "package:core/a.dart",
                         "count": values["count"], "bytes": values["size"]},
                        {"class": "_Uint8List", "lib": None, "count": 1, "bytes": values["buffer"]}]}


def web(wasm=1000, controllers=1):
    types = ["object", "native", "string", "closure"]
    strings = ["ComposerController", "Memory", "ArrayBuffer",
               "system / JSArrayBufferData", "secret content"]
    nodes = []
    for i in range(controllers):
        nodes.extend([0, 0, i + 1, 10, 0])
    # Two memories and duplicate references share one data node.
    nodes.extend([0, 1, 20, 10, 2, 0, 1, 21, 10, 1,
                  0, 2, 22, 10, 1, 1, 3, 23, wasm, 0, 2, 4, 24, 7, 0])
    array_offset = (controllers + 2) * 5
    data_offset = (controllers + 3) * 5
    return {"snapshot": {"meta": {
        "node_fields": ["type", "name", "id", "self_size", "edge_count"],
        "node_types": [types, "string", "number", "number", "number"],
        "edge_fields": ["type", "name_or_index", "to_node"],
        "edge_types": [["internal"], "string_or_number", "node"]}},
        "nodes": nodes, "edges": [0, 0, array_offset] * 3 + [0, 0, data_offset],
        "strings": strings}


class MemoryReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.rules = {"tmailLibPrefixes": ["package:core/"],
                      "bufferClasses": {"android": ["_Uint8List"]},
                      "webBufferKeys": ["(string)", "system / JSArrayBufferData"],
                      "defaults": {"maxTotalGrowthBytes": 4194304,
                                   "maxBufferGrowthBytes": 2621440,
                                   "maxTmailClassGrowthBytes": 1048576,
                                   "maxRssGrowthBytes": 31457280, "topN": 20},
                      "cases": {"demo": {"mustReturnToBaseline": ["ComposerController"]}}}
        (self.root / "lib").mkdir()
        (self.root / "lib/a.dart").write_text("final class ComposerController {}")
        self.rules_path = self.root / "rules.json"
    def write(self, platform, before, after):
        suffix = "android.json" if platform == "android" else "heapsnapshot"
        for label, sample in [("before", before), ("after", after)]:
            if sample is not None:
                (self.root / f"demo-{label}.{suffix}").write_text(json.dumps(sample))
    def run_report(self, subprocess_mode=False, **env):
        self.rules_path.write_text(json.dumps(self.rules))
        args = [str(self.root), str(self.rules_path), "--repo-root", str(self.root)]
        environment = {**os.environ, "MEMORY_REPORT_ONLY": "", "GITHUB_STEP_SUMMARY": "", **env}
        if subprocess_mode:
            result = subprocess.run([sys.executable, "-I", str(SCRIPT), *args],
                                    env=environment, capture_output=True, text=True)
            self.assertEqual(result.stderr, "")
            return result.returncode, result.stdout
        with patch.dict(os.environ, environment, clear=True), contextlib.redirect_stdout(io.StringIO()) as out:
            code = report.main(args)
        return code, out.getvalue()
    def test_android_pass_and_summary_appends(self):
        self.write("android", android(), android())
        summary = self.root / "summary.md"
        summary.write_text("existing\n")
        code, text = self.run_report(GITHUB_STEP_SUMMARY=str(summary))
        self.assertEqual(code, 0)
        self.assertIn("RESULT: PASS", text)
        self.assertIn("### demo (android)", text)
        self.assertEqual(summary.read_text(), "existing\n" + text)
        self.assertEqual(self.run_report(subprocess_mode=True)[0], 0)
    def test_android_r1_and_retainers(self):
        after = android({"count": 2})
        after["retainers"] = {"ComposerController": ["root -> composer"]}
        self.write("android", android(), after)
        code, text = self.run_report()
        self.assertEqual(code, 1)
        self.assertIn("R1 ComposerController | 1 | 2 | 1 | 0 | ❌", text)
        self.assertIn("root -> composer", text)
        self.assertIn("RESULT: FAIL (1 failed)", text)
    def test_android_buffer_three_mb_fails(self):
        self.write("android", android(), android({"buffer": 3 * 1024 * 1024}))
        code, text = self.run_report()
        self.assertEqual(code, 1)
        self.assertIn("R2 | 0 | 3145728 | 3145728 | < 2621440 | ❌", text)
    def test_android_r5_boundary_fails(self):
        self.write("android", android(), android({"rss": 31457380}))
        code, text = self.run_report()
        self.assertEqual(code, 1)
        self.assertIn("R5 | 100 | 31457380 | 31457280 | < 31457280 | ❌", text)
    def test_limits_and_override(self):
        for field, limit, rule in [("buffer", 2621440, "R2"), ("heap", 4194304, "R3"),
                                   ("size", 1048576, "R4")]:
            with self.subTest(rule=rule):
                value = limit + (100 if field in {"heap", "size"} else 0)
                self.write("android", android(), android({field: value}))
                self.assertEqual(self.run_report()[0], 0 if rule == "R4" else 1)
        self.write("android", android(), android({"size": 1048677}))
        self.assertEqual(self.run_report()[0], 1)
        self.rules["cases"]["demo"]["maxTmailClassGrowthBytes"] = 1048577
        self.assertEqual(self.run_report()[0], 0)
    def test_web_wasm_exclusion_and_string_grouping(self):
        self.write("web", web(), web(wasm=6000000))
        code, text = self.run_report()
        self.assertEqual(code, 0)
        self.assertIn("wasmBytes: before=1000, after=6000000", text)
        self.assertIn("R3 | 47 | 47 | 0", text)
        self.assertIn("R2 | 7 | 7 | 0", text)
        self.assertIn("(string)", text)
        self.assertNotIn("secret content", text)
        self.assertIn("ComposerController | ✅", text)
    def test_web_r1_counts_only_objects(self):
        before, after = web(), web(controllers=2)
        self.write("web", before, after)
        code, text = self.run_report()
        self.assertEqual(code, 1)
        self.assertIn("R1 ComposerController | 1 | 2 | 1 | 0 | ❌", text)
        after["nodes"][0] = 3  # Same name, but closure: no object growth.
        self.write("web", before, after)
        self.assertEqual(self.run_report()[0], 0)
    def test_workspace_class_scan(self):
        (self.root / "pubspec.yaml").write_text("name: demo\nworkspace:\n  - packages/mail\ndependencies:\n  other: any\n")
        lib = self.root / "packages/mail/lib"
        lib.mkdir(parents=True)
        (lib / "a.dart").write_text("abstract base class PackageController {}\n")
        before, after = web(), web()
        before["strings"][0] = after["strings"][0] = "PackageController"
        after["nodes"][3] = 1048587
        self.write("web", before, after)
        code, text = self.run_report()
        self.assertEqual(code, 1)
        self.assertIn("PackageController | ✅", text)
        self.assertIn("R4", text)
    def test_no_sample_and_partial_sample(self):
        code, text = self.run_report()
        self.assertEqual(code, 1)
        self.assertIn("no sample", text)
        self.assertNotIn("| Rule |", text)
        self.write("android", android(), None)
        self.assertIn("missing after sample", self.run_report()[1])
        (self.root / "demo-before.android.json").unlink()
        self.write("web", None, web())
        self.assertIn("missing before sample", self.run_report()[1])
    def test_report_only_keeps_failure_report_but_exits_zero(self):
        self.assertEqual(self.run_report(subprocess_mode=True)[0], 1)
        code, text = self.run_report(subprocess_mode=True, MEMORY_REPORT_ONLY="1")
        self.assertEqual(code, 0)
        self.assertIn("RESULT: FAIL (1 failed)", text)
    def test_absent_baseline_and_both_platforms(self):
        self.rules["cases"]["demo"]["mustReturnToBaseline"] = ["Absent"]
        self.write("android", android(), android())
        self.write("web", web(), web())
        code, text = self.run_report()
        self.assertEqual(code, 0)
        self.assertEqual(text.count("### demo ("), 2)
        self.assertEqual(text.count("R1 Absent | 0 | 0 | 0 | 0 | ✅"), 2)
    def test_android_identity_and_top_n(self):
        before, after = android(), android()
        after["classes"].append({"class": "ComposerController", "lib": "other",
                                 "count": 1, "bytes": 500})
        self.rules["defaults"]["topN"] = 1
        self.write("android", before, after)
        code, text = self.run_report()
        self.assertEqual(code, 1)
        self.assertIn("ComposerController [other] |  | 1 | 500 | 0 | 500", text)
        self.assertNotIn("_Uint8List |", text)


if __name__ == "__main__":
    unittest.main()
