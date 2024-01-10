#!/usr/bin/env sh

set -eux

flutter pub get
pod install && pod update
