#!/bin/bash
# Patrol parses the output of `flutter --version --machine`, so -v must only reach `flutter run`.
if [ "$1" = run ]; then
    exec flutter -v "$@"
fi
exec flutter "$@"
