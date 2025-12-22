#!/bin/bash
# scout-block.sh - Bash implementation for blocking heavy directories
# Blocks: node_modules, __pycache__, .git/, dist/, build/

# Read stdin
INPUT=$(cat)

# Validate input not empty
if [ -z "$INPUT" ]; then
  echo "ERROR: Empty input" >&2
  exit 2
fi

# Parse JSON using Node.js (eliminates jq dependency) with error handling
COMMAND=$(echo "$INPUT" | node -e "
try {
  const input = require('fs').readFileSync(0, 'utf-8');
  const data = JSON.parse(input);
  if (!data.tool_input || typeof data.tool_input.command !== 'string') {
    console.error('ERROR: Invalid JSON structure');
    process.exit(2);
  }
  console.log(data.tool_input.command);
} catch (error) {
  console.error('ERROR: JSON parse failed');
  process.exit(2);
}
")

# Check if parsing failed
if [ $? -ne 0 ]; then
  exit 2
fi

# Validate command not empty
if [ -z "$COMMAND" ]; then
  echo "ERROR: Empty command" >&2
  exit 2
fi

# Blocked patterns (regex)
BLOCKED="node_modules|__pycache__|\.git/|dist/|build/"

# Check if command matches blocked pattern
if echo "$COMMAND" | grep -qE "$BLOCKED"; then
  echo "ERROR: Blocked directory pattern" >&2
  exit 2
fi

# Allow command (exit 0)
exit 0