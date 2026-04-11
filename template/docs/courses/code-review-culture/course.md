---
name: Code Review Culture
description: How to give and receive reviews, what to look for, and how to chain /code-review with /preflight and /ready-to-commit
difficulty: beginner
estimated_sessions: 2-3
prerequisites: [claude-code-basics]
---

# Code Review Culture

Learn how to review code effectively, give constructive feedback, and use Big Gulps' review tools to catch issues early.

## Module 1: Why Review Code?

### Concept: The Purpose of Code Review

**Predict:** What's the primary purpose of code review? Is it to:
1. Find bugs
2. Enforce style consistency
3. Share knowledge across the team
4. All of the above, but one matters most

**Reveal:** All are valid, but knowledge sharing is often the most valuable long-term benefit. Bug finding is important but automated tools catch many issues. Style enforcement should be automated (linters, formatters). Knowledge sharing ensures no one person is a single point of failure.

### Concept: Review Before Merge

**Predict:** Why does Big Gulps block direct pushes to main and require pull requests?

**Reveal:** The PR workflow ensures every change gets reviewed before it reaches the main branch. This catches issues early (when they're cheap to fix) rather than late (when they're in production). It also creates a record of WHY changes were made.

### Exercise: Your First Review

Run `/code-review` on your current branch. Read the output and identify:
- Which findings are critical (must fix)?
- Which are warnings (should fix)?
- Which are info (nice to have)?

## Module 2: What to Look For

### Concept: The Review Checklist

When reviewing code, check these areas (in priority order):

1. **Correctness** — Does it do what it's supposed to do?
2. **Security** — Does it introduce vulnerabilities?
3. **Performance** — Will it be fast enough at scale?
4. **Maintainability** — Can someone else understand and modify this?
5. **Testing** — Is the new logic tested?

**Predict:** Which area do you think is most commonly missed in reviews?

**Reveal:** Security and performance are most commonly overlooked because they require thinking about scenarios the author didn't consider. That's why `/code-review` splits large reviews into parallel agents — one focused on architecture and security, one on correctness and performance, one on quality and test coverage. Each agent reads with a specific lens so nothing slips through.

### Concept: Spotting Common Issues

**Predict:** What's wrong with this code?
```javascript
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return data;
}
```

**Reveal:** No error handling! If the request fails, the promise resolves with undefined or throws. Better:
```javascript
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch user: ${response.status}`);
  }
  return response.json();
}
```

### Exercise: Review Practice

Pick a file in your project that was recently changed. Review it manually, checking for:
- Missing error handling
- Unused variables or imports
- Type safety bypasses
- Missing tests

Then run `/code-review` and compare your findings with the automated review.

## Module 3: Giving Good Feedback

### Concept: Constructive Review Comments

**Predict:** Which is better review feedback?
A. "This is wrong."
B. "Consider using a Map here instead of an Object — Maps have O(1) lookup and preserve insertion order, which matters for the display list."

**Reveal:** B is better because it:
1. Explains WHAT to change
2. Explains WHY (performance + correctness)
3. Shows you understand the context
4. Isn't judgmental

### Concept: The Three Types of Feedback

1. **Blocking** — Must fix before merging (security issues, bugs, breaking changes)
2. **Non-blocking** — Should fix but won't break anything (style, performance, readability)
3. **Nit** — Optional improvements (naming preferences, minor refactors)

Always label your feedback so the author knows what's required vs suggested.

### Exercise: Practice Feedback

Run `/code-review` on a recent feature branch. For each finding, categorize it:
- Is it blocking, non-blocking, or a nit?
- Can you explain WHY it matters?
- Can you suggest a specific fix?

## Module 4: When to Use Which Tool

### Concept: The Review Stack

Big Gulps includes three tools that work together at different depths:

| Tool | When | Time | Depth |
|------|------|------|-------|
| `/preflight` | Before every push | 30s | Types, tests, debug, lint, file size |
| `/code-review` | After finishing a feature, before PR | 1-3 min | Correctness, security, performance, quality |
| `/security-check` | Anything touching auth, data, or external input | 2-5 min | Secrets, injection, XSS, access control, deps |

**Predict:** When would you run `/security-check` in addition to `/code-review`?

**Reveal:** Run `/security-check` when:
- The change touches authentication, authorization, or session handling
- You're accepting user input (forms, uploads, query params)
- You're adding or modifying a database query
- You're integrating a new third-party API or dependency
- You're about to release to production

`/code-review` covers security at a high level. `/security-check` goes deeper with tagged finding IDs (AUTH-*, INJ-*, XSS-*, etc.) so you can track fixes across sessions.

### Concept: Skill Chaining

The magic move is chaining. `/ready-to-commit` runs `/code-review` + `/preflight` automatically, using audit caching so nothing runs twice. That's how experienced users move fast without skipping checks — the tools chain, the cache remembers, and you commit with confidence.

### Exercise: Review Workflow

Practice the full review workflow:
1. Make a small change to a file
2. Run `/code-review` — review the findings
3. Fix any critical issues
4. Run `/preflight` — verify all checks pass
5. Run `/ready-to-commit` — commit with a good message
