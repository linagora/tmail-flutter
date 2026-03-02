#!/usr/bin/env bash
# Sync pubspec.yaml version using the shared version resolver.
# This ensures all build methods use the same version source.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! GIT_VERSION="$("$SCRIPT_DIR/resolve-version.sh" 2>/dev/null)"; then
  echo "No valid git tag version found, keeping pubspec.yaml version unchanged"
  exit 0
fi

PUBSPEC_FILE="pubspec.yaml"

if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "pubspec.yaml not found"
    exit 1
fi

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" "$PUBSPEC_FILE" | sed 's/version: //')

if [ "$CURRENT_VERSION" = "$GIT_VERSION" ]; then
    echo "Version already in sync: $GIT_VERSION"
    exit 0
fi

echo "Updating version: $CURRENT_VERSION -> $GIT_VERSION"

# Update version in pubspec.yaml (macOS and Linux compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^version: .*/version: $GIT_VERSION/" "$PUBSPEC_FILE"
else
    sed -i "s/^version: .*/version: $GIT_VERSION/" "$PUBSPEC_FILE"
fi

echo "Version synced to $GIT_VERSION"
