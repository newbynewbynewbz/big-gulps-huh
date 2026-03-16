# big-gulps-huh

> **First time here?** Read [START-HERE.md](START-HERE.md) — it walks you through everything in 10 minutes.

Complete Claude Code collaboration setup. One command. Everything you need to start building safely.

Built for friends, family, and anyone joining a project (or starting their own) who wants guardrails, good habits, and a learning path from day one.

## What This Does

Run `/big-gulps-huh` and it sets up 6 layers:

1. **Git protection** — [git-shit](https://github.com/newbynewbynewbz/git-shit) hooks: secret scanning, conventional commits, PR workflow, branch protection, and smart git config
2. **Claude Code hooks** — safety checks that run automatically (blocks .env edits, warns on debug statements, type bypasses, big files, hardcoded colors, type regressions, related file changes)
3. **Check scripts** — shell scripts that power the hooks (8+ language-aware checks)
4. **18 skills + 5 courses** — portable tools and built-in lessons
5. **Learning & achievements** — badge tracking, progress state, audit caching
6. **Documentation** — CLAUDE.md project config + onboarding guide

It asks your experience level first and adjusts how much it explains along the way.

## Quick Start

```bash
# Copy the skill file into your project
mkdir -p YOUR_PROJECT/.claude/commands
cp .claude/commands/big-gulps-huh.md YOUR_PROJECT/.claude/commands/

# Open Claude Code in your project
cd YOUR_PROJECT
claude

# Run it
/big-gulps-huh
```

That's it. It handles the rest.

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
      health.md                 <- Project health report
      preflight.md              <- Pre-push checks
      code-review.md            <- Multi-agent code review
      deep-review.md            <- 5-agent deep review
      retro.md                  <- Session retrospective
      future-feature.md         <- Feature backlog
      ready-to-commit.md        <- Smart commit prep
      learn.md                  <- Interactive tutor + courses
      vibes.md                  <- Focus priming
      security-check.md         <- Security audit
      impact-analysis.md        <- Change blast radius
      test-gen.md               <- Test generator
      session-log.md            <- Session persistence
      async-audit.md            <- Async safety audit
      validate.md               <- Project validation
      optimize-review.md        <- Optimization audit
      achievements.md           <- Badge tracker
      double-double.md          <- Dual worktree dev sessions
    settings.local.json         <- Hooks + permissions
    learning-state.json         <- Learning progress
    achievements.json           <- Badge tracking
    related-files.json          <- File dependency map
    .audit-state.json           <- Audit cache
  scripts/
    check-console-log.sh        <- Debug statement detector
    check-as-any.sh             <- Type assertion detector
    check-async-safety.sh       <- Unguarded promise detector
    check-file-size.sh          <- Large file detector
    check-theme-tokens.sh       <- Hardcoded color detector
    check-type-regression.sh    <- Type error tracker
    check-related-files.sh      <- Related file reminder
    double-double-open.sh       <- Dual session launcher
    double-double-close.sh      <- Dual session teardown
    hooks-manifest.json         <- Hook configuration
  docs/
    BIG_GULPS_GUIDE.md          <- Onboarding guide
    courses/
      claude-code-basics/       <- Course: how Claude Code works
      terminal-basics/          <- Course: terminal navigation
      git-fundamentals/         <- Course: version control
      security-basics/          <- Course: security fundamentals
      code-review-culture/      <- Course: code review practices
  CLAUDE.md                     <- Project config (fill in TODOs)
  .gitattributes                <- Binary + lock file handling
  .gitshitrc                    <- Git hook config (modes, protected branches)
  .gitmessage                   <- Commit message template
  .github/
    pull_request_template.md    <- PR template
```

## The Skills

| Skill | What It Does | Pack |
|-------|-------------|------|
| `/health` | Full project health report — types, tests, deps, TODOs, file sizes | Core |
| `/preflight` | Pre-push verification — run before every push | Core |
| `/ready-to-commit` | Smart commit prep — categorizes, reviews, commits | Core |
| `/learn` | Interactive tutor with built-in courses + achievements | Core |
| `/vibes` | Research-backed focus & motivation priming | Core |
| `/code-review` | Multi-agent code review — routes by file count | Reviews |
| `/deep-review` | 5-agent parallel deep review — for significant changes | Reviews |
| `/optimize-review` | 7-domain optimization audit with scored report | Reviews |
| `/security-check` | Security audit with scorecard tracking | Quality |
| `/impact-analysis` | Change blast radius analyzer | Quality |
| `/test-gen` | Test gap analyzer + generator | Quality |
| `/async-audit` | Async safety audit (focused or deep mode) | Quality |
| `/retro` | Post-session retrospective — captures lessons learned | Workflow |
| `/future-feature` | Feature extraction & prioritization from docs/feedback | Workflow |
| `/session-log` | Save session summary to persistent memory | Workflow |
| `/validate` | Project validation framework | Workflow |
| `/achievements` | Badge progress tracker | Workflow |
| `/double-double` | Dual worktree dev sessions with parallel terminals + simulators/browser | Workflow |

## The Courses

`/learn` ships with 5 built-in courses designed for people starting from zero:

| Course | What You'll Learn | Prerequisite |
|--------|------------------|-------------|
| **Claude Code Basics** | Skills, CLAUDE.md, hooks, working with AI | None — start here |
| **Terminal Basics** | Navigation, files, searching, pipes | Claude Code Basics |
| **Git Fundamentals** | Branches, commits, PRs, recovery | Terminal Basics |
| **Security Basics** | Auth, secrets, API keys, data protection | Claude Code Basics |
| **Code Review Culture** | Reviewing code, giving feedback, accepting feedback | Terminal Basics |

Courses use a predict-then-reveal teaching method with hands-on exercises. Progress is tracked across sessions via `.claude/learning-state.json`.

### Create Your Own Courses

Anyone can create a course:

```bash
/learn contribute    # Shows the template and suggests topics
```

Courses are just markdown files in `docs/courses/your-topic/course.md`. Drop one in and `/learn` discovers it automatically.

## Achievement System

Work tracked via `.claude/achievements.json`:

- **Badges** — Earned through milestones (first commit, 10 commits, all tests passing, security audit passed, etc.)
- **Streak tracking** — Consecutive days of commits
- **Skill usage stats** — Which skills you use most
- **Findings fixed** — Issues resolved through audits

Run `/achievements` anytime to check progress and claim earned badges.

## Audit Caching

Review skills cache results via `.claude/.audit-state.json`:

- **60-minute TTL** — Results cached to avoid redundant checks
- **Up to 10 entries** — Recent audits stored for trend analysis
- **Enables fast retros** — `/retro` can reference recent findings without re-running full audits

## Learning State Tracking

Progress saved across sessions in `.claude/learning-state.json`:

- **Courses completed** — Which courses you've finished
- **Courses in progress** — Where you are in active courses
- **Skill usage** — Which skills you've tried
- **Common mistakes** — Patterns to avoid based on your history
- **Streak days** — Consecutive development days

Enables personalized recommendations and adaptive learning paths.

## For Experienced Devs

Big Gulps uses [git-shit](https://github.com/newbynewbynewbz/git-shit) for git protection — 6 hooks, secret scanning, conventional commits, and 15 git config settings. If you just want git hooks without the Claude Code setup, install git-shit directly.

## Why This Exists

This came out of building [Pahu Hau](https://github.com/newbynewbynewbz/pahu-hau), a pantry management app for West Side Oahu families. After months of development, friends and family wanted to help but needed:

- Guardrails so they couldn't break things
- The best tools so they'd be productive from day one
- A learning path so they could grow into confident developers

The mission is simple: actually help people. Not give the appearance of helping. Actually help.

## License

MIT — take it, use it, share it.
