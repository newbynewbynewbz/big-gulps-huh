---
description: "Scaffold a beginner-friendly Claude Code workspace — git protection, safety hooks, 8 focused skills, 5 interactive courses, and an achievement system"
argument-hint: "[path|new <name>|new <name> --passcode <code>|guide|guide --tone <preset>]"
---

# Big Gulps, Huh? — Setup Wizard

The setup wizard for the Big Gulps Huh learner plugin. Scaffolds everything a new Claude Code user needs into a target project in one pass.

## Arguments

| Input | Action |
|-------|--------|
| *(empty)* | Scaffold into current working directory |
| `<path>` | Scaffold into specified project path |
| `new <name>` | Create new dir + `git init` + scaffold |
| `guide` | Just regenerate the Big Gulps Guide |
| `guide --tone pro` | Regenerate guide in professional tone |
| `guide --tone minimal` | Regenerate guide in minimal bullet-point tone |
| `new <name> --passcode <code>` | Skip guided setup — trusted user fast track |

## Template Location

Template files live in the plugin's `template/` directory. Resolve the plugin root via `${CLAUDE_PLUGIN_ROOT}` when available, otherwise find this file's path and walk up to the `big-gulps-huh/` repo root. Templates are at `<root>/template/`.

## Execution Flow

### If argument is `guide` or `guide --tone <preset>`:
Skip directly to **Phase 5** — regenerate the guide only.

### If argument is `new <name>`:
1. `mkdir -p <name>`
2. `cd <name>`
3. `git init`
4. Continue with the full scaffolding flow.

---

## Phase 1 — Detection

### Step 1a: Passcode fast track

If `--passcode` is present:
- Set `$EXPERIENCE = experienced`
- Skip experience detection
- Still run the context scan and stack detection below

### Step 1b: Experience detection

Use `AskUserQuestion`:

> "Hey! I'm Claude — I'm going to set up your development environment so you can build things without breaking things. Quick question: have you used Claude Code before?"

Options:
1. Nope, first time — show me the ropes
2. A little — I know the basics
3. Yeah, I'm good — just set it up

Store as `$EXPERIENCE` (`new` / `some` / `experienced`).

| Answer | `$EXPERIENCE` | Teaching depth | Landing nudge |
|--------|---------------|----------------|---------------|
| "Nope" | `new` | Full explanations after each phase | "/learn — start with Claude Code Basics" |
| "A little" | `some` | Light explanations | "Try /learn when exploring" |
| "Yeah" | `experienced` | Status lines only | "/achievements for progress" |

### Step 1c: Context & idempotency scan

```bash
git rev-parse --git-dir 2>/dev/null
```

Scan for existing scaffold files:

| Layer | Files to check |
|-------|---------------|
| Git protection | `scripts/git-hooks/` (6 hooks), `.gitshitrc`, `scripts/setup.sh`, `.gitattributes`, `.gitmessage` |
| Claude Code hooks | `.claude/settings.local.json` |
| Check scripts | `scripts/check-console-log.sh`, `scripts/check-as-any.sh`, `scripts/check-file-size.sh` |
| Skills | `.claude/commands/preflight.md` (+ 7 others) |
| Courses | `docs/courses/claude-code-basics/course.md` (+ 4 others) |
| Learning state | `.claude/learning-state.json`, `.claude/achievements.json` |
| Audit cache | `.claude/.audit-state.json` |
| CLAUDE.md | `CLAUDE.md` |
| Guide | `docs/BIG_GULPS_GUIDE.md` |

Present the scan results. Skip fully present layers. For partial layers, ask: "Overwrite all, skip existing, or choose per file?"

**Legacy migration:** If `.git/hooks/pre-push` exists but `scripts/git-hooks/` does not, this is a legacy Big Gulps install. Offer to upgrade: "Found legacy hooks in .git/hooks/. Replace with git-shit? This upgrades you to 6 hooks with secret scanning, configurable modes, and better git config."

### Step 1d: Stack detection

Scan for project files:

| File | Language |
|------|----------|
| `package.json` | TypeScript/JavaScript |
| `tsconfig.json` | TypeScript (confirmed) |
| `pyproject.toml` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |

Detect package manager (`bun.lockb` → bun, `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm, else npm).

Detect default branch:
```bash
git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|.*/||' || echo "main"
```

Store `$LANG`, `$PKG_MGR`, `$DEFAULT_BRANCH`, `$TEST_CMD`, `$LINT_CMD`.

---

## Phase 2 — Git Protection (via git-shit)

Big Gulps delegates git protection to [git-shit](https://github.com/newbynewbynewbz/git-shit). The bundled copy lives in `<plugin root>/template/git-shit/`.

### Pre-flight checks

```bash
# Guard: bundled copy must exist
if [ ! -d "$TEMPLATE_DIR/git-shit" ]; then
  echo "Bundled git-shit not found. Run /sync-git-shit to populate it."
  exit 1
fi

# Freshness check (non-blocking)
STORED_HASH=$(cat "$TEMPLATE_DIR/git-shit/.version" 2>/dev/null || echo "")
GIT_SHIT_ROOT="${GIT_SHIT_PATH:-$BG_ROOT/../../git-shit}"
CURRENT_HASH=$(cd "$GIT_SHIT_ROOT" 2>/dev/null && git rev-parse HEAD 2>/dev/null || echo "")
if [ -n "$CURRENT_HASH" ] && [ -n "$STORED_HASH" ] && [ "$STORED_HASH" != "$CURRENT_HASH" ]; then
  echo "⚠️  Bundled git-shit is behind. Run /sync-git-shit to update."
fi
```

### Install

Run: `bash "$TEMPLATE_DIR/git-shit-install.sh"`

This installs into the target project:
- 6 git hooks in `scripts/git-hooks/` (pre-commit with secret scanning, commit-msg, pre-push, prepare-commit-msg, pre-rebase, post-merge)
- `scripts/setup.sh` — teammate onboarding (configures `core.hooksPath` + 15 git settings)
- `scripts/git-shit-tools.sh` — optional tool recommendations
- `.gitshitrc` — config (commit mode, secret scanning, protected branches)
- `.gitattributes`, `.gitmessage`, `.github/pull_request_template.md`

### Post-install config

```bash
sed -i '' 's/^COMMIT_MSG_MODE=.*/COMMIT_MSG_MODE=strict/' .gitshitrc
sed -i '' "s/^PROTECTED_BRANCHES=.*/PROTECTED_BRANCHES=$DEFAULT_BRANCH/" .gitshitrc
```

Big Gulps defaults to `strict` (git-shit defaults to `warn`) because learners benefit from guardrails, not suggestions.

### .gitignore additions

Git-shit doesn't manage `.gitignore`. Add language-specific entries without duplicating existing ones:

| Language | Entries |
|----------|---------|
| TypeScript/JavaScript | `node_modules/`, `dist/`, `.env`, `.env.local` |
| Python | `__pycache__/`, `*.pyc`, `.venv/`, `.env` |
| Go | `/vendor/`, `.env` |
| Rust | `/target/`, `.env` |
| All | `.DS_Store`, `*.log` |

### Teaching after Phase 2

- **new:** Full explanation of the 6 hooks, `.gitshitrc`, and `scripts/setup.sh`. Don't mention `git-shit-tools.sh`.
- **some:** "6 git hooks installed, conventional commits enforced, 15 git settings applied."
- **experienced:** "git-shit installed. `.gitshitrc` for config."

---

## Phase 3 — Claude Code Hooks & Check Scripts

### Step 3a: Write `.claude/settings.local.json`

Base permissions (all languages):
```
WebSearch, Bash(git:*), Bash(gh:*), Bash(ls:*), Bash(find:*), Bash(grep:*),
Bash(cat:*), Bash(head:*), Bash(wc:*), Bash(chmod:*), Bash(bash:*),
Bash(echo:*), Bash(mv:*), Bash(tree:*)
```

Language-specific additions:

| Language | Additional |
|----------|-----------|
| TypeScript | `Bash(node:*)`, `Bash(npx:*)`, `Bash(tsc:*)`, `Bash($PKG_MGR:*)` |
| Python | `Bash(python3:*)`, `Bash(pip:*)`, `Bash(pytest:*)`, `Bash(pyright:*)`, `Bash(ruff:*)` |
| Go | `Bash(go:*)`, `Bash(golangci-lint:*)` |
| Rust | `Bash(cargo:*)`, `Bash(rustc:*)` |

### Step 3b: Wire hooks from `hooks-manifest.json`

Read `<plugin root>/template/scripts/hooks-manifest.json`. For each entry:
- Install only if `languages` includes `$LANG` or `"all"`
- Lifecycle hooks (`SessionStart`, `Stop`, `PreCompact`, `PreToolUse`) are always installed

### Step 3c: Copy check scripts

For each hook wired in Step 3b, copy the corresponding script from `<plugin root>/template/scripts/` into the target project's `scripts/` directory and `chmod +x` it.

### Step 3d: Create `.claude/rules/` directory

Copy `safety.md` and `workflow.md` from the template.

### Teaching after Phase 3

- **new:** Explain what the check scripts do and how they power the hooks.
- **some:** List installed scripts.
- **experienced:** Status line.

**Dial-back check** fires here for `new` users, after Phase 2 for `some` users:
> "Quick check — want me to keep explaining, or just finish setting up?"

---

## Phase 4 — Skills & Courses

### Step 4a: Project-local skills

Copy these 8 project-local skills from `<plugin root>/template/.claude/commands/` into the target project's `.claude/commands/`:

| Skill | Purpose |
|-------|---------|
| `preflight.md` | Pre-push verification checks |
| `ready-to-commit.md` | Smart commit prep with skill chaining |
| `code-review.md` | Multi-agent code review |
| `security-check.md` | Security audit with scorecard |
| `impact-analysis.md` | Change blast radius analyzer |
| `test-gen.md` | Test gap analyzer + generator |
| `vibes.md` | Daily motivation & focus helper |
| `double-double.md` | Dual worktree dev sessions |

`/learn` and `/achievements` come from the plugin itself at user scope — no copy needed.

### Step 4b: Courses

Copy 6 course directories from `<plugin root>/template/docs/courses/` into the target project's `docs/courses/`:
1. `claude-code-basics/`
2. `terminal-basics/`
3. `git-fundamentals/`
4. `security-basics/`
5. `code-review-culture/`
6. `working-smart/`

### Step 4c: Learning state + achievements

Create these files in the target project's `.claude/` directory:

**`learning-state.json`**
```json
{
  "version": 1,
  "experience_level": "$EXPERIENCE",
  "courses_completed": [],
  "courses_in_progress": {},
  "skills_used": {},
  "common_mistakes": [],
  "streak_days": 0,
  "last_session": null
}
```

**`achievements.json`**
```json
{
  "version": 1,
  "badges": {},
  "stats": {
    "total_commits": 0,
    "skills_used": {},
    "findings_fixed": 0,
    "streak_days": 0,
    "longest_streak": 0,
    "last_session": null
  }
}
```

**`.audit-state.json`**
```json
{
  "version": 1,
  "audits": {},
  "max_entries": 10
}
```

### Teaching after Phase 4

- **new:** Recommend starting with `/learn Claude Code Basics`.
- **some:** "8 project skills + 6 courses installed. Run /learn to explore."
- **experienced:** Status line with counts.

---

## Phase 5 — Documentation

### Step 5a: Generate CLAUDE.md

Write `CLAUDE.md` using `<plugin root>/template/CLAUDE.md`. Replace `$VARIABLES` with detected values:
- `$DEFAULT_BRANCH` → actual branch name
- `$LANG`, `$TEST_CMD`, `$LINT_CMD`, `$PKG_MGR`

Auto-fill where possible:
- **Tech Stack** — from stack detection
- **Commands** — from `package.json`, `pyproject.toml`, or `Makefile`
- **Hook Reference** — list installed hooks
- **Custom Skills** — list installed skills (8 project-local + 2 plugin-level)

Leave TODO markers for: File Structure, Code Patterns, Common Gotchas.

### Step 5b: Generate Big Gulps Guide

For `new`, default to the sarcastic tone. For others, ask: Sarcastic / Professional / Minimal.

Write `docs/BIG_GULPS_GUIDE.md` using `<plugin root>/template/docs/BIG_GULPS_GUIDE.md` as the base, swapping tone if requested.

---

## Phase 6 — Landing

### `$EXPERIENCE = new`

```
You're all set! Try this right now:

  1. git checkout -b my-first-branch
  2. Make any small change to any file
  3. git add <that file>
  4. git commit -m "feat: my first commit"

Did it work? That's the hooks in action.

When you're ready to learn more, type: /learn

It has built-in courses on Claude Code, terminal, git,
security basics, code review, and working smart with AI —
plus it can teach you this specific codebase once you're
ready to dig in.
```

### `$EXPERIENCE = some`

```
Setup complete!

  Hooks: 6 git + [N] Claude Code hooks
  Skills (8 project-local + 2 plugin-scope):
    preflight, ready-to-commit, code-review, security-check,
    impact-analysis, test-gen, vibes, double-double
    (/learn and /achievements come from the plugin itself)
  Courses (6): Claude Code Basics, Terminal Basics,
    Git Fundamentals, Security Basics, Code Review Culture,
    Working Smart with AI
  Achievements: Badge tracking enabled
  Audit Cache: Smart caching for review skills

  Documentation:
    CLAUDE.md                    — Fill in the TODOs!
    docs/BIG_GULPS_GUIDE.md      — Share with your team

Try /learn to explore or /achievements to see your progress.
```

### `$EXPERIENCE = experienced`

```
Big Gulps scaffolding complete.

  Git Hooks: 6 (via git-shit)
  Claude Hooks: [N] wired from hooks-manifest.json
  Check Scripts: [list]
  Skills: 8 project-local + 2 plugin-level (/learn, /achievements)
  Courses (6): [list]
  Learning: learning-state.json + achievements.json
  Audit Cache: .audit-state.json (60-min TTL)

  Config:
    .claude/settings.local.json  — Hooks + permissions
    .claude/learning-state.json  — Learning progress
    .claude/achievements.json    — Badge tracking
    .claude/.audit-state.json    — Audit cache

  Documentation:
    CLAUDE.md                    — Fill in the TODOs!
    docs/BIG_GULPS_GUIDE.md      — Share with your team

  Next: fill CLAUDE.md TODOs, run /preflight, read the guide.
```

### Passcode fast track summary

```
Big Gulps complete. 8 project skills + 2 plugin skills (/learn, /achievements), 6 courses, [N] hooks.
CLAUDE.md has TODOs. /preflight for status. /achievements to track progress.
```

---

## What Gets Installed

| Category | Count | Details |
|----------|-------|---------|
| Git hooks | 6 (via git-shit) | pre-commit, commit-msg, pre-push, prepare-commit-msg, pre-rebase, post-merge |
| Claude hooks | 4–8 | Language-filtered from `hooks-manifest.json` |
| Check scripts | 3–5 | Language-filtered from `hooks-manifest.json` |
| Project skills | 8 | Project-local, copied into `.claude/commands/` |
| Plugin skills | 2 | `/learn` + `/achievements` (from plugin) |
| Courses | 6 | Claude Code, Terminal, Git, Security, Code Review, Working Smart |
| Config | 3 | `learning-state.json`, `achievements.json`, `.audit-state.json` |
| Docs | 2 | `CLAUDE.md`, `BIG_GULPS_GUIDE.md` |
