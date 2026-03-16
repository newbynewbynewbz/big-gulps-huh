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

## How It Works

This is a coordinator skill. It calls 6 sub-skills in order:

1. **`/big-gulps-init`** — Experience detection, idempotency scan, stack detection
2. **`/big-gulps-git`** — Git hooks, .gitattributes, .gitignore
3. **`/big-gulps-hooks`** — Claude Code hooks + check scripts (language-aware via hooks-manifest.json)
4. **`/big-gulps-skills`** — Skill selection + installation (experience-aware packs)
5. **`/big-gulps-docs`** — CLAUDE.md + Big Gulps Guide generation
6. **`/big-gulps-landing`** — Landing message + onboarding nudge

## Execution Flow

### If argument is `guide` or `guide --tone <preset>`:
Skip directly to Step 5 (`/big-gulps-docs`) — regenerate guide only.

### If argument is `new <name>`:
1. Create directory: `mkdir -p <name>`
2. `cd <name>`
3. `git init`
4. Continue with full scaffolding flow

### Full Scaffolding Flow:

#### Phase 1: Detection (Steps 0-3)
Execute `/big-gulps-init`. This returns:
- `$EXPERIENCE` (new / some / experienced)
- `$LANG`, `$PKG_MGR`, `$DEFAULT_BRANCH`, `$TEST_CMD`, `$LINT_CMD`
- Idempotency scan results (which layers to skip)

Pass `--passcode` to init if provided in arguments.

#### Phase 2: Git Protection (Step 4)
Execute `/big-gulps-git` with detected stack variables. Installs bundled git-shit (6 hooks, config, git settings).
Skip if idempotency scan shows git protection already present.
Requires bundled git-shit in `template/git-shit/` — run `/sync-git-shit` if missing.

#### Phase 3: Hooks & Scripts (Steps 5-6)
Execute `/big-gulps-hooks` with detected stack variables.
Skip if idempotency scan shows hooks already present.

Dial-back check fires here:
- For `$EXPERIENCE = new`: After this phase
- For `$EXPERIENCE = some`: After Phase 2

"Quick check — want me to keep explaining, or just finish setting up?"

#### Phase 4: Skills & Courses (Step 7)
Execute `/big-gulps-skills` with experience level.
Installs skills (18), courses (5), learning state, and achievements.
Skip individual items that idempotency scan found present.

#### Phase 5: Documentation (Steps 8-9)
Execute `/big-gulps-docs` with all detected variables.
Generates CLAUDE.md and Big Gulps Guide.

#### Phase 6: Landing (Step 10)
Execute `/big-gulps-landing` with experience level.
Shows the appropriate welcome message.

## Template Location

Sub-skills find template files relative to this skill's location:
- If this skill is at `/path/to/big-gulps-huh/.claude/commands/big-gulps-huh.md`
- Templates are at `/path/to/big-gulps-huh/template/`

## What Gets Installed

| Category | Count | Details |
|----------|-------|---------|
| Git hooks | 6 (via git-shit) | pre-commit (secret scanning), commit-msg, pre-push, prepare-commit-msg, pre-rebase, post-merge |
| Claude hooks | 8+ | Language-filtered from hooks-manifest.json |
| Check scripts | Up to 8 | Language-filtered from hooks-manifest.json |
| Skills | Up to 18 | Experience-filtered by skill packs |
| Courses | 5 | Claude Code, Terminal, Git, Security, Code Review |
| Config | 4 | learning-state, achievements, related-files, audit-state |
| Docs | 2 | CLAUDE.md, BIG_GULPS_GUIDE.md |
