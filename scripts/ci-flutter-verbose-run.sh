#!/bin/bash
# Patrol parses the output of `flutter --version --machine`, so -v must only reach `flutter run`.
if [ "$1" = run ]; then
    # CanvasKit comes from the local dev server: no gstatic fetch in every fresh browser context.
    exec flutter -v run --no-web-resources-cdn "${@:2}"
fi
exec flutter "$@"
