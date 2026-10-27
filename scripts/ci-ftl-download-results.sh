#!/bin/bash
# Usage: ci-ftl-download-results.sh <ftl-output> <results-dir> <firebase-project-id>
# Copies FTL test_result XML and logcat from GCS into ftl-results/, keeping per-device sub-paths.
FTL_OUTPUT="$1"
RESULTS_DIR="$2"
FIREBASE_PROJECT_ID="$3"

echo "Downloading test results from Firebase Test Lab..."

# Strategy 1: parse gs:// URL directly from gcloud output
GCS_PATH=$(grep -oP "gs://[^\s\"'\[\]]+" "$FTL_OUTPUT" | head -1)

# Strategy 2: parse GCS browser URL and convert to gs://
if [ -z "$GCS_PATH" ]; then
    GCS_BROWSER=$(grep -oP "console\.(cloud|developers)\.google\.com/storage/browser/\K[^\s\"'\[\]]+" "$FTL_OUTPUT" | head -1)
    if [ -n "$GCS_BROWSER" ]; then
        GCS_PATH="gs://${GCS_BROWSER}"
        echo "Extracted GCS path from console URL: $GCS_PATH"
    fi
fi

# Strategy 3: fallback to listing project buckets
if [ -z "$GCS_PATH" ]; then
    echo "GCS path not in gcloud output, trying project bucket lookup..."
    FTL_BUCKET=$(gsutil ls -p "$FIREBASE_PROJECT_ID" 2>/dev/null \
        | grep 'test-lab' | head -1 || true)
    if [ -n "$FTL_BUCKET" ]; then
        GCS_PATH="${FTL_BUCKET}${RESULTS_DIR}"
    fi
fi

if [ -n "$GCS_PATH" ]; then
    mkdir -p ftl-results
    echo "Results GCS path: $GCS_PATH"
    gsutil ls -r "${GCS_PATH}" 2>/dev/null \
        | grep -E '(test_result_.*\.xml|/logcat)$' \
        | while read -r gcs_file; do
            echo "  $gcs_file"
            # Keep the GCS sub-path so per-device files do not overwrite each other.
            rel="${gcs_file#"${GCS_PATH%/}"/}"
            [ "$rel" = "$gcs_file" ] && rel="${gcs_file#gs://}"
            mkdir -p "ftl-results/$(dirname "$rel")"
            gsutil cp "$gcs_file" "ftl-results/$rel" 2>/dev/null || true
          done || true

    xml_count=$(find ftl-results -name 'test_result_*.xml' | wc -l)
    if [ "$xml_count" -gt 0 ]; then
        echo "Downloaded $xml_count result file(s)"
    else
        echo "Warning: no test_result XML files found at $GCS_PATH"
    fi
else
    echo "Warning: could not determine GCS results path"
fi
