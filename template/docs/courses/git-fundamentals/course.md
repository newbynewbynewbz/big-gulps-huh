---
name: Git Fundamentals
description: Version control from zero — branches, commits, PRs, and the hooks that protect you
difficulty: beginner
estimated_sessions: 3-4
prerequisites: ["terminal-basics"]
---

# Git Fundamentals

## Module 1: What Is Git?

### Concept: Version Control
Git tracks every change you make to your project over time. Think of it as unlimited undo — not just for one file, but for your ENTIRE project.

**Predict:** You make a change that breaks everything. Without git, what are your options?

**Reveal:** Without git: panic, try to remember what you changed, maybe cry. WITH git: type one command and you're back to the working version. Git saves snapshots of your project at every commit. You can go back to any snapshot.

**Analogy:** Git is like a save system in a video game. You save before a boss fight. If you die, you reload. Commits are your save points.

### Exercise: See Git in Action
```bash
git log --oneline -5     # See last 5 saves (commits)
git status               # See what's changed since last save
```

## Module 2: Making Changes (The Stage-Commit Flow)

### Concept: Two Steps to Save
Git doesn't auto-save. You choose what to save and when. It's a two-step process:

1. **Stage** — pick which changes to include (`git add`)
2. **Commit** — save them with a description (`git commit`)

**Predict:** Why would git make you choose which files to include instead of just saving everything?

**Reveal:** Because you might be working on two different things at once. Maybe you fixed a bug AND started a new feature. Those should be TWO separate saves (commits), not one jumbled mess. Staging lets you control exactly what goes into each commit.

```bash
git add src/login.tsx           # Stage one file
git add src/login.tsx src/api.ts  # Stage two files
git commit -m "feat: add login form validation"
```

### Concept: Conventional Commit Messages
This project uses conventional commits — every message starts with a type:

| Type | When to Use | Example |
|------|-------------|---------|
| `feat:` | Adding something new | `feat: add search bar` |
| `fix:` | Fixing something broken | `fix: cart total was wrong` |
| `docs:` | Documentation changes | `docs: update setup guide` |
| `refactor:` | Reorganizing code (no behavior change) | `refactor: extract login logic` |
| `test:` | Adding or fixing tests | `test: add login validation tests` |
| `chore:` | Maintenance tasks | `chore: update dependencies` |

The commit-msg hook enforces this — if you forget the prefix, it'll remind you.

### Exercise: Make a Commit
```bash
# Make a tiny change (add a comment to any file)
git status                              # See the change
git add <filename>                      # Stage it
git commit -m "docs: add clarifying comment"   # Save it
git log --oneline -3                    # See your commit
```

## Module 3: Branches

### Concept: Working in Parallel
A branch is a copy of your project where you can make changes without affecting the main version. When you're done, you merge your branch back.

**Predict:** What happens if two people edit the same file on different branches?

**Reveal:** When they try to merge, git detects the conflict and asks a human to decide which changes to keep. This is called a "merge conflict." It sounds scary but it's just git saying "I found two different edits to the same place — which one wins?"

```bash
git checkout -b feature/my-thing    # Create a new branch and switch to it
# ... make changes, commit them ...
git push -u origin feature/my-thing  # Push to remote
```

### Concept: Why We Never Work on Main
The `main` branch is the "real" version — the one that's deployed, the one everyone trusts. If you break main, you break it for everyone.

That's why the pre-push hook blocks direct pushes to main. Every change goes:
1. Create a branch
2. Make changes on the branch
3. Push the branch
4. Open a Pull Request (PR)
5. Get it reviewed and merged

### Exercise: Create Your First Branch
```bash
git checkout -b practice/my-first-branch  # Create + switch
git branch                                 # See all branches (* = current)
# Make a small change, commit it
git checkout main                          # Switch back to main
git branch                                 # Notice your branch still exists
```

## Module 4: Pull Requests

### Concept: Code Review Before Merge
A Pull Request (PR) is how you say "I made changes on my branch, please review and merge them into main." It's a conversation — reviewers can comment, suggest changes, or approve.

**Predict:** Why not just merge directly without a PR?

**Reveal:** Because everyone makes mistakes. A second pair of eyes catches bugs, security issues, and design problems before they hit production. PRs also create a searchable record of WHY changes were made.

```bash
git push -u origin feature/my-thing   # Push branch
gh pr create --fill                    # Open a PR (fills from commit messages)
```

After approval:
```bash
gh pr merge --squash --delete-branch   # Merge + clean up
```

### Exercise: The Full Workflow
```bash
git checkout -b practice/full-workflow
# Make a small change
git add <file>
git commit -m "feat: practice the full PR workflow"
git push -u origin practice/full-workflow
gh pr create --title "Practice: full workflow" --body "Testing the PR flow"
# Then go to GitHub and look at your PR!
```

## Module 5: When Things Go Wrong

### Concept: Common Recovery Commands
Things will go wrong. Here's your emergency kit:

```bash
git status              # What's going on right now?
git diff                # What exactly changed?
git stash               # Temporarily hide my changes (get them back with git stash pop)
git checkout -- <file>  # Undo changes to one file (back to last commit)
git log --oneline -10   # What happened recently?
```

**Predict:** You made changes you want to keep, but need to switch branches to look at something. What do you do?

**Reveal:** `git stash` — it hides your changes temporarily. Switch branches, look at what you need, switch back, then `git stash pop` to bring your changes back.

### Concept: Just Ask Claude
For anything beyond basics:
- "I committed to the wrong branch, how do I fix it?"
- "I need to undo my last commit but keep the changes"
- "How do I resolve this merge conflict?"

Claude can see your git state and give you the exact commands. You don't need to memorize recovery procedures.

### Exercise: Practice Recovery
```bash
# Make a change but DON'T commit
echo "temporary" >> README.md
git status                    # See the change
git stash                     # Hide it
git status                    # Clean again
git stash pop                 # Bring it back
git checkout -- README.md     # Undo it for real
git status                    # Clean
```

## Module 6: The Hooks That Protect You

### Concept: Automatic Safety
This project has git hooks — scripts that run automatically before certain git actions. They catch mistakes before they become problems.

| Hook | When It Runs | What It Does |
|------|-------------|--------------|
| pre-push | Before `git push` | Blocks pushes to main — use PRs |
| pre-commit | Before `git commit` | Warns if commit is 200+ lines |
| commit-msg | After writing commit message | Requires feat:/fix:/docs: prefix |

**Predict:** If you try `git push` while on the main branch, what happens?

**Reveal:** The pre-push hook blocks it and tells you to use a branch + PR instead. It even shows you the exact commands. This isn't punishment — it's protection. Every team has stories about someone pushing broken code to main at 2am.

### Exercise: Test the Hooks
```bash
# Test commit-msg hook
git checkout -b test/hooks
echo "test" >> test-file.txt
git add test-file.txt
git commit -m "test"              # Should be rejected! No prefix.
git commit -m "test: verify hooks"  # Should work!
git checkout main
git branch -D test/hooks          # Clean up
```
