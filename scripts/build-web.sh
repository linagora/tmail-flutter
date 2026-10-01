#!/usr/bin/env sh

set -eux

# Pinned browser libs (web/js/vendor) must exist before Flutter copies web/
sh "$(dirname "$0")/fetch-web-vendor.sh"

# Build web in release mode (lightweight, optimized)
flutter build web --release --no-web-resources-cdn --base-href "/${GITHUB_REPOSITORY##*/}/$FOLDER/"
