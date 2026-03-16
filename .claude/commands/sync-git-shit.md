---
name: sync-git-shit
description: Sync bundled git-shit from the workspace repo
model-hint: haiku
---

# Sync git-shit

Updates the bundled git-shit snapshot in `template/git-shit/` from the workspace repo.

## Steps

1. Show current bundled version:
   ```bash
   cat template/.version 2>/dev/null || echo "No version file — first sync"
   ```

2. Run the sync script:
   ```bash
   bash scripts/sync-git-shit.sh
   ```

3. Show what changed:
   ```bash
   git diff --stat template/git-shit/ template/.version
   ```

4. If changes exist, show them and ask: "Commit the updated git-shit bundle?"

5. If yes:
   ```bash
   git add template/git-shit/ template/.version
   git commit -m "chore(big-gulps): sync git-shit bundle to $(cat template/.version | head -c 7)"
   ```
