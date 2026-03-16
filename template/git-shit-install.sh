#!/bin/bash
# Git Shit: Install adapter for Big Gulps
# Installs bundled git-shit hooks and config into the current repo.
# Based on git-shit/repo/install.sh — adapted for embedded use.

set -e

# Resolve bundled template directory (sibling to this script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/git-shit"

# Validate: must be run inside a git repo
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "Error: not a git repository. cd into your project first."
  exit 1
}

# Validate: bundled template must exist
if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "Error: bundled git-shit not found at $TEMPLATE_DIR"
  echo "Run /sync-git-shit in the Big Gulps project to populate it."
  exit 1
fi

cd "$REPO_ROOT"

echo ""
echo "Installing git-shit into: $REPO_ROOT"
echo ""

# Auto-detect default branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
if [ -z "$DEFAULT_BRANCH" ]; then
  PROTECTED_BRANCHES="main|master"
  echo "  No remote detected — protecting both main and master"
else
  PROTECTED_BRANCHES="$DEFAULT_BRANCH"
  echo "  Detected default branch: $DEFAULT_BRANCH"
fi

# Copy hooks
mkdir -p scripts/git-hooks
cp "$TEMPLATE_DIR"/git-hooks/* scripts/git-hooks/
chmod +x scripts/git-hooks/*
echo "  Copied 6 hooks -> scripts/git-hooks/"

# Copy setup scripts
mkdir -p scripts
cp "$TEMPLATE_DIR/scripts/setup.sh" scripts/setup.sh
chmod +x scripts/setup.sh
cp "$TEMPLATE_DIR/scripts/setup-hooks.sh" scripts/setup-hooks.sh
chmod +x scripts/setup-hooks.sh
cp "$TEMPLATE_DIR/scripts/git-shit-tools.sh" scripts/git-shit-tools.sh
chmod +x scripts/git-shit-tools.sh
echo "  Copied setup.sh, setup-hooks.sh (compat), git-shit-tools.sh -> scripts/"

# Copy config files
cp "$TEMPLATE_DIR/.gitattributes" .gitattributes
echo "  Copied .gitattributes"

cp "$TEMPLATE_DIR/.gitmessage" .gitmessage
echo "  Copied .gitmessage"

mkdir -p .github
cp "$TEMPLATE_DIR/.github/pull_request_template.md" .github/pull_request_template.md
echo "  Copied PR template -> .github/"

# Copy .gitshitrc (only if not already present — don't overwrite team config)
if [ ! -f ".gitshitrc" ]; then
  sed "s/^PROTECTED_BRANCHES=.*/PROTECTED_BRANCHES=$PROTECTED_BRANCHES/" \
    "$TEMPLATE_DIR/.gitshitrc" > .gitshitrc
  echo "  Created .gitshitrc (PROTECTED_BRANCHES=$PROTECTED_BRANCHES)"
else
  echo "  Skipped .gitshitrc (already exists — keeping team config)"
fi

# Run setup to configure git
echo ""
bash scripts/setup.sh

echo "----------------------------------------"
echo "Done! git-shit installed via Big Gulps."
echo ""
# Note: original git-shit install.sh prints "Next steps" guidance here.
# Big Gulps omits it because big-gulps-git.md handles the teaching layer
# with experience-aware explanations instead.
