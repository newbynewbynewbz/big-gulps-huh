#!/bin/bash
# cache-hash.sh — Generate file fingerprints for audit caching
# Usage: bash scripts/cache-hash.sh [file-pattern...]
# Returns a short hash based on git diff state of the specified files

# Default to all staged + unstaged changes
if [ $# -eq 0 ]; then
  FINGERPRINT=$(git diff HEAD 2>/dev/null | shasum -a 256 | cut -c1-16)
else
  # Hash changes for specific file patterns
  COMBINED=""
  for pattern in "$@"; do
    COMBINED="${COMBINED}$(git diff HEAD -- $pattern 2>/dev/null)"
    COMBINED="${COMBINED}$(git diff --cached -- $pattern 2>/dev/null)"
    COMBINED="${COMBINED}$(git ls-files --others --exclude-standard -- $pattern 2>/dev/null)"
  done
  FINGERPRINT=$(echo "$COMBINED" | shasum -a 256 | cut -c1-16)
fi

echo "$FINGERPRINT"
