# big-gulps-huh

Complete Claude Code collaboration setup. One command. Everything you need to start building safely.

Built for friends, family, and anyone joining a project (or starting their own) who wants guardrails, good habits, and a learning path from day one.

## What This Does

Run `/big-gulps-huh` and it sets up 5 layers:

1. **Git protection** — hooks that enforce PR workflow, conventional commits, and small atomic commits
2. **Claude Code hooks** — safety checks that run automatically (blocks .env edits, warns on debug statements, type bypasses, big files)
3. **Check scripts** — shell scripts that power the hooks
4. **9 skills + 3 courses** — portable tools and built-in lessons
5. **Documentation** — CLAUDE.md project config + onboarding guide

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
  .git/hooks/
    pre-push                    <- Blocks pushes to main
    pre-commit                  <- Warns on big commits
    commit-msg                  <- Enforces feat:/fix:/docs: prefixes
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
    settings.local.json         <- Hooks + permissions
  scripts/
    setup-hooks.sh              <- Hook installer for teammates
    check-console-log.sh        <- Debug statement detector
    check-as-any.sh             <- Type assertion detector
    check-async-safety.sh       <- Unguarded promise detector
    check-file-size.sh          <- Large file detector
  docs/
    BIG_GULPS_GUIDE.md          <- Onboarding guide
    courses/
      claude-code-basics/       <- Course: how Claude Code works
      terminal-basics/          <- Course: terminal navigation
      git-fundamentals/         <- Course: version control
  CLAUDE.md                     <- Project config (fill in TODOs)
  .gitattributes                <- Binary + lock file handling
  .github/
    pull_request_template.md    <- PR template
```

## The Skills

| Skill | What It Does |
|-------|-------------|
| `/health` | Full project health report — types, tests, deps, TODOs, file sizes |
| `/preflight` | Pre-push verification — run before every push |
| `/code-review` | Multi-agent code review — routes by file count |
| `/deep-review` | 5-agent parallel deep review — for significant changes |
| `/retro` | Post-session retrospective — captures lessons learned |
| `/future-feature` | Feature extraction & prioritization from docs/feedback |
| `/ready-to-commit` | Smart commit prep — categorizes, reviews, commits |
| `/learn` | Interactive tutor with built-in courses |
| `/vibes` | Research-backed focus & motivation priming |

## The Courses

`/learn` ships with 3 built-in courses designed for people starting from zero:

| Course | What You'll Learn | Prerequisite |
|--------|------------------|-------------|
| **Claude Code Basics** | Skills, CLAUDE.md, hooks, working with AI | None — start here |
| **Terminal Basics** | Navigation, files, searching, pipes | Claude Code Basics |
| **Git Fundamentals** | Branches, commits, PRs, recovery | Terminal Basics |

Courses use a predict-then-reveal teaching method with hands-on exercises. Progress is tracked across sessions.

### Create Your Own Courses

Anyone can create a course:

```bash
/learn contribute    # Shows the template and suggests topics
```

Courses are just markdown files in `docs/courses/your-topic/course.md`. Drop one in and `/learn` discovers it automatically.

## For Experienced Devs

If you just want git hooks without the Claude Code setup, check out [git-shit](https://github.com/newbynewbynewbz/git-shit) — same hooks, no AI tooling.

## Why This Exists

This came out of building [Pahu Hau](https://github.com/newbynewbynewbz/pahu-hau), a pantry management app for West Side Oahu families. After months of development, friends and family wanted to help but needed:

- Guardrails so they couldn't break things
- The best tools so they'd be productive from day one
- A learning path so they could grow into confident developers

The mission is simple: actually help people. Not give the appearance of helping. Actually help.

## License

MIT — take it, use it, share it.
