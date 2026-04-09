---
name: preflight
description: "Pre-push verification — types, tests, lint, debug statements, large files. Modes: quick, full (default), pre-commit, pre-pr"
argument: "[mode: quick|full|pre-commit|pre-pr]"
model-hint: haiku
---

# Preflight Checks

## Mode Selection

| Mode | What It Runs | When to Use |
|------|-------------|-------------|
| `quick` | Types only | Fast sanity check while coding |
| `full` *(default)* | All 5 checks | Before pushing |
| `pre-commit` | Types + lint + debug statements | Before committing |
| `pre-pr` | All 5 checks + security scan | Before opening a PR |

If no mode argument is given, default to `full`.

Run checks sequentially. Stop on first blocking failure.

## Step 0: Check Audit Cache

Read `.claude/.audit-state.json` if it exists. For each check below:
- If a matching audit entry exists with the same file fingerprint and timestamp < 60 minutes old, skip that check
- Print "(cached — last passed X minutes ago)" for skipped checks
- Always re-run checks if no cache or cache expired

## Check 1: Type Safety (BLOCKING)
Run the project's type checker. If errors > 0, report them and STOP. Do not proceed.

## Check 2: Test Suite (BLOCKING)
Run the project's test command. If any tests fail, report them and STOP.

## Check 3: Debug Statements (WARNING)
Search source files (not tests, not scripts, not .claude/) for debug print statements:
- TypeScript/JavaScript: `console.(log|warn|error|info|debug|trace)(`
- Python: `print(` and `breakpoint()`
- Go: `fmt.Print`
- Rust: `println!` and `dbg!`

Report matches but don't block.

## Check 4: Lint / Style (WARNING)
If a linter config exists (eslint, ruff, golangci-lint, clippy), run it. Report issues but don't block.

## Check 5: Large Files (WARNING)
List any source files over 500 lines.

## Check 6: Security Scan (pre-pr mode only)

If mode is `pre-pr`, also check for:
- Hardcoded secrets or API keys in source files (grep for patterns like `sk-`, `api_key=`, `password=`)
- .env files accidentally staged in git
- Dependencies with known vulnerabilities (if `npm audit` / `pip audit` / equivalent is available)

Report findings but don't block (security issues should be reviewed, not auto-blocked).

## Summary

```
VERIFICATION: [mode] mode
============================
| Check          | Result        |
|----------------|---------------|
| Types          | PASS / FAIL   |
| Tests          | PASS / FAIL   |
| Debug          | N found / OK  |
| Lint           | N issues / OK |
| File size      | N large / OK  |
| Security       | N found / OK  |  <- pre-pr mode only

Ready to push: YES / NO
```

For `quick` mode, only show the Types row. For `pre-commit`, show Types + Debug + Lint.

## Update Audit Cache

After completing all checks, update `.claude/.audit-state.json`:
1. Compute fingerprint: `bash scripts/cache-hash.sh`
2. Status: PASS if verdict is CLEAR TO PUSH, FAIL otherwise
3. Upsert entry under key `"preflight"`
4. Keep max 10 entries (prune oldest)
