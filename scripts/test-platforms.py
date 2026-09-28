#!/usr/bin/env python3
"""Finds every package test and runs the @TestOn suites on the backend they need.

No test is registered by hand: a package with a test/ folder joins the CI matrix, and a test
whose @TestOn selector needs a browser runs on Chrome. A selector that neither the VM nor Chrome
can satisfy fails the run instead of being skipped in silence.

Usage:
    test-platforms.py matrix                    JSON list of packages that have tests
    test-platforms.py has-default-tests MODULE  "true" when MODULE has tests for the VM
    test-platforms.py run-annotated MODULE      runs MODULE's Chrome tests

MODULE is "default" for the root package, otherwise the package path.
"""

import json
import os
import platform
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import quote

ROOT = Path(__file__).resolve().parent.parent
# Dart string literals, raw and multi-line included. They are matched before comments, so a
# "//" or "/*" inside a string ('https://…') stays text.
SQ3, DQ3 = "'" * 3, '"' * 3
STRING = "|".join([
    "r" + SQ3 + ".*?" + SQ3,
    "r" + DQ3 + ".*?" + DQ3,
    SQ3 + r"(?:\\.|.)*?" + SQ3,
    DQ3 + r"(?:\\.|.)*?" + DQ3,
    r"r'[^'\n]*'",
    r'r"[^"\n]*"',
    r"'(?:\\.|[^'\\\n])*'",
    r'"(?:\\.|[^"\\\n])*"',
])
LEXEME = re.compile(f"(?P<string>{STRING})|(?P<line_comment>//[^\\n]*)|(?P<block_comment>/\\*)", re.DOTALL)
# Dart block comments nest: /* a /* b */ c */ is one comment.
BLOCK_COMMENT_TOKEN = re.compile(r"/\*|\*/")
# package:test reads @TestOn from the metadata of the first directive only (test_core
# parse_metadata.dart), wherever it sits on the line and next to other annotations.
FIRST_DIRECTIVE = re.compile(r"(?m)^[ \t]*(?:library|import|export|part)\b")
# `TestOn` or `<import prefix>.TestOn`, with Dart identifiers (which may contain `$`) and the
# whitespace Dart allows between tokens.
IDENTIFIER_CHARS = "A-Za-z0-9_$"
IDENTIFIER_NAME = rf"[A-Za-z_$][{IDENTIFIER_CHARS}]*"
TEST_ON_NAME = rf"@\s*(?:(?P<prefix>{IDENTIFIER_NAME})\s*\.\s*)?TestOn(?![{IDENTIFIER_CHARS}])"
ANNOTATION_START = re.compile(TEST_ON_NAME)
# `@X.TestOn` is package:test's TestOn only when X is an import prefix of the file; otherwise
# it is the named constructor `TestOn` of a class X (test_core _resolveConstructor).
IMPORT_PREFIX = re.compile(rf"(?<![{IDENTIFIER_CHARS}])import(?![{IDENTIFIER_CHARS}])[^;]*?\bas\s+({IDENTIFIER_NAME})")
# The argument must be a constant string literal (test_core _parseString): any quote style, raw
# or not, possibly several adjacent literals, never an interpolation.
ANNOTATION_OPEN = re.compile(TEST_ON_NAME + r"\s*\(\s*")
STRING_LITERAL = re.compile(STRING, re.DOTALL)
SPACE = re.compile(r"\s*")
ARGUMENT_END = re.compile(r",?\s*\)")
ESCAPE = re.compile(r"\\(x[0-9A-Fa-f]{2}|u[0-9A-Fa-f]{4}|u\{[0-9A-Fa-f]+\}|.)|\$", re.DOTALL)
SIMPLE_ESCAPES = {"n": "\n", "r": "\r", "t": "\t", "b": "\b", "f": "\f", "v": "\v"}
TOKEN = re.compile(r"\s+|//[^\n]*|/\*.*?\*/|&&|\|\||[!()?:]|[A-Za-z_-][A-Za-z0-9_-]*", re.DOTALL)
IDENTIFIER = re.compile(r"[A-Za-z_-][A-Za-z0-9_-]*\Z")
# Selector variables package:test accepts (test_api platform_selector.dart). Not a test registry.
VALID_VARIABLES = {
    "posix", "dart-vm", "browser", "js", "blink", "google", "wasm",
    "vm", "chrome", "firefox", "safari", "ie", "edge", "node",
    "dart2js", "dart2wasm", "exe", "kernel", "source",
    "windows", "mac-os", "linux", "android", "ios", "none",
}
CHROME_VARIABLES = {"chrome", "browser", "js", "blink", "dart2js"}
HOST_OS = {"Darwin": "mac-os", "Linux": "linux", "Windows": "windows"}


# ---- Discovery ----------------------------------------------------------------------------

def list_test_files():
    """Tracked and new (not ignored) *_test.dart files. git is always present on CI checkouts."""
    command = ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard", "--", "*_test.dart"]
    try:
        result = subprocess.run(command, cwd=ROOT, capture_output=True)
    except OSError as error:
        raise ValueError(f"Cannot discover test files: {error}") from error
    if result.returncode:
        raise ValueError(f"Cannot discover test files (git exit code {result.returncode}): "
                         f"{result.stderr.decode(errors='replace').strip()}")
    paths = (ROOT / os.fsdecode(raw) for raw in result.stdout.split(b"\0") if raw)
    return [path for path in paths if path.is_file()]


def package_of(test_file):
    """The nearest package root above the file, or None."""
    return next((folder for folder in test_file.parents if (folder / "pubspec.yaml").is_file()), None)


def discover_tests():
    """{package root: [test files in its test/ folder]}. integration_test/ has its own workflows."""
    packages = {}
    for test_file in list_test_files():
        package = package_of(test_file)
        if package is None:
            raise ValueError(f"Test has no package root: {test_file.relative_to(ROOT)}")
        if test_file.relative_to(package).parts[0] == "test":
            packages.setdefault(package, []).append(test_file)
    if not packages:
        raise ValueError("No package tests found")
    return packages


def tests_in_module(module):
    package = ROOT if module == "default" else ROOT / module
    tests = discover_tests().get(package)
    if tests is None:
        raise ValueError(f"Unknown test package: {module}")
    return package, tests


# ---- @TestOn selectors (package:test boolean selector grammar) -----------------------------

def tokenize(selector):
    tokens, offset = [], 0
    while offset < len(selector):
        match = TOKEN.match(selector, offset)
        if match is None:
            raise ValueError(f"Invalid platform selector near {selector[offset:]!r}")
        if not match.group().isspace() and not match.group().startswith(("//", "/*")):
            tokens.append(match.group())
        offset = match.end()
    return tokens


class SelectorParser:
    def __init__(self, selector):
        self.tokens = tokenize(selector)
        self.index = 0

    def take(self, token):
        found = self.index < len(self.tokens) and self.tokens[self.index] == token
        self.index += 1 if found else 0
        return found

    def expect(self, token, message):
        if not self.take(token):
            raise ValueError(message)

    def parse(self):
        expression = self.conditional()
        if self.index != len(self.tokens):
            raise ValueError(f"Unexpected selector token: {self.tokens[self.index]}")
        return expression

    def conditional(self):
        expression = self.disjunction()
        if not self.take("?"):
            return expression
        when_true = self.conditional()
        self.expect(":", "Expected ':' in platform selector")
        return ("if", expression, when_true, self.conditional())

    def disjunction(self):
        expression = self.conjunction()
        while self.take("||"):
            expression = ("or", expression, self.conjunction())
        return expression

    def conjunction(self):
        expression = self.primary()
        while self.take("&&"):
            expression = ("and", expression, self.primary())
        return expression

    def primary(self):
        if self.take("!"):
            return ("not", self.primary())
        if self.take("("):
            expression = self.conditional()
            self.expect(")", "Expected ')' in platform selector")
            return expression
        return self.variable()

    def variable(self):
        if self.index == len(self.tokens):
            raise ValueError("Incomplete platform selector")
        name = self.tokens[self.index]
        if not IDENTIFIER.fullmatch(name) or name not in VALID_VARIABLES:
            raise ValueError(f"Unknown platform selector variable: {name}")
        self.index += 1
        return name


OPERATORS = {
    "not": lambda node, active: not evaluate(node[1], active),
    "and": lambda node, active: evaluate(node[1], active) and evaluate(node[2], active),
    "or": lambda node, active: evaluate(node[1], active) or evaluate(node[2], active),
    "if": lambda node, active: evaluate(node[2] if evaluate(node[1], active) else node[3], active),
}


def evaluate(expression, active_variables):
    if isinstance(expression, str):
        return expression in active_variables
    return OPERATORS[expression[0]](expression, active_variables)


def vm_variables():
    """Variables true for `flutter test` on this host's VM."""
    variables = {"vm", "dart-vm", "kernel"}
    host = HOST_OS.get(platform.system())
    if host:
        variables.add(host)
    if host in ("mac-os", "linux"):
        variables.add("posix")
    return variables


def _blank(text):
    """Same length and line breaks, no content, so offsets stay valid across views."""
    return re.sub(r"[^\n]", " ", text)


def dart_views(source):
    """(metadata, code) views of a Dart file that share offsets.

    `metadata` has comments blanked and strings intact, for reading annotation arguments.
    `code` also has strings blanked, for finding annotations, directives and import prefixes,
    so text inside a string or a comment is never mistaken for any of them.
    """
    metadata, code = list(source), list(source)
    for start, end, is_string in lexeme_spans(source):
        blank = _blank(source[start:end])
        code[start:end] = blank
        if not is_string:
            metadata[start:end] = blank
    return "".join(metadata), "".join(code)


def lexeme_spans(source):
    """(start, end, is_string) of every string literal and comment, in source order."""
    spans = []
    match = LEXEME.search(source)
    while match:
        end = block_comment_end(source, match.start()) if match.group("block_comment") else match.end()
        spans.append((match.start(), end, match.group("string") is not None))
        match = LEXEME.search(source, end)
    return spans


def block_comment_end(source, start):
    """End offset of the block comment opening at `start`, counting nested /* */ pairs."""
    depth = 0
    for token in BLOCK_COMMENT_TOKEN.finditer(source, start):
        depth += 1 if token.group() == "/*" else -1
        if depth == 0:
            return token.end()
    return len(source)


def test_on_annotations(code):
    """Matches of package:test's @TestOn in the first directive's metadata (the file header)."""
    directive = FIRST_DIRECTIVE.search(code)
    header_end = directive.start() if directive else len(code)
    prefixes = set(IMPORT_PREFIX.findall(code))
    return [match for match in ANNOTATION_START.finditer(code, 0, header_end)
            if match.group("prefix") is None or match.group("prefix") in prefixes]


def test_selector(test_file):
    """The parsed @TestOn selector of a test file, or None when it has none."""
    metadata, code = dart_views(test_file.read_text(encoding="utf-8"))
    starts = test_on_annotations(code)
    if not starts:
        return None
    if len(starts) > 1:
        raise ValueError("Expected one @TestOn annotation")
    return SelectorParser(read_test_on(metadata, starts[0].start())).parse()


def read_test_on(metadata, start):
    """The selector string of the @TestOn annotation at `start`, as package:test reads it."""
    opening = ANNOTATION_OPEN.match(metadata, start)
    if opening is None:
        raise ValueError("Cannot read @TestOn annotation")
    parts, position = [], opening.end()
    literal = STRING_LITERAL.match(metadata, position)
    while literal:
        parts.append(string_value(literal.group()))
        position = SPACE.match(metadata, literal.end()).end()
        literal = STRING_LITERAL.match(metadata, position)
    if not parts or not ARGUMENT_END.match(metadata, position):
        raise ValueError("@TestOn needs a constant string literal argument")
    return "".join(parts)


def string_value(literal):
    """The value of one Dart string literal: r'…', '…', \"…\", '''…''' or \"\"\"…\"\"\"."""
    raw = literal.startswith("r")
    body = literal[1:] if raw else literal
    quote = body[:3] if body[:3] in (SQ3, DQ3) else body[0]
    content = body[len(quote):-len(quote)]
    return content if raw else ESCAPE.sub(_unescape, content)


def _unescape(match):
    if match.group() == "$":
        raise ValueError("@TestOn must be a constant string, without interpolation")
    code = match.group(1)
    if len(code) > 1:
        return chr(int(code.strip("xu{}"), 16))
    return SIMPLE_ESCAPES.get(code, code)


# ---- Planning and running -----------------------------------------------------------------

def backends_for(test_file, vm):
    """(runs on VM, runs on Chrome) for one test file."""
    selector = test_selector(test_file)
    if selector is None:
        return True, False
    return evaluate(selector, vm), evaluate(selector, CHROME_VARIABLES)


def plan_tests(package, test_files):
    """{'vm': count, 'chrome': [paths relative to the package], 'errors': [messages]}."""
    plan, vm = {"vm": 0, "chrome": [], "errors": []}, vm_variables()
    for test_file in sorted(test_files):
        try:
            on_vm, on_chrome = backends_for(test_file, vm)
        except (ValueError, UnicodeError, OSError) as error:
            plan["errors"].append(f"{test_file.relative_to(ROOT)}: {error}")
            continue
        plan["vm"] += 1 if on_vm else 0
        if on_chrome:
            plan["chrome"].append(test_file.relative_to(package))
        if not (on_vm or on_chrome):
            plan["errors"].append(f"{test_file.relative_to(ROOT)}: @TestOn matches neither the CI VM nor Chrome, "
                                  "so no CI backend can run it")
    return plan


def report_path(module):
    return ROOT / f"test-report-{module.replace('/', '-')}-chrome.json"


def run_chrome(module, package, chrome_tests):
    """Runs all Chrome tests of a package in one `flutter test` call. Returns failure messages.

    One call launches the browser once, and `flutter test` keeps going after a failing or
    non-compiling suite, so every test is attempted before the exit code is checked.
    """
    for relative_path in chrome_tests:
        print(f"Chrome test: {(package / relative_path).relative_to(ROOT)}", flush=True)
    command = ["flutter", "test", "--no-fail-fast", "--platform", "chrome",
               f"--file-reporter=json:{report_path(module)}"] + [str(path) for path in chrome_tests]
    try:
        exit_code = subprocess.run(command, cwd=package).returncode
    except OSError as error:
        return [f"Cannot run Chrome tests for {module}: {error}"]
    return [f"Chrome tests failed for {module} (exit code {exit_code})"] if exit_code else []


def run_annotated(module):
    package, test_files = tests_in_module(module)
    plan = plan_tests(package, test_files)
    failures = list(plan["errors"])
    if plan["chrome"]:
        failures += run_chrome(module, package, plan["chrome"])
    if failures:
        raise ValueError(f"{module}: {len(failures)} test issue(s) after attempting {len(plan['chrome'])} "
                         "Chrome test files:\n" + "\n".join(f"- {failure}" for failure in failures))
    print(f"{module}: all {len(plan['chrome'])} Chrome test files passed", flush=True)


def matrix():
    modules = []
    for package in sorted(discover_tests()):
        path = "default" if package == ROOT else str(package.relative_to(ROOT))
        modules.append({"path": path, "id": quote(path, safe="")})
    print(json.dumps(sorted(modules, key=lambda module: module["path"] != "default")))


def has_default_tests(module):
    package, test_files = tests_in_module(module)
    print("true" if plan_tests(package, test_files)["vm"] else "false")


COMMANDS = {
    ("matrix", 0): lambda _args: matrix(),
    ("has-default-tests", 1): lambda args: has_default_tests(args[0]),
    ("run-annotated", 1): lambda args: run_annotated(args[0]),
}


def main(argv):
    command = COMMANDS.get((argv[0], len(argv) - 1)) if argv else None
    if command is None:
        raise ValueError("Usage: test-platforms.py matrix | has-default-tests MODULE | run-annotated MODULE")
    command(argv[1:])


if __name__ == "__main__":
    try:
        main(sys.argv[1:])
    except ValueError as error:
        print(error, file=sys.stderr)
        sys.exit(1)
