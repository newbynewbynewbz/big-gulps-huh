---
name: big-gulps-init
description: "Internal: Experience detection, idempotency scan, stack detection (Steps 0-3)"
model-hint: opus
argument: "[passcode]"
---

# Big Gulps Init — Steps 0-3

**Internal sub-skill.** Called by `/big-gulps-huh` coordinator. Do not run directly.

## Step 0: Passcode Check

If the argument includes `--passcode`, skip experience detection:
- Set `$EXPERIENCE = experienced`
- Skip to Step 2 (Context & Idempotency Scan)
- No guided explanations

## Step 1: Experience Detection

Use AskUserQuestion FIRST:

**Question:** "Hey! I'm Claude — I'm going to set up your development environment so you can build things without breaking things. Quick question: have you used Claude Code before?"

**Options:**
1. Nope, first time — show me the ropes
2. A little — I know the basics
3. Yeah, I'm good — just set it up

Store as `$EXPERIENCE`: `new` / `some` / `experienced`

| Answer | $EXPERIENCE | Teaching | Landing Nudge |
|--------|-------------|----------|---------------|
| "Nope" | `new` | Full explanations after each layer | "/learn — start with Claude Code Basics" |
| "A little" | `some` | Light explanations | "Try /learn when exploring" |
| "Yeah" | `experienced` | Status lines only | "/health for project status" |

## Step 2: Detect Context & Idempotency

```bash
git rev-parse --git-dir 2>/dev/null
```

Scan for existing scaffold files:

| Layer | Files to check |
|-------|---------------|
| Git protection | `scripts/git-hooks/` (6 hooks), `.gitshitrc`, `scripts/setup.sh`, `.gitattributes`, `.gitmessage` |
| Claude Code hooks | `.claude/settings.local.json` |
| Check scripts | `scripts/check-console-log.sh`, `check-as-any.sh`, `check-async-safety.sh`, `check-file-size.sh` |
| Skills | `.claude/commands/health.md` (+ 16 others) |
| Courses | `docs/courses/claude-code-basics/course.md` (+ 4 others) |
| Learning state | `.claude/learning-state.json`, `.claude/achievements.json` |
| Audit cache | `.claude/.audit-state.json` |
| Related files | `.claude/related-files.json` |
| CLAUDE.md | `CLAUDE.md` |
| Guide | `docs/BIG_GULPS_GUIDE.md` |

**Migration check:** If `.git/hooks/pre-push` exists but `scripts/git-hooks/` does not, this is a legacy Big Gulps installation. Ask: "Found legacy hooks in .git/hooks/. Replace with git-shit? This upgrades you to 6 hooks with secret scanning, configurable modes, and better git config. Your .gitattributes will also be upgraded." If yes, proceed with install. If no, skip git protection layer.

```
Scaffold scan:
  Git protection:    [present | missing]
  Claude hooks:      [present | missing]
  Check scripts:     [N/8 present]
  Skills:            [N/17 present]
  Courses:           [N/5 present]
  Learning state:    [present | missing]
  Audit cache:       [present | missing]
  CLAUDE.md:         [present | missing]
  Guide:             [present | missing]
```

Skip fully present layers. For partial layers, ask: "Overwrite all, skip existing, or choose per file?"

## Step 3: Auto-Detect Stack

Scan for project files:

| File | Language |
|------|----------|
| `package.json` | TypeScript/JavaScript |
| `tsconfig.json` | TypeScript (confirmed) |
| `pyproject.toml` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |

Detect package manager: bun.lockb → bun, yarn.lock → yarn, etc.

Detect default branch:
```bash
git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|.*/||' || echo "main"
```

### Behavior by $EXPERIENCE:
- **new:** Plain language, no jargon
- **some:** Confirm with brief context
- **experienced:** Ask directly, list findings, offer override

Store as `$LANG`, `$PKG_MGR`, `$DEFAULT_BRANCH`, `$TEST_CMD`, `$LINT_CMD`.
