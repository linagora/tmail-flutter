#!/usr/bin/env sh

set -eux

flutter pub get
# Remove Podfile.lock to ensure pods regenerate with correct deployment target
rm -f Podfile.lock
pod install && pod update
