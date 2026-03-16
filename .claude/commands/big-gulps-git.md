---
name: big-gulps-git
description: "Internal: Git protection via git-shit (Step 4)"
model-hint: opus
---

# Big Gulps Git — Step 4

**Internal sub-skill.** Called by `/big-gulps-huh` coordinator.

## Git Protection (via git-shit)

Big Gulps delegates git protection to [git-shit](https://github.com/newbynewbynewbz/git-shit).
The bundled copy lives in `template/git-shit/`.

### Pre-flight Checks

Before installing, verify the bundled copy exists and check freshness:

```bash
# Guard: bundled copy must exist
if [ ! -d "$TEMPLATE_DIR/git-shit" ]; then
  echo "Bundled git-shit not found. Run /sync-git-shit to populate it."
  # Exit this step — coordinator can continue with other phases
  exit 1
fi

# Freshness check (non-blocking — warn and continue)
STORED_HASH=$(cat "$TEMPLATE_DIR/.version" 2>/dev/null || echo "")
GIT_SHIT_ROOT="${GIT_SHIT_PATH:-$BG_ROOT/../../git-shit}"
CURRENT_HASH=$(cd "$GIT_SHIT_ROOT" 2>/dev/null && git rev-parse HEAD 2>/dev/null || echo "")

if [ -n "$CURRENT_HASH" ] && [ -n "$STORED_HASH" ] && [ "$STORED_HASH" != "$CURRENT_HASH" ]; then
  if cd "$GIT_SHIT_ROOT" && git cat-file -t "$STORED_HASH" >/dev/null 2>&1; then
    BEHIND=$(cd "$GIT_SHIT_ROOT" && git rev-list "$STORED_HASH..HEAD" --count)
    echo "⚠️  Bundled git-shit is behind by $BEHIND commits."
  else
    echo "⚠️  Bundled git-shit version unknown."
  fi
  echo "   Run /sync-git-shit to update."
elif [ -z "$STORED_HASH" ]; then
  echo "⚠️  No .version file found. Run /sync-git-shit to populate."
fi
```

### Install

Run: `bash $TEMPLATE_DIR/git-shit-install.sh`

This installs into the target project:
- 6 git hooks in `scripts/git-hooks/` (pre-commit with secret scanning, commit-msg, pre-push, prepare-commit-msg, pre-rebase, post-merge)
- `scripts/setup.sh` (teammate onboarding — configures core.hooksPath, merge.ours, 15 git config settings)
- `scripts/setup-hooks.sh` (compat shim → redirects to setup.sh)
- `scripts/git-shit-tools.sh` (optional tool recommendations)
- `.gitshitrc` (config: commit mode, secret scanning, protected branches)
- `.gitattributes` (binary handling, lock file merge strategy, line endings)
- `.gitmessage` (commit message template)
- `.github/pull_request_template.md`

### Post-Install Config

After `git-shit-install.sh` completes, patch `.gitshitrc` in the target project:

```bash
sed -i '' 's/^COMMIT_MSG_MODE=.*/COMMIT_MSG_MODE=strict/' .gitshitrc
sed -i '' "s/^PROTECTED_BRANCHES=.*/PROTECTED_BRANCHES=$DEFAULT_BRANCH/" .gitshitrc
```

Big Gulps defaults to `strict` commit enforcement (git-shit defaults to `warn`) because the target audience benefits from guardrails, not suggestions.

### .gitignore Additions

Git-shit does not manage .gitignore. Add language-specific entries without duplicating existing ones:

| Language | Entries |
|----------|---------|
| TypeScript/JavaScript | `node_modules/`, `dist/`, `.env`, `.env.local` |
| Python | `__pycache__/`, `*.pyc`, `.venv/`, `.env` |
| Go | `/vendor/`, `.env` |
| Rust | `/target/`, `.env` |
| All | `.DS_Store`, `*.log` |

### Teaching After Layer

- **new:** Full explanation of all 6 hooks:
  - **pre-commit:** Scans for secrets (AWS keys, private keys, API tokens) — blocks the commit if found. Also warns on large commits (200+ lines).
  - **commit-msg:** Enforces conventional commit prefixes (`feat:`, `fix:`, `docs:`, etc.) — blocks non-conforming messages.
  - **pre-push:** Blocks direct pushes to the default branch — forces PR workflow.
  - **prepare-commit-msg:** Auto-fills commit prefix from branch name (e.g., `feat/auth/login` → `feat(auth): `).
  - **pre-rebase:** Prevents rebasing commits already pushed to remote — protects shared history.
  - **post-merge:** Reminds you to install dependencies when lock files change.
  - Explain `.gitshitrc` as the config file, and `scripts/setup.sh` as the command teammates run after cloning.
  - Do NOT mention `git-shit-tools.sh` (lazygit/delta/etc. would overwhelm beginners).

- **some:** "Git protection installed: 6 hooks (including secret scanning), conventional commits enforced, 15 git config settings applied. Config in `.gitshitrc`. Run `bash scripts/git-shit-tools.sh` for optional power tools."

- **experienced:** "git-shit installed. `.gitshitrc` for config. `bash scripts/git-shit-tools.sh` for tool recs."
