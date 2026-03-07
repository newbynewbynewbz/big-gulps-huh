---
name: big-gulps-huh
description: Full zero-to-hero Claude Code collaboration setup — onboarding, skills, hooks, courses, and a guide that actually explains things.
argument: "[path|new <name>|new <name> --passcode <code>|guide|guide --tone <preset>]"
model-hint: opus
---

# Big Gulps, Huh? — Claude Code Collaboration Scaffolder

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

## Step 0: Passcode Check

If the argument includes `--passcode`, skip the experience detection entirely:
- Set `$EXPERIENCE = experienced`
- Skip to Step 2 (Context & Idempotency Scan)
- No guided explanations — just scaffold everything quickly
- At the end, show a brief summary of what was installed instead of the full landing page

This is for trusted users who've been vouched for and don't need the walkthrough.

## Step 1: Experience Detection

Use AskUserQuestion FIRST, before anything else:

**Question:**
"Hey! I'm Claude — I'm going to set up your development environment so you can build things without breaking things. Quick question: have you used Claude Code before?"

**Options:**
1. Nope, first time — show me the ropes
2. A little — I know the basics
3. Yeah, I'm good — just set it up

Store the answer as `$EXPERIENCE`:

| Answer | $EXPERIENCE | Stack Detection | Teaching | Dial-Back Check | Landing Nudge |
|--------|-------------|-----------------|----------|-----------------|---------------|
| "Nope, first time" | `new` | Auto-detect, explain in plain language | Full explanations after each layer | After Layer 3 | "Type /learn — start with Claude Code Basics" |
| "A little" | `some` | Auto-detect, confirm findings | Light explanations (key facts only) | After Layer 2 | "Try /learn when you're exploring" |
| "Yeah, I'm good" | `experienced` | Ask directly (technical) | Status lines only | Never | "/health for project status" |

## Step 2: Detect Context & Idempotency

```bash
git rev-parse --git-dir 2>/dev/null  # Is this a git repo?
```

Scan for existing scaffold files and report status:

| Layer | Files to check |
|-------|---------------|
| Git protection | `.git/hooks/pre-push`, `pre-commit`, `commit-msg`, `.gitattributes`, `scripts/setup-hooks.sh` |
| Claude Code hooks | `.claude/settings.local.json` |
| Check scripts | `scripts/check-console-log.sh`, `check-as-any.sh`, `check-async-safety.sh`, `check-file-size.sh` |
| Skills | `.claude/commands/health.md` (+ 8 others) |
| Courses | `docs/courses/claude-code-basics/course.md` (+ 2 others) |
| CLAUDE.md | `CLAUDE.md` |
| Guide | `docs/BIG_GULPS_GUIDE.md` |

Print a scan summary:

```
Scaffold scan:
  Git protection:  [present | missing]
  Claude hooks:    [present | missing]
  Check scripts:   [N/4 present]
  Skills:          [N/9 present]
  Courses:         [N/3 present]
  CLAUDE.md:       [present | missing]
  Guide:           [present | missing]
```

**Skip layers that are fully present.** For partially present layers, use AskUserQuestion: "Some [layer] files exist. Overwrite all, skip existing, or choose per file?"

If `new <name>`: create directory, `cd`, `git init`, scaffold everything.
If `guide` or `guide --tone <preset>`: skip to Step 9.

## Step 3: Auto-Detect Stack

Scan for project files to determine the tech stack:

| File | Language | Derived Info |
|------|----------|-------------|
| `package.json` | TypeScript/JavaScript | Read `scripts.test` for test command, `scripts.lint` for linter, check for `typescript` dep |
| `tsconfig.json` | TypeScript (confirmed) | — |
| `pyproject.toml` | Python | Read for pytest, ruff, pyright config |
| `go.mod` | Go | — |
| `Cargo.toml` | Rust | — |

Also detect package manager:
- `bun.lockb` → bun
- `yarn.lock` → yarn
- `pnpm-lock.yaml` → pnpm
- `package-lock.json` → npm
- `Pipfile.lock` or `requirements.txt` → pip
- `go.sum` → go modules
- `Cargo.lock` → cargo

Also detect default branch:
```bash
git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|.*/||' || echo "main"
```

### Behavior by $EXPERIENCE:

**$EXPERIENCE = new:**
Present findings in plain language, no jargon. Example:
"I found TypeScript with npm in this project. That means you're writing JavaScript with extra safety checks, and npm handles your project's dependencies (libraries other people wrote that you can use). All good!"

If nothing detected: "This looks like a fresh project — what language are you planning to use?" with options: TypeScript (Recommended), Python, Go, Rust, Other.

**$EXPERIENCE = some:**
Confirm with brief context. Example:
"Detected: TypeScript + npm. Test runner: vitest. Sound right?"

If nothing detected: ask language with brief descriptions.

**$EXPERIENCE = experienced:**
Ask directly (same questions as below). List findings, offer override.

For experienced users, use AskUserQuestion:

**Question 1 — Primary language:**
- TypeScript/JavaScript (Recommended)
- Python
- Go
- Rust
- Other

**Question 2 — Package manager:**
- npm / bun / yarn / pnpm / pip/uv / cargo / go modules / Other

**Question 3 — Default branch:**
- main (Recommended) / master / Other

**Question 4 — Test runner:**
- Jest / Vitest / Pytest / Go test / Cargo test / Other

**Question 5 — Linter/type checker:**
- tsc + ESLint / Pyright + Ruff / golangci-lint / Clippy / Other

Store as `$LANG`, `$PKG_MGR`, `$DEFAULT_BRANCH`, `$TEST_CMD`, `$LINT_CMD`.

Derive extensions and exclusions:

| Language | `$EXT` | Test exclusions |
|----------|--------|----------------|
| TypeScript | `*.ts\|*.tsx` | `__tests__/`, `__mocks__/`, `*.test.*`, `*.spec.*` |
| Python | `*.py` | `tests/`, `test_*`, `*_test.py` |
| Go | `*.go` | `*_test.go` |
| Rust | `*.rs` | `tests/`, `*_test.rs` |

## Step 4: Git Protection (Inlined)

Write all 3 hooks to `.git/hooks/` and `chmod +x` each one.

### `.git/hooks/pre-push`

Blocks direct pushes to the default branch. Forces PR workflow.

```bash
#!/bin/bash
# Pre-push hook: Blocks direct pushes to $DEFAULT_BRANCH
# Bypass: git push --no-verify (emergencies only)

BRANCH=$(git branch --show-current)
REMOTE="$1"

while read local_ref local_sha remote_ref remote_sha; do
  if [ "$remote_ref" = "refs/heads/$DEFAULT_BRANCH" ] && [ "$BRANCH" = "$DEFAULT_BRANCH" ]; then
    if echo "$local_ref" | grep -q "refs/tags/"; then
      continue
    fi

    echo ""
    echo "Direct push to $DEFAULT_BRANCH blocked"
    echo ""
    echo "  Use the PR workflow instead:"
    echo "    1. git checkout -b feature/my-change"
    echo "    2. git push -u origin feature/my-change"
    echo "    3. gh pr create --fill"
    echo "    4. gh pr merge --squash --delete-branch"
    echo ""
    echo "  Emergency bypass: git push --no-verify"
    echo ""
    exit 1
  fi
done

exit 0
```

Replace `$DEFAULT_BRANCH` with the actual branch name from Step 3.

### `.git/hooks/pre-commit`

Non-blocking warning when staged changes are large.

```bash
#!/bin/bash
# Pre-commit hook: Commit size warning

WARN_THRESHOLD=200

INSERTIONS=$(git diff --cached --numstat | awk '{sum+=$1} END{print sum+0}')

if [ "$INSERTIONS" -gt "$WARN_THRESHOLD" ]; then
  echo ""
  echo "Commit size warning: $INSERTIONS insertions (threshold: $WARN_THRESHOLD)"
  echo ""
  echo "  Staged files:"
  git diff --cached --stat | tail -1
  echo ""
  echo "  Consider splitting into smaller atomic commits."
  echo "  Ask: 'Is this truly ONE logical change?'"
  echo ""
fi

exit 0
```

### `.git/hooks/commit-msg`

Enforces conventional commit prefixes. Blocking.

```bash
#!/bin/bash
# Commit-msg hook: Enforce conventional commit prefixes
# Valid: feat: fix: refactor: docs: test: chore: style: perf: ci: build: revert:

MSG_FILE="$1"
MSG=$(head -1 "$MSG_FILE")

# Allow merge commits
if echo "$MSG" | grep -qE '^Merge '; then
  exit 0
fi

# Allow squash merge commits from GitHub/GitLab
if echo "$MSG" | grep -qE '^\S+.*\(#[0-9]+\)$'; then
  exit 0
fi

# Allow fixup/squash commits (interactive rebase)
if echo "$MSG" | grep -qE '^(fixup|squash)! '; then
  exit 0
fi

# Check for conventional commit prefix
if echo "$MSG" | grep -qE '^(feat|fix|refactor|docs|test|chore|style|perf|ci|build|revert)(\([a-zA-Z0-9_-]+\))?!?: .+'; then
  exit 0
fi

echo ""
echo "Commit message rejected — missing conventional prefix"
echo ""
echo "  Your message:  $MSG"
echo ""
echo "  Required format: <type>(<scope>): <description>"
echo ""
echo "  Types: feat fix refactor docs test chore style perf ci build revert"
echo "  Scope: optional — e.g., feat(auth): or fix(api):"
echo ""
echo "  Examples:"
echo "    feat: add user authentication flow"
echo "    fix(api): prevent crash on empty response"
echo "    docs: update contributing guide"
echo ""
exit 1
```

### Create .gitattributes

Adapt based on `$LANG` and `$PKG_MGR`:

```
# Images — binary, no text diffs
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.webp binary
*.ico binary
*.svg text

# Fonts
*.ttf binary
*.otf binary
*.woff binary
*.woff2 binary

# Lock files — don't try to manually merge, just take one version
$LOCKFILE_ENTRY

# Auto-normalize line endings
* text=auto
```

Lock file entries by package manager:
- npm: `package-lock.json -diff merge=ours`
- bun: `bun.lockb binary`
- yarn: `yarn.lock -diff merge=ours`
- pnpm: `pnpm-lock.yaml -diff merge=ours`
- pip: `requirements.txt -diff merge=ours`
- cargo: `Cargo.lock -diff merge=ours`
- go: `go.sum -diff merge=ours`

### Create PR Template

If remote is GitHub, write `.github/pull_request_template.md`:

```markdown
## What

<!-- One sentence: what does this PR do? -->

## Why

<!-- Why is this change needed? Link to issue if applicable. -->

## How

<!-- Brief description of the approach. -->

## Test Plan

- [ ] Tests pass locally
- [ ] Manual testing done
- [ ] No console.log / debug statements left

## Screenshots

<!-- If UI change, add before/after screenshots. Delete this section if N/A. -->
```

### Create `scripts/setup-hooks.sh`

```bash
#!/bin/bash
# One-command hook installer for new cloners
# Run: bash scripts/setup-hooks.sh

HOOK_DIR=".git/hooks"

if [ ! -d ".git" ]; then
  echo "Not a git repository. Run from project root."
  exit 1
fi

for hook in pre-push pre-commit commit-msg; do
  if [ -f "$HOOK_DIR/$hook" ]; then
    echo "$hook installed"
  else
    echo "$hook missing — check your .git/hooks/ directory"
  fi
done

chmod +x "$HOOK_DIR"/pre-push "$HOOK_DIR"/pre-commit "$HOOK_DIR"/commit-msg 2>/dev/null
echo ""
echo "Done. All hooks are executable."
```

### .gitignore additions

Check if `.gitignore` exists. If not, create one. If it does, append missing entries.

**All languages:**
```
.env
.env.*
.DS_Store
*.log
```

**TypeScript/JavaScript:**
```
node_modules/
dist/
build/
coverage/
.next/
```

**Python:**
```
__pycache__/
*.pyc
.venv/
venv/
dist/
*.egg-info/
.pytest_cache/
```

**Go:**
```
/bin/
/vendor/
```

**Rust:**
```
/target/
```

Don't duplicate entries already in .gitignore.

### Teaching After Layer (Git Protection)

**$EXPERIENCE = new:**
```
Done — installed commit message rules and branch protection.

  From now on, start your commits with what you did:
    feat: added the login button
    fix: the cart wasn't updating
    docs: updated the readme

  This means 6 months from now you can search "feat:" to find
  every feature you ever added.

  Also: you can't push directly to $DEFAULT_BRANCH anymore.
  That's by design — every change goes through a branch and
  pull request, so nothing breaks without review.
```

**$EXPERIENCE = some:**
```
Git hooks installed: commit-msg (conventional prefixes), pre-commit
(size warning at 200+ lines), pre-push (blocks direct pushes to
$DEFAULT_BRANCH). Also added .gitattributes and setup-hooks.sh.
```

**$EXPERIENCE = experienced:**
```
Git protection installed.
```

## Step 5: Scaffold Claude Code Hooks

Write `.claude/settings.local.json` with permissions and hooks.

### Permissions by language

All languages get these base permissions:

```
WebSearch, Bash(git:*), Bash(gh:*), Bash(ls:*), Bash(find:*), Bash(grep:*),
Bash(cat:*), Bash(head:*), Bash(wc:*), Bash(chmod:*), Bash(bash:*),
Bash(echo:*), Bash(mv:*), Bash(tree:*)
```

Add language-specific entries:

| Language | Additional permissions |
|----------|----------------------|
| TypeScript | `Bash(node:*)`, `Bash(npx:*)`, `Bash(tsc:*)`, `Bash($PKG_MGR:*)` |
| Python | `Bash(python3:*)`, `Bash(pip:*)`, `Bash(pytest:*)`, `Bash(pyright:*)`, `Bash(ruff:*)` |
| Go | `Bash(go:*)`, `Bash(golangci-lint:*)` |
| Rust | `Bash(cargo:*)`, `Bash(rustc:*)` |

### Hook wiring

Which check scripts to wire per language:

| Language | Console | Type safety | Async | File size |
|----------|---------|-------------|-------|-----------|
| TypeScript | `check-console-log.sh` | `check-as-any.sh` | `check-async-safety.sh` | `check-file-size.sh` |
| Python | `check-print-stmt.sh` | `check-type-ignore.sh` | *(skip)* | `check-file-size.sh` |
| Go | `check-fmt-print.sh` | *(skip)* | *(skip)* | `check-file-size.sh` |
| Rust | *(skip — clippy)* | *(skip)* | *(skip)* | `check-file-size.sh` |

### settings.local.json template

```json
{
  "permissions": {
    "allow": [
      "WebSearch",
      "Bash(git:*)", "Bash(gh:*)", "Bash(ls:*)", "Bash(find:*)",
      "Bash(grep:*)", "Bash(cat:*)", "Bash(head:*)", "Bash(wc:*)",
      "Bash(chmod:*)", "Bash(bash:*)", "Bash(echo:*)", "Bash(mv:*)",
      "Bash(tree:*)",
      "$LANG_SPECIFIC_PERMISSIONS"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "bash scripts/$CONSOLE_SCRIPT", "timeout": 5 },
          { "type": "command", "command": "bash scripts/$TYPE_SAFETY_SCRIPT", "timeout": 5 },
          { "type": "command", "command": "bash scripts/$ASYNC_SCRIPT", "timeout": 5 },
          { "type": "command", "command": "bash scripts/check-file-size.sh", "timeout": 5 }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "FILE_PATH=$(echo \"$TOOL_INPUT\" | python3 -c \"import sys,json; d=json.load(sys.stdin); print(d.get('file_path',''))\" 2>/dev/null); case \"$FILE_PATH\" in */.env|*/.env.*) echo 'BLOCKED: .env files are immutable. Edit manually.' >&2; exit 2;; *) exit 0;; esac",
            "timeout": 5
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "BRANCH=$(git branch --show-current 2>/dev/null || echo 'N/A') && UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') && echo \"Branch: $BRANCH | Uncommitted: $UNCOMMITTED files\" && if [ ! -f 'docs/courses/claude-code-basics/progress.json' ]; then echo 'Tip: Type /learn to start with Claude Code Basics'; elif [ ! -f 'docs/courses/terminal-basics/progress.json' ]; then echo 'Tip: /learn progress — see what you have covered'; elif [ ! -f 'docs/courses/git-fundamentals/progress.json' ]; then echo 'Tip: /learn quiz — test what you have learned'; else echo 'Tip: /health for project status'; fi",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**Omit hook entries for scripts that don't apply to the chosen language** (see table above). Replace `$CONSOLE_SCRIPT`, `$TYPE_SAFETY_SCRIPT`, `$ASYNC_SCRIPT` with actual filenames, and `$LANG_SPECIFIC_PERMISSIONS` with the actual permission strings.

### Teaching After Layer (Claude Code Hooks)

**$EXPERIENCE = new:**
```
Safety hooks installed! Here's what they do:

  The .env blocker prevents Claude from editing files that
  contain passwords and API keys. That protects your secrets.

  The other hooks are like a spell-checker for code — they'll
  warn you about common mistakes but won't stop you from working.

  The session greeting shows you what branch you're on and how
  many files you haven't committed yet, so you always know
  where you stand.
```

**$EXPERIENCE = some:**
```
Claude Code hooks wired: .env blocker (blocking), console sentinel,
type assertion detector, async safety, file size (all warnings).
Session greeting shows branch + uncommitted count + learning tips.
```

**$EXPERIENCE = experienced:**
```
Claude hooks configured.
```

## Dial-Back Check

**For $EXPERIENCE = new:** Fire this check AFTER Step 5 (Layer 3 of scaffolding).
**For $EXPERIENCE = some:** Fire this check AFTER Step 4 (Layer 2 of scaffolding).
**For $EXPERIENCE = experienced:** Skip entirely.

Use AskUserQuestion:

"Quick check — I've been explaining things as I go. Want me to keep teaching, or just finish setting up?"

Options:
1. Keep explaining — this is helpful
2. Just finish up — I get the idea

If user selects "Just finish up": set `$TEACHING = false`. All remaining layers print status-only output regardless of original $EXPERIENCE level.

## Step 6: Scaffold Check Scripts

Write to `scripts/`. All scripts share the stdin JSON pattern for reading the edited file path from Claude Code hooks.

### `check-console-log.sh` (TypeScript version)

```bash
#!/bin/bash
# Console Statement Sentinel — warns on debug prints (non-blocking)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in *.ts|*.tsx) ;; *) exit 0 ;; esac
case "$FILE_PATH" in */__tests__/*|*/__mocks__/*|*.test.*|*.spec.*|*/jest.setup*|*/.claude/*|*/scripts/*) exit 0 ;; esac

MATCHES=$(grep -nE "console\.(log|warn|error|info|debug|trace)\(" "$FILE_PATH" 2>/dev/null | grep -v "//.*console\." | head -5)
if [ -n "$MATCHES" ]; then
  echo ""
  echo "--- Warning: Console Statements ---"
  echo "File: $(basename "$FILE_PATH")"
  echo "$MATCHES"
  echo "Remove before committing. Use a logger instead."
  echo "-----------------------------------"
fi
exit 0
```

**Python variant** (`check-print-stmt.sh`): Same structure. Match `*.py`, skip `tests/`/`test_*`/`conftest*`. Grep for `\bprint\(` excluding lines with `# noqa`.

**Go variant** (`check-fmt-print.sh`): Same structure. Match `*.go`, skip `*_test.go`. Grep for `fmt\.Print`.

### `check-as-any.sh` (TypeScript only)

```bash
#!/bin/bash
# Type Assertion Sentinel — warns on `as any` (non-blocking)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in *.ts|*.tsx) ;; *) exit 0 ;; esac
case "$FILE_PATH" in */__tests__/*|*/__mocks__/*|*.test.*|*.spec.*|*/.claude/*|*/scripts/*) exit 0 ;; esac

MATCHES=$(grep -nE '\bas any\b' "$FILE_PATH" 2>/dev/null | grep -v "//.*as any" | head -5)
if [ -n "$MATCHES" ]; then
  echo ""
  echo "--- Warning: as any Type Assertion ---"
  echo "File: $(basename "$FILE_PATH")"
  echo "$MATCHES"
  echo "Use proper types or unknown with type guards."
  echo "--------------------------------------"
fi
exit 0
```

**Python variant** (`check-type-ignore.sh`): Same structure. Match `*.py`. Grep for `# type: ignore` without specific error codes in brackets.

### `check-async-safety.sh` (TypeScript only)

```bash
#!/bin/bash
# Async Promise Safety — warns on .then() without .catch() (non-blocking)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in *.ts|*.tsx) ;; *) exit 0 ;; esac
case "$FILE_PATH" in */__tests__/*|*/__mocks__/*|*.test.*|*.spec.*|*/.claude/*|*/scripts/*) exit 0 ;; esac

THEN_LINES=$(grep -nE '\.then\(' "$FILE_PATH" 2>/dev/null | head -10)
[ -z "$THEN_LINES" ] && exit 0

WARNINGS=""
while IFS= read -r line; do
  LINE_NUM=$(echo "$line" | cut -d: -f1)
  END=$((LINE_NUM + 30))
  HAS_CATCH=$(sed -n "${LINE_NUM},${END}p" "$FILE_PATH" 2>/dev/null | grep -c '\.catch(')
  if [ "$HAS_CATCH" -eq 0 ]; then
    WARNINGS="${WARNINGS}${line}\n"
  fi
done <<< "$THEN_LINES"

if [ -n "$WARNINGS" ]; then
  echo ""
  echo "--- Warning: Unguarded Async ---"
  echo "File: $(basename "$FILE_PATH")"
  echo -e "$WARNINGS" | head -5
  echo "Add .catch() to .then() chains."
  echo "--------------------------------"
fi
exit 0
```

### `check-file-size.sh` (All languages)

```bash
#!/bin/bash
# File Size Warning — warns on 500+ line files (non-blocking)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in *.ts|*.tsx|*.js|*.jsx|*.py|*.go|*.rs) ;; *) exit 0 ;; esac
case "$FILE_PATH" in */__tests__/*|*/__mocks__/*|*.test.*|*.spec.*|*/.claude/*|*/scripts/*) exit 0 ;; esac
[ ! -f "$FILE_PATH" ] && exit 0

LINES=$(wc -l < "$FILE_PATH" | tr -d ' ')
if [ "$LINES" -gt 500 ]; then
  echo ""
  echo "--- File Size Warning ---"
  echo "$(basename "$FILE_PATH"): $LINES lines (limit: 500)"
  echo "Extract into smaller modules."
  echo "-------------------------"
fi
exit 0
```

`chmod +x` all scripts after writing.

### Teaching After Layer (Check Scripts)

**If $TEACHING = true and $EXPERIENCE = new:**
```
Check scripts installed! These power the safety hooks from the
previous step.

  When Claude edits a file, these scripts automatically scan it:
  - Console statements (debug prints left in real code)
  - Type safety bypasses (shortcuts that cause bugs later)
  - Missing error handling (promises that fail silently)
  - File size (big files are hard to maintain)

  They warn you but never block you. Think of them as a
  second pair of eyes.
```

**If $TEACHING = true and $EXPERIENCE = some:**
```
Check scripts installed: console sentinel, type assertion detector,
async safety, file size. All non-blocking warnings on Edit|Write.
```

**Otherwise:** Status line only.

## Step 7: Scaffold 9 Portable Skills + 3 Course Packs

Write each skill to `.claude/commands/` as a standalone markdown file with YAML frontmatter. Write the FULL skill content — each must be self-contained.

### Skills to Write

Write these 9 skills exactly as defined in the template files. Each skill is a complete markdown file with YAML frontmatter (name, description, model-hint) followed by the full skill instructions.

1. **health.md** — Project health dashboard. Model hint: haiku. 6 parallel checks (types, tests, deps, TODOs, large files, stats). Auto-detect commands from project files. Report card with grades.

2. **preflight.md** — Pre-push gate. Model hint: haiku. 5 sequential checks. Types and tests are BLOCKING. Debug, lint, large files are WARNING. Verdict: CLEAR TO PUSH or BLOCKED.

3. **code-review.md** — Multi-agent code review. Model hint: sonnet. Routes by file count: 1-3 files = single pass, 4+ files = 3 parallel agents (Architecture+Security, Correctness+Performance, Quality+DX). Verdict: APPROVED / NEEDS CHANGES / BLOCKED.

4. **deep-review.md** — 5-agent deep review. Model hint: sonnet. For significant changes. 5 parallel agents: Architecture, Security, Performance, Correctness, DX. Deduplicate and assign severity.

5. **retro.md** — Post-session retrospective. Model hint: sonnet. 4 parallel agents: Lessons Learned, Skills Auditor, CLAUDE.md Freshness, Workflow Efficiency. Auto-detect scope. Trend analysis. Retro log.

6. **future-feature.md** — Feature backlog manager. Model hint: sonnet. Scan sources, extract features, deduplicate, tier (T1-T4), write backlog, optional build plan.

7. **ready-to-commit.md** — Smart commit prep. Model hint: sonnet. Detect changes, categorize files, route by scope (small/medium/large), chain review + preflight, stage + commit.

8. **learn.md** — Interactive tutor with course pack engine. Model hint: opus. Discovers courses from docs/courses/, shows built-in courses + dynamic project topics. Mentor personalities (Professor/Practitioner/Philosopher). Predict-then-reveal teaching. Progress tracking. Quiz mode. Contribute command for creating new courses.

9. **vibes.md** — Positive mindset priming. No model hint. 10-step flow: streak tracking, breathing, random content categories, web search, interactive presentation, wins, growth questions, rotating focus frameworks, journal, closing energy. Under 5 minutes.

### Course Packs to Scaffold

Create 3 course pack directories under `docs/courses/` with their `course.md` files:

1. **docs/courses/claude-code-basics/course.md** — 5 modules: What Is Claude Code, Skills, CLAUDE.md, Hooks, Working With Claude Effectively. Predict-then-reveal format throughout.

2. **docs/courses/terminal-basics/course.md** — 7 modules: Where Am I, Moving Around, Looking at Files, Finding Things, Creating and Moving Things, Pipes and Redirection, You Don't Need to Memorize This. Prerequisite: claude-code-basics.

3. **docs/courses/git-fundamentals/course.md** — 6 modules: What Is Git, Making Changes, Branches, Pull Requests, When Things Go Wrong, The Hooks That Protect You. Prerequisite: terminal-basics.

### Teaching After Layer (Skills + Courses)

**If $TEACHING = true and $EXPERIENCE = new:**
```
Skills and courses installed!

  Skills are commands you can run anytime:
    /health      — "Is my project working?"
    /preflight   — Run this before pushing code
    /learn       — Interactive lessons (start here!)
    /vibes       — Focus and motivation booster

  Courses are built-in lessons that /learn can teach you:
    1. Claude Code Basics  <- Start here
    2. Terminal Basics
    3. Git Fundamentals

  Type /learn anytime to start learning.
```

**If $TEACHING = true and $EXPERIENCE = some:**
```
9 skills installed: health, preflight, code-review, deep-review,
retro, future-feature, ready-to-commit, learn, vibes.

3 built-in courses: Claude Code Basics, Terminal Basics,
Git Fundamentals. Run /learn to explore.
```

**Otherwise:** Status line only.

## Step 8: Generate CLAUDE.md

Write `CLAUDE.md` with pre-filled universal sections and TODO markers. Replace all `$VARIABLES` with actual values from Step 3.

```markdown
# [Project Name] — CLAUDE.md

> Generated by `/big-gulps-huh`. Fill in the TODOs to make Claude useful for YOUR project.

## Usage Rules

### For Humans
- Always work on feature branches — never commit directly to $DEFAULT_BRANCH
- Use conventional commit messages: `type(scope): description`
- Keep commits atomic — one logical change per commit
- Run `/preflight` before pushing

### For Claude
- Read files before editing — never guess at existing code
- Run type checker after every edit session
- Never edit .env files
- Prefer editing existing files over creating new ones
- Keep files under 500 lines — extract when they grow
- Don't add features or refactor beyond what was asked

## Verification Checklist
- [ ] `$LINT_CMD` passes with 0 errors
- [ ] `$TEST_CMD` passes
- [ ] No debug print statements in production code
- [ ] No type safety bypasses
- [ ] New files have tests

## Clarification Protocol
When a request is ambiguous, Claude MUST ask before implementing:
1. "Which approach do you prefer?" (with trade-offs)
2. "Should this be temporary or permanent?"
3. "What's the expected behavior for edge case X?"
Never guess on architecture decisions.

## Hook Reference
| Hook | Type | What |
|------|------|------|
| .env blocker | Blocking | Prevents editing .env files |
| Console sentinel | Warning | Warns on debug prints |
| Type assertion | Warning | Warns on type safety bypasses |
| Async safety | Warning | Warns on unguarded promises |
| File size | Warning | Warns on 500+ line files |
| Session greeting | Info | Shows branch + uncommitted count + tips |

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Language | $LANG |
| Framework | <!-- TODO --> |
| Test Runner | $TEST_CMD |
| Linter | $LINT_CMD |
| Package Manager | $PKG_MGR |

## Commands
| Command | What |
|---------|------|
| `$TEST_CMD` | Run tests |
| `$LINT_CMD` | Type check / lint |
| <!-- TODO --> | Start dev server |
| <!-- TODO --> | Build for production |

## File Structure
<!-- TODO: Map your actual project structure -->

## Code Patterns
<!-- TODO: Document your patterns -->

## Common Gotchas
- `.env` files are protected — edit manually
- Commits over 200 lines trigger a warning
- Direct pushes to $DEFAULT_BRANCH are blocked — use PR workflow
<!-- TODO: Add project-specific gotchas -->

## Custom Skills
| Skill | What |
|-------|------|
| `/health` | Project health report |
| `/preflight` | Pre-push checks |
| `/code-review` | Multi-agent code review |
| `/deep-review` | 5-agent deep review |
| `/retro` | Post-session retrospective |
| `/future-feature` | Feature backlog management |
| `/ready-to-commit` | Smart commit prep |
| `/learn` | Interactive tutor + courses |
| `/vibes` | Focus priming |
```

## Step 9: Generate Big Gulps Guide

For `$EXPERIENCE = new`, default to sarcastic tone. For `$EXPERIENCE = some` or `$EXPERIENCE = experienced`, use AskUserQuestion to ask tone preference.

Use AskUserQuestion:

**Question — Guide tone:**
- Sarcastic (Recommended) — dry humor, "because someone did this" explanations
- Professional — same content, straight delivery, corporate-safe
- Minimal — just the facts, bullet points only

Write `docs/BIG_GULPS_GUIDE.md` using the corresponding template:

### Template: Sarcastic (default)

```markdown
# The Big Gulps Guide

> "Big gulps, huh? Welp, see ya later!" — Lloyd Christmas, professional optimist

*A sarcastic but genuinely helpful guide to not breaking things.*

---

## What Just Happened

You (or someone who cares about you) just ran `/big-gulps-huh` and scaffolded a complete Claude Code collaboration setup. That means git hooks, AI guardrails, portable skills, and a CLAUDE.md constitution. You now have more safety nets than a Cirque du Soleil performer.

---

## The Rules

### 1. Never Push to Main
The `pre-push` hook will block you. Main is sacred. You work on branches, you make PRs, you get them merged. Not negotiable.
**DYOR:** [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow)

### 2. Conventional Commits or Go Home
Every commit needs a prefix: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, etc. "fixed stuff" is not a commit message, it's a cry for help.
**DYOR:** [Conventional Commits](https://www.conventionalcommits.org/)

### 3. Keep Commits Small
The `pre-commit` hook warns at 200+ lines. If your commit touches 47 files, that's not a commit, that's a hostage situation.
**DYOR:** [Atomic commits](https://www.pauline-vos.nl/atomic-commits/)

### 4. Don't Touch .env Through Claude
The blocker hook will physically prevent it. Credentials in AI chat history is how you end up on Hacker News for the wrong reasons.
**DYOR:** [12-Factor Config](https://12factor.net/config)

---

## The Skills (Your New Superpowers)

| Skill | What It Does | When to Use It |
|-------|-------------|----------------|
| `/health` | Types, tests, deps, TODOs, file sizes | "Is everything still working?" |
| `/preflight` | Pre-push verification suite | Before every push. Every. Single. One. |
| `/code-review` | Multi-agent code review | After finishing a feature, before PR |
| `/deep-review` | 5-agent parallel deep review | Important changes or new architecture |
| `/retro` | Post-session retrospective | End of a work session — captures lessons |
| `/future-feature` | Feature extraction & prioritization | After reviews, feedback, brainstorms |
| `/ready-to-commit` | Smart commit prep | When you're ready to commit (duh) |
| `/learn` | Interactive tutor + built-in courses | When you're new or exploring |
| `/vibes` | Focus priming | Monday mornings. Trust us. |

**Pro tip:** `/preflight` before pushing + `/health` when things feel off. Everything else is bonus XP.

---

## The Courses (Your Learning Path)

| Course | What You'll Learn | Start Here? |
|--------|------------------|-------------|
| Claude Code Basics | Skills, CLAUDE.md, hooks, working with AI | Yes — start here |
| Terminal Basics | Navigating, searching, file operations | After Claude Code Basics |
| Git Fundamentals | Branches, commits, PRs, recovery | After Terminal Basics |

Type `/learn` to see the full menu and pick a course.

---

## The Hooks (Things That Yell at You)

| Hook | What It Checks | Why It Exists (Because Someone Did This) |
|------|---------------|------------------------------------------|
| pre-push | Pushes to main | Pushed untested code to main at 2am. Production went down. |
| pre-commit | Commit size > 200 lines | Made a 3,000-line commit called "updates". Nobody could review it. |
| commit-msg | Commit prefix | Wrote "asdf" as a commit message. Needed to find it 6 months later. |
| .env blocker | .env edits via Claude | AI assistant committed AWS keys to a public repo. |
| Console sentinel | Debug prints | Left `console.log("here")` in production. Users saw it. |
| Type assertion | `as any` usage | Cast everything to `any`. Created 47 runtime errors. |
| Async safety | Missing .catch() | Forgot error handling. App silently failed for 3 days. |
| File size | 500+ lines | Created a 2,400-line "utils.ts". It's still haunted. |
| Session greeting | Branch + status | Started coding on main. Didn't notice for 2 hours. |

---

## The CLAUDE.md (Your Project's Constitution)

The `CLAUDE.md` file has TODO markers. **Fill them in.** This isn't busywork — it's what makes Claude useful for YOUR project instead of giving generic answers.

Priority TODOs:
1. **Tech Stack** — so Claude knows your tools
2. **File Structure** — so Claude finds things without asking
3. **Code Patterns** — so Claude writes code like yours
4. **Common Gotchas** — so Claude skips your past mistakes

Think of it as onboarding docs for an AI that reads fast and knows nothing.

---

## Quick Start

1. **Read this guide** *(gold star)*
2. **Fill in CLAUDE.md TODOs** — Tech Stack, File Structure, Code Patterns minimum
3. **Run `bash scripts/setup-hooks.sh`** to verify hooks
4. **Try `/learn`** to start with Claude Code Basics
5. **Make a test branch:** `git checkout -b test/my-first-branch`
6. **Test commit:** `git commit -m "test: verify hook setup"`
7. **Run `/preflight`** before pushing

All 7 work? Welcome to the guardrail life.

---

## FAQ

**Q: Can I push to main?** No.
**Q: But what if—** No.
**Q: Really small change, promise it's fine?** `git push --no-verify` for genuine emergencies. Use it for convenience and the hooks judge you silently.
**Q: Commit message error?** Prefix with: `feat:` `fix:` `docs:` `refactor:` `test:` `chore:` `style:` `perf:` `ci:` `build:` `revert:`
**Q: Console.log warnings broken?** Working perfectly. Remove your debug statements.
**Q: What's `/learn`?** Built-in courses that teach you Claude Code, terminal, and git — interactively, using your actual project.
**Q: What's `/vibes`?** Productivity science disguised as fun. Try it Monday.

---

## One More Thing

This is a starting point, not a straitjacket:
- Add project-specific hooks as patterns emerge
- Create custom skills for repetitive workflows
- Create your own courses with `/learn contribute`
- Update CLAUDE.md as your project evolves
- Run `/retro` regularly to capture what you've learned

Fewer "oh no" moments. More "oh nice" moments.

---

*Generated by `/big-gulps-huh`*
*DYOR: Do Your Own Research. Links above are starting points, not gospel.*
```

### Template: Professional

Same content as sarcastic template but with straight delivery, no humor. Remove "because someone did this" column. Use formal language. Replace "FAQ" with "Common Questions". Keep all technical content identical. See original big-gulps-huh skill for exact professional template.

### Template: Minimal

Bullet-point only format. No prose sections. Tables for everything. See original big-gulps-huh skill for exact minimal template.

## Step 10: Landing

After all scaffolding is complete, print the landing message calibrated to $EXPERIENCE.

### $EXPERIENCE = new:

```
You're all set! Try this right now:

  1. git checkout -b my-first-branch
  2. Make any small change to any file
  3. git add <that file>
  4. git commit -m "feat: my first commit"

Did it work? That's the hooks in action.

When you're ready to learn more, type: /learn

It has built-in courses on Claude Code, terminal basics, and
git fundamentals — plus it can teach you this specific
codebase once you're ready to dig in.
```

### $EXPERIENCE = some:

```
Setup complete!

  Hooks:
    .git/hooks/pre-push       — PR-only workflow enforced
    .git/hooks/pre-commit     — 200-line commit warning
    .git/hooks/commit-msg     — Conventional commits required

  Claude Code Hooks:
    .claude/settings.local.json — [N] hooks wired

  Skills (9):
    .claude/commands/ — health, preflight, code-review, deep-review,
    retro, future-feature, ready-to-commit, learn, vibes

  Courses (3):
    docs/courses/ — Claude Code Basics, Terminal Basics, Git Fundamentals

  Documentation:
    CLAUDE.md                    — Fill in the TODOs!
    docs/BIG_GULPS_GUIDE.md      — Share with your team

Try /learn when you want to explore the codebase,
or /health for a project status check.
```

### $EXPERIENCE = experienced:

```
Big Gulps scaffolding complete.

  Git Hooks:
    .git/hooks/pre-push       — PR-only workflow enforced
    .git/hooks/pre-commit     — 200-line commit warning
    .git/hooks/commit-msg     — Conventional commits required

  Claude Code Hooks:
    .claude/settings.local.json — [N] hooks wired

  Check Scripts:
    scripts/[list actual scripts written]

  Skills (9):
    .claude/commands/ — health, preflight, code-review, deep-review,
    retro, future-feature, ready-to-commit, learn, vibes

  Courses (3):
    docs/courses/ — Claude Code Basics, Terminal Basics, Git Fundamentals

  Documentation:
    CLAUDE.md                    — Fill in the TODOs!
    docs/BIG_GULPS_GUIDE.md      — Share with your team

  Next steps:
    1. Fill in CLAUDE.md TODOs (Tech Stack, File Structure, Code Patterns)
    2. Run: bash scripts/setup-hooks.sh
    3. Try: /health
    4. Read: docs/BIG_GULPS_GUIDE.md

  Tell your team:
    "Run 'bash scripts/setup-hooks.sh' after cloning"
```
