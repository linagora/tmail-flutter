#!/usr/bin/env sh

set -eux
flutter build web --profile --verbose --base-href "/${GITHUB_REPOSITORY##*/}/$FOLDER/"
