# big-gulps-huh

> **First time here?** Read [START-HERE.md](START-HERE.md) — it walks you through everything in 10 minutes.

A Claude Code learner plugin. Interactive courses, gamified achievements, and a one-command setup wizard for people new to Claude Code.

Built for friends, family, and anyone joining a project (or starting their own) who wants guardrails, good habits, and a learning path from day one.

## What It Is

Big Gulps Huh is a [Claude Code plugin](https://code.claude.com/docs/en/plugins). Install it once, and you get:

- **`/learn`** — an interactive tutor with 6 built-in courses and predict-then-reveal pedagogy
- **`/achievements`** — a gamified badge tracker for building good habits
- **`/big-gulps-huh`** — a one-shot setup wizard that scaffolds git protection, safety hooks, 8 focused skills, and the full course library into any project

The plugin asks your experience level first and adjusts how much it explains along the way.

## What the Setup Wizard Installs

Running `/big-gulps-huh` in a target project sets up 6 layers:

1. **Git protection** — bundled [git-shit](https://github.com/newbynewbynewbz/git-shit) hooks: secret scanning, conventional commits, PR workflow, branch protection, and smart git config
2. **Claude Code hooks** — safety checks that run automatically (debug statement warnings, `as any` detector, file-size warnings, session save/load)
3. **Check scripts** — shell scripts that power the hooks
4. **Project skills** — 8 scaffolded skills (preflight, ready-to-commit, code-review, security-check, impact-analysis, test-gen, vibes, double-double)
5. **Courses & achievements** — 6 interactive courses, learning progress tracking, audit caching
6. **Documentation** — CLAUDE.md project config + onboarding guide

`/learn` and `/achievements` come from the plugin itself and work as soon as you install it — no scaffolding required.

## Quick Start

Big Gulps Huh is its own single-plugin marketplace. Add the marketplace, then install:

```bash
# Open Claude Code in any project
cd YOUR_PROJECT
claude

# Add the Big Gulps Huh marketplace (once per machine)
/plugin marketplace add /path/to/big-gulps-huh

# Install the plugin
/plugin install big-gulps-huh@big-gulps-huh

# Run the setup wizard
/big-gulps-huh
```

That's it. The wizard handles the rest.

> The `@big-gulps-huh` suffix on `/plugin install` is the marketplace name — the plugin and the marketplace happen to share a name here, which is fine.

## What You Get

```
your-project/
  scripts/
    git-hooks/
      pre-commit               <- Secret scanning + large commit warning
      commit-msg               <- Enforces conventional commit prefixes
      pre-push                 <- Blocks direct pushes to main
      prepare-commit-msg       <- Auto-fills prefix from branch name
      pre-rebase               <- Blocks rebasing pushed commits
      post-merge               <- Reminds to install deps after lock file changes
    setup.sh                   <- One-command setup for teammates
    git-shit-tools.sh          <- Optional tool recommendations
  .claude/
    commands/
      preflight.md              <- Pre-push checks
      ready-to-commit.md        <- Smart commit prep
      code-review.md            <- Multi-agent code review
      security-check.md         <- Security audit
      impact-analysis.md        <- Change blast radius
      test-gen.md               <- Test generator
      vibes.md                  <- Focus priming
      double-double.md          <- Dual worktree dev sessions
    rules/
      safety.md                 <- Core safety rules
      workflow.md               <- Coding discipline rules
    settings.local.json         <- Hooks + permissions
    learning-state.json         <- Learning progress
    achievements.json           <- Badge tracking
    .audit-state.json           <- Audit cache
  scripts/
    check-console-log.sh        <- Debug statement detector
    check-as-any.sh             <- Type assertion detector
    check-file-size.sh          <- Large file detector
    session-load.sh             <- Session state loader
    session-save.sh             <- Session state saver
    pre-compact-save.sh         <- Pre-compaction state saver
    suggest-compact.sh          <- Compact nudge
    hooks-manifest.json         <- Hook configuration
  docs/
    BIG_GULPS_GUIDE.md          <- Onboarding guide
    courses/
      claude-code-basics/       <- Course: how Claude Code works
      terminal-basics/          <- Course: terminal navigation
      git-fundamentals/         <- Course: version control
      security-basics/          <- Course: security fundamentals
      code-review-culture/      <- Course: code review practices
      working-smart/            <- Course: working effectively with AI
  CLAUDE.md                     <- Project config (fill in TODOs)
  .gitattributes                <- Binary + lock file handling
  .gitshitrc                    <- Git hook config (modes, protected branches)
  .gitmessage                   <- Commit message template
  .github/
    pull_request_template.md    <- PR template
```

## The Skills

| Skill | What It Does | Scope |
|-------|-------------|-------|
| `/learn` | Interactive tutor with built-in courses + achievements | Plugin (global) |
| `/achievements` | Badge progress tracker | Plugin (global) |
| `/big-gulps-huh` | One-shot setup wizard (6-phase cascade) | Plugin (global) |
| `/preflight` | Pre-push verification — run before every push | Project (scaffolded) |
| `/ready-to-commit` | Smart commit prep — categorizes, reviews, commits | Project (scaffolded) |
| `/code-review` | Multi-agent code review — routes by file count | Project (scaffolded) |
| `/security-check` | Security audit with scorecard tracking | Project (scaffolded) |
| `/impact-analysis` | Change blast radius analyzer | Project (scaffolded) |
| `/test-gen` | Test gap analyzer + generator | Project (scaffolded) |
| `/vibes` | Research-backed focus & motivation priming | Project (scaffolded) |
| `/double-double` | Dual worktree dev sessions with parallel terminals | Project (scaffolded) |

> **Refocus note (April 2026):** Big Gulps Huh was originally a "scaffolder with 19 skills." It's been refocused into a lean learner plugin. Nine skills from earlier versions (`/health`, `/deep-review`, `/optimize-review`, `/async-audit`, `/retro`, `/future-feature`, `/session-log`, `/validate`, `/plan`) have been retired in favor of native Claude Code features, official plugins (`superpowers`, `code-review`, `hookify`, `commit-commands`), and workspace-level commands.

## The Courses

`/learn` ships with 7 built-in courses designed for people starting from zero:

| Course | What You'll Learn | Prerequisite |
|--------|------------------|-------------|
| **Claude Code Basics** | Skills, CLAUDE.md, hooks, working with AI | None — start here |
| **Terminal Basics** | Navigation, files, searching, pipes | Claude Code Basics |
| **Git Fundamentals** | Branches, commits, PRs, recovery | Terminal Basics |
| **Security Basics** | Auth, secrets, API keys, data protection | Claude Code Basics |
| **Code Review Culture** | Reviewing code, giving feedback, accepting feedback | Terminal Basics |
| **Working Smart with AI** | Context, compaction, planning, commit messages | Claude Code Basics |
| **Extending Claude Code** | Subagents, output styles, hooks, MCP servers | Claude Code Basics |

Courses use a predict-then-reveal teaching method with hands-on exercises. Progress is tracked across sessions via `.claude/learning-state.json`.

### Create Your Own Courses

Anyone can create a course:

```bash
/learn contribute    # Shows the template and suggests topics
```

Courses are just markdown files in `docs/courses/your-topic/course.md`. Drop one in and `/learn` discovers it automatically.

## Achievement System

Work tracked via `.claude/achievements.json`:

- **Badges** — Earned through milestones (first commit, 10 commits, test contributor, blast-radius scout, course marathoner, etc.)
- **Streak tracking** — Consecutive days of commits
- **Skill usage stats** — Which skills you use most
- **Findings fixed** — Issues resolved through audits

Run `/achievements` anytime to check progress and claim earned badges.

## Audit Caching

Review skills cache results via `.claude/.audit-state.json`:

- **60-minute TTL** — Results cached to avoid redundant checks
- **Up to 10 entries** — Recent audits stored for trend analysis
- **Enables skill chaining** — `/ready-to-commit` references recent findings from `/code-review` and `/preflight` without re-running them

## Learning State Tracking

Progress saved across sessions in `.claude/learning-state.json`:

- **Courses completed** — Which courses you've finished
- **Courses in progress** — Where you are in active courses
- **Skill usage** — Which skills you've tried
- **Common mistakes** — Patterns to avoid based on your history
- **Streak days** — Consecutive development days

Enables personalized recommendations and adaptive learning paths.

## For Experienced Devs

Big Gulps uses [git-shit](https://github.com/newbynewbynewbz/git-shit) for git protection — 6 hooks, secret scanning, conventional commits, and 15 git config settings. If you just want git hooks without the learner plugin, install git-shit directly.

## Why This Exists

This came out of building [Pahu Hau](https://github.com/newbynewbynewbz/pahu-hau), a pantry management app for West Side Oahu families. After months of development, friends and family wanted to help but needed:

- Guardrails so they couldn't break things
- The best tools so they'd be productive from day one
- A learning path so they could grow into confident developers

The mission is simple: actually help people. Not give the appearance of helping. Actually help.

## License

MIT — take it, use it, share it.
