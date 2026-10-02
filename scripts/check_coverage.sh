#!/usr/bin/env bash
set -euo pipefail
INFO="${1:-coverage/lcov.info}"
MIN="${2:-70}"
test -s "$INFO"
SUMMARY="$(lcov --summary "$INFO" 2>&1)"
echo "$SUMMARY"
RATE="$(printf "%s\n" "$SUMMARY" | awk -F: '/lines.*:/{gsub(/%/,"",$2); gsub(/ /,"",$2); print $2; exit}')"
awk -v rate="$RATE" -v min="$MIN" 'BEGIN { if (rate+0 < min+0) { printf "Coverage %.2f%% is below required %.2f%%\n", rate, min; exit 1 } }'
echo "Coverage gate passed: " "$RATE" "% >= " "$MIN" "%"
