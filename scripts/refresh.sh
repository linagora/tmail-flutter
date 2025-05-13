#!/bin/bash

# Find all directories containing pubspec.yaml in the current directory
find . -maxdepth 1 -type d -exec sh -c '
  if [ -f "$1/pubspec.yaml" ]; then
    echo "Found Flutter project: $1"
    echo "-----------------------------------------"

    # Run flutter clean
    echo "Running flutter clean in $1..."
    cd "$1" && flutter clean
    if [ $? -ne 0 ]; then
      echo "Error running flutter clean in $1. Skipping..."
      echo "-----------------------------------------"
      continue
    fi

    # Run flutter pub get
    echo "Running flutter pub get in $1..."
    flutter pub get
    if [ $? -ne 0 ]; then
      echo "Error running flutter pub get in $1. Skipping..."
      echo "-----------------------------------------"
      continue
    fi

    # Run dart run build_runner build -d
    echo "Running dart run build_runner build -d in $1..."
    flutter pub run build_runner build -d
    if [ $? -ne 0 ]; then
      echo "Error running dart run build_runner build -d in $1. Skipping..."
    fi

    echo "-----------------------------------------"
  fi
' _ {} \;