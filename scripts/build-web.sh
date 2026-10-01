#!/usr/bin/env sh

set -eux

# Build web in release mode (lightweight, optimized)
flutter build web --release --no-web-resources-cdn --base-href "/${GITHUB_REPOSITORY##*/}/$FOLDER/"
