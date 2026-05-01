# Changelog

## [2.0.0] - 2026-04-08

### Refocus

Pivoted from a 19-skill general scaffolder into a lean learner plugin (interactive courses + gamified achievements + setup wizard). The native Claude Code plugin ecosystem (`superpowers`, `code-review`, `commit-commands`, `hookify`) made the original "skill bundle" half of the project obsolete; the "pedagogy + onboarding + gamification" half had no native equivalent and remains the core value prop. See `~/.claude/projects/.../memory/project_big_gulps_refocus.md` for the audit rationale.

### Skill changes
- Promoted to `~/.claude/commands/` (no longer scaffolded by this plugin): `/preflight`, `/ready-to-commit`, `/impact-analysis`, `/security-check`, `/code-review`, `/test-gen`
- Already global (no longer scaffolded): `/vibes`, `/double-double`
- Kept in plugin (core value prop): `/learn`, `/achievements`, `/big-gulps-huh`
- Archived: `/health`, `/validate`, `/optimize-review`, `/async-audit`, `/deep-review`, `/plan`, `/retro`, `/future-feature`, `/session-log`

### Plugin structure
- Collapsed dual-copy: `/learn` and `/achievements` now live only in `skills/` at plugin scope (no template copies). Removing the plugin removes them — that's intentional, since they ARE the plugin's value.
- Single-plugin marketplace at `.claude-plugin/marketplace.json` for local install
- 6 courses (added `working-smart`)
- 4 pahu-hau-specific check scripts dropped from `template/scripts/` (`check-async-safety.sh`, `check-theme-tokens.sh`, `check-type-regression.sh`, `check-related-files.sh`)

### Versioning
- Adopted `plugin.json:version` as the single canonical version source. The standalone `VERSION` file has been removed.

## [0.1.0] - 2026-03-21

### Features
- Integrate git-shit for git protection (#1)
- Add permissions for smooth onboarding flow
- Add /retro skill at repo level for self-improvement
- Add START-HERE.md onboarding entry point and passcode bypass
- Add big-gulps-huh skill with onboarding-first design
- Add check scripts, template files, and documentation
- Add 8 portable skills (health, preflight, code-review, deep-review, retro, future-feature, ready-to-commit, vibes)
- Add enhanced /learn skill with course pack engine
- Add 3 preloaded course packs -- Claude Code, Terminal, Git
- Initial commit

### Bug Fixes
- Make skill/course scaffolding reference template files explicitly

### Other
- Add README with onboarding-focused documentation
