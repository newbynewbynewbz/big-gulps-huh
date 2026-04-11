---
name: ready-to-commit
description: Smart commit preparation — categorizes changes, suggests message, chains review + preflight
model-hint: sonnet
---

# Ready to Commit — Smart Skill Router

## Step 1: Detect Changes

```bash
git status --porcelain
git diff --cached --name-only
git diff --name-only
```

If nothing to commit, say so and stop.

## Step 1.5: Check Audit Cache

If `.claude/.audit-state.json` exists, read it. For each audit entry:
- Check if the fingerprint still matches current file state
- Check if the timestamp is within 60 minutes
- If both match, mark that audit as CACHED (skip re-running)

When routing to `/code-review` in Step 3, pass cache status. If a sub-audit is cached with PASS status, skip it and note "(cached)" in output.

## Step 2: Categorize Files

Group changed files by category:
| Category | Patterns |
|----------|----------|
| COMPONENT | `components/**`, `app/**/*.tsx`, `pages/**`, `views/**` |
| SERVICE | `services/**`, `api/**`, `lib/**` |
| TYPE | `types/**`, `*.d.ts`, `interfaces/**` |
| TEST | `__tests__/**`, `*.test.*`, `*.spec.*`, `tests/**` |
| CONFIG | `*.config.*`, `.env*`, `tsconfig*`, `package.json` |
| DOCS | `*.md`, `docs/**` |
| STYLE | `*.css`, `*.scss`, `styles/**` |
| OTHER | everything else |

Show the categorized file list to the user.

## Step 3: Route by Scope

### Small change (1-5 files, single category)
- Suggest a conventional commit message based on the dominant category
- Ask user to confirm or edit

### Medium change (6-15 files, 2-3 categories)
- Run `/code-review` first
- Then suggest commit message with scope
- Ask user to confirm

### Large change (16+ files or 4+ categories)
- Warn: "This looks like it should be multiple commits"
- Suggest how to split by category
- If user insists on single commit, run `/code-review` first with all files in scope

## Step 4: Pre-Commit Chain

Before committing:
1. Run `/preflight` — if BLOCKED, stop and report
2. Stage files: `git add` the relevant files (not `git add -A`)
3. Commit with the agreed message
4. Report success with commit hash

## Step 5: Post-Commit

After successful commit:
- Show `git log --oneline -3` for context
- Ask: "Push to remote?" — if yes, `git push -u origin $(git branch --show-current)`
- Suggest: "Run `/achievements` to check for new badges"
