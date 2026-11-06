"""Discover class names in the root and workspace Dart libraries."""
import re


CLASS_PATTERN = re.compile(
    r"^\s*(?:abstract\s+|final\s+|base\s+|sealed\s+|mixin\s+|interface\s+)*class\s+(\w+)",
    re.MULTILINE)


def is_section(line):
    if not line or line.startswith("#"):
        return False
    return not line[0].isspace()


def workspace_match(line, in_workspace):
    if not in_workspace:
        return None
    return re.match(r"^  -\s+([^#]+)", line)


def workspace_members(lines):
    in_workspace = False
    for line in lines:
        if line.startswith("workspace:"):
            in_workspace = True
            continue
        if is_section(line):
            in_workspace = False
        match = workspace_match(line, in_workspace)
        if match:
            yield match[1].strip().strip("\"'")


def libraries(root):
    yield root / "lib"
    pubspec = root / "pubspec.yaml"
    if pubspec.exists():
        lines = pubspec.read_text(encoding="utf-8").splitlines()
        yield from (root / member / "lib" for member in workspace_members(lines))


def scan_classes(root):
    names = set()
    for library in libraries(root):
        for source in library.rglob("*.dart"):
            names.update(CLASS_PATTERN.findall(source.read_text(encoding="utf-8")))
    return names
