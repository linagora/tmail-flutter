#!/usr/bin/env sh

# Install patrol CLI
dart pub global activate patrol_cli

# Enable integration with BrowserStack
sed -i 's/pl.leancode.patrol.PatrolJUnitRunner/pl.leancode.patrol.BrowserstackPatrolJUnitRunner/' android/app/build.gradle

# Secrets
echo "$TMAIL_PATROL_CREDENTIALS" > secrets.env

# Install helper scripts
brew tap leancodepl/tools
brew install mobile-tools
