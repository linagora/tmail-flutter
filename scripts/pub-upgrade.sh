#!/bin/bash

# Check if a package name parameter is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <package_name>"
  echo "  <package_name>: The name of the package to upgrade in all Flutter projects."
  exit 1
fi

package_name_param="$1"

# Function to process a directory containing pubspec.yaml
process_flutter_project() {
  local dir="$1"
  local package="$2"
  local display_name
  
  if [ -f "$dir/pubspec.yaml" ]; then
    # Use 'tmail' for root directory, otherwise use the directory name
    if [ "$dir" = "." ]; then
      display_name="tmail"
    else
      display_name="$dir"
    fi
    
    echo "Found Flutter project: $display_name"
    echo "-----------------------------------------"

    # Run flutter pub upgrade with the specified package
    echo "Running flutter pub upgrade $package in $display_name..."
    (cd "$dir" && flutter pub upgrade "$package")
    if [ $? -ne 0 ]; then
      echo "Error running flutter pub upgrade $package in $display_name."
    fi

    echo "-----------------------------------------"
  fi
}

# Export the function so it's available to subshells
export -f process_flutter_project

# Process the current directory first
process_flutter_project "." "$package_name_param"

# Then process all subdirectories
find . -mindepth 1 -maxdepth 3 -type d -exec bash -c 'process_flutter_project "$1" "$2"' _ {} "$package_name_param" \;