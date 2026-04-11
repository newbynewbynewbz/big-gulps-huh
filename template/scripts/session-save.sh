#!/bin/bash
# Session save — auto-saves session context on Stop
# Part of Big Gulps memory persistence system

SESSION_DIR=".claude/sessions"
mkdir -p "$SESSION_DIR"

DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
BRANCH=$(git branch --show-current 2>/dev/null || echo "N/A")
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "N/A")

SESSION_FILE="$SESSION_DIR/${DATE}.tmp"
cat > "$SESSION_FILE" << EOF
timestamp: $TIMESTAMP
branch: $BRANCH
uncommitted_files: $UNCOMMITTED
last_commit: $LAST_COMMIT
EOF

# Keep only last 30 session files
ls -t "$SESSION_DIR"/*.tmp 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null

exit 0
