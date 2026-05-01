#!/bin/bash
# SessionStart hook — prints a one-line streak banner from .claude/learning-state.json
# No-ops silently if the state file is missing, unreadable, or malformed.
# Designed to encourage habit-building without interrupting users who haven't started a course.

set -u

STATE_FILE=".claude/learning-state.json"

[ -f "$STATE_FILE" ] || exit 0
[ -r "$STATE_FILE" ] || exit 0

extract_value() {
  local key="$1"
  local file="$2"
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg k "$key" '.[$k] // empty' "$file" 2>/dev/null
  else
    grep -E "\"$key\"[[:space:]]*:" "$file" 2>/dev/null \
      | head -1 \
      | sed -E "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"?([^\",}]*)\"?.*/\1/" \
      | tr -d ' '
  fi
}

extract_in_progress_course() {
  local file="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -r '.courses_in_progress // {} | keys | .[0] // empty' "$file" 2>/dev/null
  else
    grep -E '"courses_in_progress"' "$file" 2>/dev/null \
      | head -1 \
      | sed -E 's/.*"courses_in_progress"[[:space:]]*:[[:space:]]*\{[[:space:]]*"([^"]+)".*/\1/' \
      | grep -v '"courses_in_progress"'
  fi
}

STREAK=$(extract_value "streak_days" "$STATE_FILE")
COURSE=$(extract_in_progress_course "$STATE_FILE")

[ -n "${STREAK:-}" ] && [ "$STREAK" -gt 0 ] 2>/dev/null || exit 0

if [ -n "${COURSE:-}" ]; then
  echo "Streak: Day $STREAK — in progress: $COURSE (run /learn to continue)"
else
  echo "Streak: Day $STREAK — run /learn to keep it going"
fi
