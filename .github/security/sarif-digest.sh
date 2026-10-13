#!/usr/bin/env bash
# Prints error/warning results of SARIF files as a compact findings json array.
# Usage: sarif-digest.sh <sarif>...
set -euo pipefail
(( $# )) || { echo '[]'; exit 0; }
jq -s '[.[].runs[] | .tool.driver.name as $t | .results[]?
  | select((.level // "warning") | IN("error", "warning"))
  | {tool: $t, rule: .ruleId, level: (.level // "warning"), text: .message.text,
     at: "\(.locations[0].physicalLocation.artifactLocation.uri // "?"):\(.locations[0].physicalLocation.region.startLine // 0)"}]' "$@"
