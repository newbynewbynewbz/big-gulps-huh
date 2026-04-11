#!/usr/bin/env bash
# double-double-close.sh -- Universal teardown for dual dev sessions
# Supports native (iOS Simulator) and web (Brave Browser) modes.
# Called by /double-double close. Not meant for direct invocation.
#
# Usage: ./double-double-close.sh <session-json-path>

set -euo pipefail

SESSION_FILE="${1:-.worktrees/.session.json}"

# Resolve project root from session file location
if [[ "$SESSION_FILE" == /* ]]; then
  SESSION_PATH="$SESSION_FILE"
  PROJECT_ROOT="$(dirname "$(dirname "$SESSION_PATH")")"
else
  PROJECT_ROOT="$(pwd)"
  SESSION_PATH="$PROJECT_ROOT/$SESSION_FILE"
fi

if [[ ! -f "$SESSION_PATH" ]]; then
  echo "Error: Session file not found at $SESSION_PATH"
  exit 1
fi

# --- Parse session JSON ---
SESSION_MODE=$(python3 -c "
import json
with open('$SESSION_PATH') as f:
    s = json.load(f)
print(s.get('mode', 'native'))
" 2>/dev/null || echo "native")

WORKTREE_PATHS=$(python3 -c "
import json
with open('$SESSION_PATH') as f:
    s = json.load(f)
for w in s.get('worktrees', []):
    print(w['path'])
" 2>/dev/null || true)

DEVICE_UDIDS=$(python3 -c "
import json
with open('$SESSION_PATH') as f:
    s = json.load(f)
for w in s.get('worktrees', []):
    print(w.get('deviceUDID') or '')
" 2>/dev/null || true)

PORTS=$(python3 -c "
import json
with open('$SESSION_PATH') as f:
    s = json.load(f)
for w in s.get('worktrees', []):
    print(w.get('port', ''))
" 2>/dev/null || true)

echo "=== Double-Double Close (${SESSION_MODE} mode) ==="

# --- Shutdown simulators (native mode only) ---
if [[ "$SESSION_MODE" == "native" ]]; then
  echo "Shutting down simulators..."
  while IFS= read -r udid; do
    if [[ -n "$udid" ]]; then
      echo "  Shutting down $udid..."
      xcrun simctl shutdown "$udid" 2>/dev/null || true
    fi
  done <<< "$DEVICE_UDIDS"
else
  echo "Skipping simulator shutdown (web mode)"
fi

# --- Kill dev server processes on session ports ---
echo "Killing dev server processes..."
while IFS= read -r port; do
  if [[ -n "$port" ]]; then
    pids=$(lsof -ti :"$port" 2>/dev/null || true)
    if [[ -n "$pids" ]]; then
      echo "  Killing processes on port $port: $pids"
      echo "$pids" | xargs kill 2>/dev/null || true
    else
      echo "  Port $port already free"
    fi
  fi
done <<< "$PORTS"

# --- Remove worktrees ---
echo "Removing worktrees..."
# Deduplicate paths (single-worktree mode uses same path twice)
UNIQUE_PATHS=$(echo "$WORKTREE_PATHS" | sort -u)
while IFS= read -r wt_path; do
  if [[ -n "$wt_path" ]]; then
    full_path="$PROJECT_ROOT/$wt_path"
    if [[ -d "$full_path" ]]; then
      echo "  Removing worktree: $wt_path"
      cd "$PROJECT_ROOT"
      git worktree remove "$wt_path" --force 2>/dev/null || {
        echo "  Warning: git worktree remove failed, cleaning up manually..."
        rm -rf "$full_path"
        git worktree prune 2>/dev/null || true
      }
    else
      echo "  Worktree already gone: $wt_path"
    fi
  fi
done <<< "$UNIQUE_PATHS"

# --- Clean up .worktrees directory if empty ---
if [[ -d "$PROJECT_ROOT/.worktrees" ]]; then
  remaining=$(find "$PROJECT_ROOT/.worktrees" -mindepth 1 -not -name '.session.json' | head -1)
  if [[ -z "$remaining" ]]; then
    echo "  Cleaning up empty .worktrees directory"
  fi
fi

# --- Remove session file ---
echo "Removing session state..."
rm -f "$SESSION_PATH"

# --- Prune any orphaned worktree references ---
cd "$PROJECT_ROOT"
git worktree prune 2>/dev/null || true

echo ""
echo "=== Double-Double Session Closed ==="
if [[ "$SESSION_MODE" == "native" ]]; then
  echo "  Simulators shut down"
else
  echo "  Web mode (no simulators to shut down)"
fi
echo "  Dev server processes killed"
echo "  Worktrees removed"
echo "  Session state cleared"
