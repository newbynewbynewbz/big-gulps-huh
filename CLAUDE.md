# Big Gulps Huh

Claude Code scaffolder that sets up a complete collaboration workspace for non-technical collaborators — git protection, safety hooks, 18 skills, 5 courses, and an achievement system — in a single command.

## Tech Stack

- Bash scripts (hook installers, check scripts)
- Markdown (skills as `.md` files in `.claude/commands/`)
- JSON config (settings, learning state, achievements, audit cache)

## How to Use

```bash
# Copy the entry-point skill into any project
mkdir -p YOUR_PROJECT/.claude/commands
cp .claude/commands/big-gulps-huh.md YOUR_PROJECT/.claude/commands/

# Open Claude Code in the target project
cd YOUR_PROJECT
claude

# Run the scaffolder
/big-gulps-huh
```

## Commands (Skills)

All skills live in `.claude/commands/` and are invoked as `/skill-name` inside Claude Code.

| Command | Purpose |
|---------|---------|
| `/big-gulps-huh` | Main entry point — runs full setup on a target project |
| `/big-gulps-init` | Initializes project structure and config files |
| `/big-gulps-hooks` | Installs git hooks and Claude Code safety hooks |
| `/big-gulps-skills` | Deploys all 18 skills to the target project |
| `/big-gulps-docs` | Generates onboarding docs and CLAUDE.md for target project |
| `/big-gulps-git` | Sets up git configuration and branch protection |
| `/big-gulps-landing` | Generates the START-HERE.md onboarding page |
| `/retro` | Post-session retrospective |
| `/sync-git-shit` | Syncs bundled git-shit from workspace repo |

## File Structure

```
big-gulps-huh/
  .claude/
    commands/           <- All skill .md files (the scaffolder's own skills)
    settings.local.json <- Permissions config
  template/
    CLAUDE.md           <- Template that gets copied to scaffolded projects
    big-gulps-huh.md    <- Main scaffolder skill (also the entry point)
    big-gulps-init.md
    big-gulps-hooks.md
    big-gulps-skills.md
    big-gulps-docs.md
    big-gulps-git.md
    big-gulps-landing.md
    retro.md
    docs/               <- Course content that gets deployed
    scripts/            <- Check scripts that get deployed
  README.md             <- Full feature documentation
  START-HERE.md         <- Non-technical onboarding guide
  LICENSE
```

> The `template/` directory contains what gets scaffolded into user projects. Do not edit it here to test scaffolder behavior — scaffold a test project instead.

## Active Gotchas

- Git protection is powered by bundled git-shit (`template/git-shit/`). After updating the git-shit project, run `/sync-git-shit` to update the bundle.
