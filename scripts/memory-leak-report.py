#!/usr/bin/env python3
"""Compare Android Dart heap samples and V8 snapshots using shared leak rules."""
import argparse
import os
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from memory_report import build_report
from memory_report.data import load_json
from memory_report.render import COVERAGE, escape


def arguments(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("samples_dir", type=Path)
    parser.add_argument("rules", type=Path)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parent.parent)
    return parser.parse_args(argv)


def generate_report(args):
    try:
        return build_report(args.samples_dir, load_json(args.rules), args.repo_root)
    except (OSError, ValueError, KeyError, TypeError) as error:
        return COVERAGE + f"\nInvalid rules: {escape(error)}\n\nRESULT: FAIL (1 failed)\n", 1, []


def append_summary(markdown):
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as stream:
            stream.write(markdown)


def main(argv=None):
    markdown, failures, warnings = generate_report(arguments(argv))
    for warning in warnings:
        print(warning)
    print(markdown, end="")
    append_summary(markdown)
    return 0 if os.environ.get("MEMORY_REPORT_ONLY") == "1" else int(bool(failures))


if __name__ == "__main__":
    raise SystemExit(main())
