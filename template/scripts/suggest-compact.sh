#!/bin/bash
# Suggest compact — counts tool calls and nudges compaction at logical boundaries
# PreToolUse hook for Edit|Write — Part of Big Gulps memory persistence system

# Use a counter file keyed by date and project directory
PROJECT_KEY=$(basename "$(pwd)")
COUNTER_FILE="/tmp/claude-compact-$(date +%Y%m%d)-${PROJECT_KEY}"

# Initialize or increment counter
if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE")
  COUNT=$((COUNT + 1))
else
  COUNT=1
fi

echo "$COUNT" > "$COUNTER_FILE"

# At 40 tool calls, suggest compaction
if [ "$COUNT" -eq 40 ]; then
  echo "Hey, we've been going for a while and my memory is getting full. Want to save progress? Type /compact"
fi

# Remind again every 20 calls after that
if [ "$COUNT" -gt 40 ] && [ $(( (COUNT - 40) % 20 )) -eq 0 ]; then
  echo "Reminder: We're at $COUNT tool calls this session. Consider /compact to free up memory."
fi

exit 0
