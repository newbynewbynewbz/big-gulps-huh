---
name: achievements
description: View your badges and progress — earned by using skills, completing courses, and building good habits
model-hint: haiku
---

# Achievements — Badge Progress Tracker

View your earned badges and progress toward new ones.

## Step 1: Load Achievement State

Read `.claude/achievements.json`. If it doesn't exist, create it with:
```json
{
  "version": 1,
  "badges": {},
  "stats": {
    "total_commits": 0,
    "skills_used": {},
    "findings_fixed": 0,
    "streak_days": 0,
    "longest_streak": 0,
    "last_session": null
  }
}
```

Also read `.claude/learning-state.json` for course completion data.

## Step 2: Check Badge Eligibility

Evaluate each badge against current stats:

| Badge | Requirement | Check |
|-------|-------------|-------|
| First Commit | Complete first conventional commit | `total_commits >= 1` |
| Clean Push | `/preflight` passes with zero warnings | Check last preflight result |
| Reviewer | Use `/code-review` 5 times | `skills_used["code-review"] >= 5` |
| Blast-Radius Scout | Use `/impact-analysis` 3 times | `skills_used["impact-analysis"] >= 3` |
| Test Contributor | Use `/test-gen` 3 times | `skills_used["test-gen"] >= 3` |
| Security Scout | Run `/security-check` and fix 3+ findings | `skills_used["security-check"] >= 1 && findings_fixed >= 3` |
| Course Graduate | Complete any course | Any course in learning-state with all modules done |
| Course Marathoner | Complete all 6 courses | All courses in learning-state done |
| Streak 7 | Commit daily for 7 days | `streak_days >= 7` |
| Streak 30 | Commit daily for 30 days | `streak_days >= 30` |
| Streak 90 | Commit daily for 90 days | `streak_days >= 90` |
| Committer | Use `/ready-to-commit` 10 times | `skills_used["ready-to-commit"] >= 10` |
| Focused Mind | Use `/vibes` 5 times | `skills_used["vibes"] >= 5` |

## Step 3: Display Dashboard

```
Achievements
=============

Earned:
  [badge] First Commit        — Earned 2026-03-01
  [badge] Clean Push           — Earned 2026-03-05
  [badge] Streak 7             — Earned 2026-03-08

In Progress:
  [ ] Reviewer                 — 3/5 code reviews
  [ ] Course Graduate          — Claude Code Basics: 4/5 modules
  [ ] Blast-Radius Scout       — 1/3 impact analyses

Locked:
  [lock] Test Contributor      — 0/3 runs of /test-gen
  [lock] Security Scout        — Run /security-check first
  [lock] Streak 30             — 7/30 days
  [lock] Streak 90             — 7/90 days

Stats:
  Total commits: 42
  Skills used: 8 unique
  Current streak: 7 days
  Longest streak: 7 days
```

## Step 4: Award New Badges

If any badges were newly earned since last check:
1. Update `achievements.json` with the badge and earned date
2. Display a congratulatory message for each new badge
3. Suggest next achievable badges

## Badge Display in Session Greeting

When the session greeting hook runs, it should check achievements.json and display:
- New badges earned since last session
- Current streak count
- Next achievable badge with progress
