#!/bin/bash
# Session load — reads last session context on SessionStart
# Part of Big Gulps memory persistence system

SESSION_DIR=".claude/sessions"
LATEST=$(ls -t "$SESSION_DIR"/*.tmp 2>/dev/null | head -1)

if [ -z "$LATEST" ]; then
  exit 0
fi

# Only show if less than 7 days old
FILE_AGE=$(( $(date +%s) - $(stat -f %m "$LATEST" 2>/dev/null || echo 0) ))
if [ "$FILE_AGE" -gt 604800 ]; then
  exit 0
fi

echo "Welcome back! Here's where you left off:"
cat "$LATEST"
