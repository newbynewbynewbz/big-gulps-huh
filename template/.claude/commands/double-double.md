# /double-double -- Universal Dual Dev Session Orchestrator

Spin up (or tear down) parallel worktree-based development sessions with dedicated terminals and either iOS simulators (native) or Brave Browser tabs (web / "animal style").

**Usage:**
- `/double-double` -- Open a new session (auto-detects project type)
- `/double-double animal style` -- Force web mode (Brave tabs) regardless of project type
- `/double-double close` -- Close the active session (review, merge, clean up)
- `/double-double close animal style` -- Same as `close` (mode is read from session state)

**Modes:**
- **Native:** iOS Simulators + Expo dev servers (auto-detected for Expo projects)
- **Web ("animal style"):** Brave Browser tabs + npm dev servers (auto-detected for Vite/Next.js/generic)

**Layout (both modes):**
- Left 50%: 2 stacked Terminal.app windows (top = worktree 1, bottom = worktree 2)
- Right 50%: 2 iOS Simulators side-by-side (native) OR 1 Brave window with 2 tabs (web)

---

## OPENING PHASE (default -- no `close` argument)

### Step 0: Detect Mode

If `$ARGUMENTS` contains "animal style" -> force **web mode**, skip auto-detection.

Otherwise, auto-detect project type using this ladder (check from project root):

1. `app.json` or `app.config.*` containing `"expo"` -> **native mode** (`projectType: expo`)
2. `vite.config.ts` or `vite.config.js` exists -> **web mode** (`projectType: vite`)
3. `next.config.*` exists -> **web mode** (`projectType: nextjs`)
4. `package.json` with a `"dev"` script -> **web mode** (`projectType: generic`)
5. None found -> abort: "Could not detect project type. Expected app.json (Expo), vite.config (Vite), next.config (Next.js), or package.json with a dev script."

**Port defaults by type:**

| Type | Port 1 | Port 2 |
|------|--------|--------|
| Expo | 8081 | 8082 |
| Vite | 5173 | 5174 |
| Next.js | 3000 | 3001 |
| Generic | 3000 | 3001 |

**Vite port override:** If `vite.config.ts` (or `.js`) contains `server: { port: NNNN }`, use that as Port 1 and NNNN+1 as Port 2.

Announce the detected mode:
```
Detected: <projectType> project -> <native|web> mode
Ports: <port1> / <port2>
```

### Step 1: Goal Input

Prompt the user with AskUserQuestion:
```
What's the plan for this session? Describe your goal(s) in 3-5 sentences.
Include: what you're building/fixing, acceptance criteria, and any constraints.
```

Validate: the response must contain at least 3 sentences (split on `.` `!` `?`). If fewer, reject with:
```
Tell me more -- I need at least 3 sentences to plan worktrees effectively.
What are you building? What does "done" look like? Any constraints?
```

Save the validated goal as SESSION_GOAL.

### Step 2: Analyze Goal & Plan Worktrees

Analyze SESSION_GOAL and determine:

1. **Worktree count (1 or 2):**
   - If the goal describes ONE cohesive task -> 1 worktree, both terminals point to it (same branch, both ports for device/tab testing)
   - If the goal describes 2 independent tasks -> 2 worktrees (separate branches)

2. **Branch names** using conventional prefixes:
   - `feature/` for new functionality
   - `fix/` for bug fixes
   - `refactor/` for code restructuring
   - `docs/` for documentation

3. **Task-to-worktree mapping** -- which task goes where

Present the plan to the user for confirmation. Adapt the display column based on mode:

**Native mode:**
```
## Session Plan

| # | Branch | Task | Port | Device |
|---|--------|------|------|--------|
| 1 | feature/xxx | [task summary] | 8081 | [auto-detected simulator 1] |
| 2 | fix/yyy | [task summary] | 8082 | [auto-detected simulator 2] |

Proceed? [Y/n]
```

**Web mode:**
```
## Session Plan

| # | Branch | Task | Port | Display |
|---|--------|------|------|---------|
| 1 | feature/xxx | [task summary] | 5173 | Brave Tab 1 |
| 2 | fix/yyy | [task summary] | 5174 | Brave Tab 2 |

Proceed? [Y/n]
```

If the user says no, ask what to adjust and re-plan.

### Step 3: Prechecks

Run these checks sequentially from the project root:

```bash
# 1. Main must be clean
git status --porcelain | grep -v '^??'
```
If dirty -> abort: "Main branch has uncommitted changes. Commit or stash before starting a session."

```bash
# 2. Check for stale worktrees
git worktree list
```
If `.worktrees/` entries exist -> ask: "Found existing worktrees. Clean them up first? [Y/n]"
If yes, run `git worktree remove <path>` for each.

```bash
# 3. Check ports
lsof -i :<port1> -t 2>/dev/null
lsof -i :<port2> -t 2>/dev/null
```
If occupied -> ask: "Port XXXX is in use by PID XXXX. Kill it? [Y/n]"
If yes, `kill <pid>`.

**Native mode only:**
```bash
# 4. Verify simulators exist
xcrun simctl list devices available | grep "iPhone"
```
If not found -> show available devices and abort.

**Web mode only:**
```bash
# 4. Verify Brave Browser exists
test -d "/Applications/Brave Browser.app"
```
If not found -> abort: "Brave Browser not found at /Applications/Brave Browser.app"

### Step 4: Create Worktrees

For each planned worktree:

```bash
# Create worktree directory if needed
mkdir -p .worktrees

# Create worktree with new branch from main
git worktree add ".worktrees/<branch-slug>" -b "<branch-name>" main
```

Where `<branch-slug>` is the branch name with `/` replaced by `-` (e.g., `feature/xxx` -> `feature-xxx`).

**Edge cases:**
- Worktree already exists at path -> AskUserQuestion: "Worktree exists at .worktrees/<slug>. Reuse it, or remove and recreate? [reuse/recreate]"
- Branch already exists -> AskUserQuestion: "Branch <name> already exists. Attach to it, or pick a new name? [attach/rename]"

Run npm install in each worktree (parallel via background Bash):
```bash
cd .worktrees/<slug> && npm install
```

### Step 5: Launch Everything

Determine if this is a first run (native mode: no `ios/` directory in worktree):
```bash
# Native mode only
ls .worktrees/<slug>/ios 2>/dev/null
```

Build the script arguments and run:
```bash
bash scripts/double-double-open.sh \
  --worktree1 ".worktrees/<slug-1>" \
  --worktree2 ".worktrees/<slug-2>" \
  --port1 <port1> \
  --port2 <port2> \
  --mode <native|web> \
  --project-type <expo|vite|nextjs|generic> \
  --project-root "$(pwd)" \
  [--first-run]
```

### Step 6: Session Dashboard & State

Save session state:
```bash
cat > .worktrees/.session.json << 'ENDJSON'
{
  "id": "dd-<YYYYMMDD>-<HHMMSS>",
  "goal": "<SESSION_GOAL>",
  "mode": "<native|web>",
  "projectType": "<expo|vite|nextjs|generic>",
  "worktrees": [
    {
      "branch": "<branch-1>",
      "path": ".worktrees/<slug-1>",
      "port": <port1>,
      "display": "<Device Name or Brave Tab 1>",
      "deviceUDID": "<UDID or null>"
    },
    {
      "branch": "<branch-2>",
      "path": ".worktrees/<slug-2>",
      "port": <port2>,
      "display": "<Device Name or Brave Tab 2>",
      "deviceUDID": "<UDID or null>"
    }
  ],
  "startTime": "<ISO 8601>"
}
ENDJSON
```

Display the dashboard (adapt display column to mode):
```
## Double-Double Session Started

| Worktree | Branch | Port | Display | Path |
|----------|--------|------|---------|------|
| 1 | feature/xxx | <port1> | <device/tab> | .worktrees/feature-xxx |
| 2 | fix/yyy | <port2> | <device/tab> | .worktrees/fix-yyy |

**Mode:** <native|web> (<projectType>)
**Goal:** <SESSION_GOAL>
**Session ID:** dd-20260308-153000
**Started:** 3:30 PM

Terminals and <simulators|Brave tabs> are launching. Dev servers will start momentarily.
When you're done, run `/double-double close` to review, merge, and clean up.
```

---

## CLOSING PHASE (when $ARGUMENTS contains "close")

### Step 7: Read Session State

```bash
cat .worktrees/.session.json 2>/dev/null
```

If missing -> abort: "No active session found. Run `/double-double` to start one."

Parse the JSON. Extract mode from the session (do NOT rely on arguments for mode). Verify each worktree path still exists:
```bash
test -d ".worktrees/<slug>"
```

If a worktree is missing, note it and skip it in subsequent steps.

### Step 8: Review Changes

For each worktree that exists:
```bash
cd .worktrees/<slug> && git diff main --stat
```

Display:
```
## Changes Review

### Worktree 1: <branch-name>
X files changed, Y insertions(+), Z deletions(-)
[file list from --stat]

### Worktree 2: <branch-name>
X files changed, Y insertions(+), Z deletions(-)
[file list from --stat]
```

Ask: "Want to see the full diff for either worktree? [1/2/both/no]"
If yes, show `git diff main` for the requested worktree(s).

### Step 9: Commit Uncommitted Work

For each worktree:
```bash
cd .worktrees/<slug> && git status --porcelain | grep -v '^??'
```

If dirty, ask: "Worktree <slug> has uncommitted changes. What should I do?"
- **Commit** -- prompt for message, then `git add -A && git commit -m "<message>"`
- **Stash** -- `git stash push -m "double-double close stash"`
- **Discard** -- `git checkout .` (confirm first: "This will discard all uncommitted changes. Sure? [y/N]")

### Step 10: Merge to Main

For each worktree with commits ahead of main:
```bash
cd .worktrees/<slug> && git log main..HEAD --oneline
```

If there are commits, ask: "How should I merge <branch-name> to main?"
- **Option A (default): Squash merge**
  ```bash
  cd <project-root>
  git switch main
  git merge --squash <branch-name>
  git commit -m "<squash commit message>"
  ```
  Generate a squash commit message from the branch's commit log.

- **Option B: Create PR**
  ```bash
  cd .worktrees/<slug>
  git push -u origin <branch-name>
  gh pr create --head <branch-name> --base main --fill
  ```
  Show the PR URL.

- **Option C: Discard**
  Confirm: "This will delete branch <branch-name> and all its commits. Sure? [y/N]"
  If confirmed, branch will be cleaned up in Step 11.

### Step 11: Cleanup

Run the close script:
```bash
bash scripts/double-double-close.sh .worktrees/.session.json
```

This handles:
- Simulator shutdown (native mode only -- skipped in web mode)
- Dev server process cleanup (all ports)
- Worktree removal
- Session file deletion

### Step 12: Post-Session Summary

Display:
```
## Session Complete

| Branch | Action | Lines Changed |
|--------|--------|---------------|
| feature/xxx | Squash merged | +Y / -Z |
| fix/yyy | PR created | +Y / -Z |

**Mode:** <native|web>
**Duration:** X hours Y minutes
**Session ID:** dd-20260308-153000

### Next Steps
- Verify main is clean
- Run tests if applicable
```

Run integrity check on main (if test infrastructure exists):
```bash
# Only run if package.json has test script
npm test 2>/dev/null || echo "No test script found"
# Only run if tsconfig.json exists
npx tsc --noEmit 2>/dev/null || echo "No TypeScript config found"
```

Report results. If tests or types fail, warn the user and suggest investigating.

---

## Error Handling Reference

| Scenario | Detection | Action |
|----------|-----------|--------|
| Main branch dirty | `git status --porcelain` | Abort with message |
| Worktree exists | `git worktree list` | Ask: reuse or clean |
| Port in use | `lsof -i :<port>` | Offer to kill process |
| Simulator not found | `xcrun simctl list` | Show available, abort |
| Brave not installed | `test -d` on app path | Abort: install Brave |
| npm install fails | Exit code != 0 | Show error, suggest `rm -rf node_modules` |
| Merge conflict | `git merge` exit code | Leave in conflict state with instructions |
| AppleScript denied | osascript exit code | Suggest System Settings > Privacy > Automation |
| Session file missing | `cat` fails | Abort close with "no active session" |
| Worktree path gone | `test -d` fails | Skip worktree, note in summary |
| No project detected | Step 0 ladder exhausted | Abort with diagnostic |
| Running from worktree | `git rev-parse --show-toplevel` | Warn, suggest cd to root |
