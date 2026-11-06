"""Assemble case reports, preserving missing and invalid sample diagnostics."""
from .android import android_sample
from .classes import scan_classes
from .data import load_json
from .model import Comparison
from .render import (COVERAGE, SUMMARY_HEADER, biggest_growth, escape, near_limit_warnings,
                     summary_row, verdict)
from .rules import compare
from .snapshot import web_sample


PLATFORMS = {"android": ("android.json", android_sample), "web": ("heapsnapshot", web_sample)}


class Report:
    def __init__(self, samples, rules, root):
        self.samples, self.rules, self.root = samples, rules, root
        self.names = None
        self.lines, self.failures = [], 0
        self.summary, self.warnings = [], []

    def fail_summary(self, case, platform, config, reason):
        self.summary.append(summary_row(config.get("title", case), platform, f"❌ {reason}"))

    def compare_samples(self, case, paths, platform, config):
        if self.names is None:
            self.names = scan_classes(self.root)
        loader = PLATFORMS[platform][1]
        before, after = (loader(load_json(path), self.rules) for path in paths)
        context = Comparison(before, after, platform, self.rules, config, self.names or set())
        tables, results = compare(context)
        row = summary_row(config.get("title", case), platform, verdict(results), biggest_growth(results))
        self.summary.append(row)
        self.warnings.extend(near_limit_warnings(case, platform, results))
        self.lines.extend(tables + [""])
        self.failures += sum(not result.passed for result in results)

    def sample_paths(self, case, platform):
        suffix = PLATFORMS[platform][0]
        return [self.samples / f"{case}-{label}.{suffix}" for label in ("before", "after")]

    def platform_report(self, case, platform, config):
        paths = self.sample_paths(case, platform)
        exists = [path.exists() for path in paths]
        if not any(exists):
            return False
        self.lines.append(f"### {escape(case)} ({platform})\n")
        if not all(exists):
            label = "before" if not exists[0] else "after"
            self.lines.append(f"missing {label} sample\n")
            self.fail_summary(case, platform, config, f"missing {label} sample")
            self.failures += 1
            return True
        self.validated_comparison(case, paths, platform, config)
        return True

    def validated_comparison(self, case, paths, platform, config):
        try:
            self.compare_samples(case, paths, platform, config)
        except (OSError, ValueError, KeyError, TypeError, IndexError) as error:
            self.lines.append(f"invalid sample: {escape(error)}\n")
            self.fail_summary(case, platform, config, "invalid sample")
            self.failures += 1

    def case_report(self, case, overrides):
        config = dict(self.rules["defaults"], **overrides)
        found = [self.platform_report(case, platform, config) for platform in PLATFORMS]
        if not any(found):
            self.lines.extend([f"### {escape(case)}\n", "no sample\n"])
            self.fail_summary(case, "-", config, "no sample")
            self.failures += 1

    def build(self):
        for case, overrides in self.rules["cases"].items():
            self.case_report(case, overrides)
        result = f"RESULT: FAIL ({self.failures} failed)" if self.failures else "RESULT: PASS"
        lines = SUMMARY_HEADER + self.summary + ["", COVERAGE] + self.lines + [result]
        return "\n".join(lines) + "\n", self.failures, self.warnings


def build_report(samples, rules, root):
    return Report(samples, rules, root).build()
