#!/bin/bash
# Syncs bundled git-shit from the workspace repo
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BG_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Allow override via env var, fall back to workspace convention
GIT_SHIT_ROOT="${GIT_SHIT_PATH:-$BG_ROOT/../../git-shit}"
GIT_SHIT_TEMPLATE="$GIT_SHIT_ROOT/repo/template"
DEST="$BG_ROOT/template/git-shit"

if [ ! -d "$GIT_SHIT_TEMPLATE" ]; then
  echo "git-shit not found at $GIT_SHIT_TEMPLATE"
  echo "Expected: ~/Desktop/Claude-Projects/git-shit/repo/template/"
  echo "Or set GIT_SHIT_PATH to the git-shit repo root."
  exit 1
fi

# Clean destination
rm -rf "$DEST"
mkdir -p "$DEST"

# Explicit file manifest — only sync what Big Gulps needs
# (excludes .claude/, .DS_Store, and any future git-shit-only files)
cp -R "$GIT_SHIT_TEMPLATE/git-hooks" "$DEST/git-hooks"
cp -R "$GIT_SHIT_TEMPLATE/scripts" "$DEST/scripts"
cp "$GIT_SHIT_TEMPLATE/.gitshitrc" "$DEST/.gitshitrc"
cp "$GIT_SHIT_TEMPLATE/.gitattributes" "$DEST/.gitattributes"
cp "$GIT_SHIT_TEMPLATE/.gitmessage" "$DEST/.gitmessage"
mkdir -p "$DEST/.github"
cp "$GIT_SHIT_TEMPLATE/.github/pull_request_template.md" "$DEST/.github/pull_request_template.md"

# Clean up OS artifacts
find "$DEST" -name .DS_Store -delete

# Store version
GIT_SHIT_HASH=$(cd "$GIT_SHIT_ROOT" && git rev-parse HEAD)
echo "$GIT_SHIT_HASH" > "$BG_ROOT/template/.version"

echo "Synced git-shit @ $(echo $GIT_SHIT_HASH | head -c 7)"
echo "Files copied to template/git-shit/"
