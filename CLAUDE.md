# Big Gulps Huh

Claude Code learner plugin — interactive courses, gamified achievements, and a one-command setup wizard for people new to Claude Code. Refocused April 2026 from general scaffolder into a learning-first plugin; see memory `project_big_gulps_refocus.md` for the pivot rationale.

## Tech Stack

- Claude Code plugin (manifest at `.claude-plugin/plugin.json`)
- Markdown skills (`skills/*/SKILL.md`) and commands (`commands/*.md`)
- Bash scripts (`template/scripts/`) for check hooks that get scaffolded into user projects
- JSON config (`learning-state.json`, `achievements.json`, `.audit-state.json`)
- Bundled [git-shit](https://github.com/newbynewbynewbz/git-shit) for git protection

## How to Use

Big Gulps Huh is its own single-plugin marketplace (schema at `.claude-plugin/marketplace.json`). Install once, then run the setup wizard in any project you want to scaffold.

```bash
# Open Claude Code in the target project
cd YOUR_PROJECT
claude

# First time only: add the marketplace (once per machine)
/plugin marketplace add /Users/pecchenino/Desktop/Claude-Projects/big-gulps/big-gulps-huh

# Install the plugin
/plugin install big-gulps-huh@big-gulps-huh

# Run the setup wizard
/big-gulps-huh
```

The `@big-gulps-huh` suffix on `/plugin install` is the marketplace name — the marketplace and the plugin happen to share a name here, which is fine.

For local development of this plugin itself, the setup wizard lives at `commands/big-gulps-huh.md` and loads its templates from `template/`.

## Commands & Skills

| Name | Type | Purpose |
|------|------|---------|
| `/big-gulps-huh` | Command | Setup wizard — runs 6-phase cascade to scaffold a project |
| `/learn` | Skill | Interactive tutor (Socratic courses + project exploration) |
| `/achievements` | Skill | Badge progress tracker |
| `/sync-git-shit` | Dev skill | Refreshes bundled git-shit from the workspace repo |

`/learn` and `/achievements` ship from `skills/` at plugin scope — they are auto-discovered by Claude Code the moment the plugin is installed. They are NOT scaffolded into user projects; a scaffolded project without the plugin installed is a broken state by design. The 8 project-local skills (`preflight`, `ready-to-commit`, `code-review`, `security-check`, `impact-analysis`, `test-gen`, `vibes`, `double-double`) get scaffolded from `template/.claude/commands/` into user projects.

## File Structure

```
big-gulps-huh/
  .claude-plugin/
    plugin.json              <- Plugin manifest (name, version, author)
    marketplace.json         <- Single-plugin marketplace schema (makes the repo locally installable)
  skills/
    learn/SKILL.md           <- Interactive tutor (plugin-level)
    achievements/SKILL.md    <- Badge tracker (plugin-level)
  commands/
    big-gulps-huh.md         <- Setup wizard (6-phase cascade)
  template/                  <- What gets scaffolded into user projects
    CLAUDE.md                <- Template project constitution
    .claude/
      commands/              <- 8 project-local skills (learn/achievements are plugin scope only)
      rules/                 <- safety.md, workflow.md
    docs/
      BIG_GULPS_GUIDE.md     <- Template onboarding guide
      courses/               <- 6 course directories
    scripts/                 <- Check scripts (console, file-size, as-any, lifecycle)
    git-shit/                <- Bundled git protection (synced from git-shit repo)
    git-shit-install.sh      <- Installer script for git-shit bundle
  .claude/
    commands/
      sync-git-shit.md       <- Dev-only skill for syncing git-shit bundle
    settings.local.json      <- Dev permissions
  scripts/
    sync-git-shit.sh         <- Implementation behind /sync-git-shit
  README.md                  <- Plugin overview for users
  START-HERE.md              <- Non-technical onboarding guide
  CHANGELOG.md
  VERSION
  LICENSE
```

> The `template/` directory is what scaffolded projects get. Do not edit it to test scaffolder behavior — scaffold a throwaway test project instead.

## Active Gotchas

- Git protection is powered by bundled git-shit (`template/git-shit/`). After updating the git-shit repo, run `/sync-git-shit` to refresh the bundle.
- `/learn` and `/achievements` live only in `skills/` (plugin scope). There are no template copies — dual-copy was collapsed 2026-04-08.
- The setup wizard resolves templates via `${CLAUDE_PLUGIN_ROOT}` when available. During local dev (before the plugin is installed), it walks up from the command file path to find `<root>/template/`.
