---
name: Working Smart with AI
description: Learn techniques that help you and Claude work more effectively together
difficulty: beginner
estimated_sessions: 3-4
prerequisites:
  - claude-code-basics
---

# Working Smart with AI

Master the techniques that make AI-assisted development smooth and productive. These patterns help you avoid common frustrations and get better results.

## Module 1: When AI Forgets — Understanding Context

### Concept: The Context Window

Claude has a memory limit called the "context window." Think of it like a whiteboard — there's only so much space. As your conversation gets longer, older content gets pushed off.

**Predict:** What do you think happens when a conversation gets really long and Claude runs out of memory space?

**Reveal:** Claude uses "compaction" — it summarizes older parts of the conversation to make room. This means details from early in the conversation might be compressed into summaries. That's why Claude might seem to "forget" things you discussed earlier.

### Concept: Strategic Compaction

You can control when compaction happens instead of letting it happen randomly.

**Predict:** Would it be better to let compaction happen automatically, or to trigger it yourself at a good stopping point? Why?

**Reveal:** Triggering it yourself with `/compact` at natural breakpoints (after finishing a feature, before starting something new) means the summary captures a clean state. Automatic compaction might happen mid-task and lose important context.

### Exercise: Try Compaction

1. Check your context usage in the status bar (look for "Context: XX%")
2. If you've been working for a while, try `/compact` now
3. Notice how Claude still knows what you're working on — the summary preserved the important parts

## Module 2: Small Bites — Review Often, Commit Often

### Concept: The Small Steps Pattern

Large changes are hard for both humans and AI to review correctly.

**Predict:** If you ask Claude to build an entire feature at once (20+ files), what problems might come up?

**Reveal:** Several things go wrong:
- Claude might run out of context mid-way and lose track of the plan
- Errors compound — a mistake in file 3 propagates to files 4-20
- Code review becomes overwhelming — nobody catches bugs in 500-line diffs
- If something breaks, it's hard to know which change caused it

### Concept: The Review-Commit Rhythm

The best pattern: make a small change, review it, commit it, repeat.

**Predict:** How often should you commit when working with Claude — after every single line, after every file, or after every logical chunk?

**Reveal:** After every logical chunk — a function, a component, a feature step. Use `/ready-to-commit` to check your work before committing. This gives you clean save points to return to if something goes wrong.

### Exercise: Practice the Rhythm

Next time you build something with Claude:
1. Ask for one piece at a time ("First, create the data model")
2. Review what was created
3. Commit with a descriptive message
4. Then ask for the next piece

## Module 3: Ask Before Building — The Planning Pattern

### Concept: Why Planning Matters

The most common mistake with AI: jumping straight to "build me X" without planning.

**Predict:** What's the risk of telling Claude "build me a todo app" with no further guidance?

**Reveal:** Claude will make dozens of decisions for you: which framework, which database, how to structure components, what features to include. Some of those decisions won't match what you wanted, and you'll spend more time fixing than if you'd planned upfront.

### Concept: Plan Mode

Claude Code has a built-in **plan mode**. Press `Shift+Tab` twice (or type the command your version uses to enter plan mode) and Claude will research, think, and present a written plan *before* touching any files. Nothing gets built until you approve the plan.

**Predict:** What information should a good plan include?

**Reveal:** A good plan includes:
- Clear steps in dependency order
- Which files will be created or modified
- Potential tricky parts flagged upfront
- Confirmation before building starts

### Exercise: Plan Something

Think of a feature you want to build (even a simple one). Try:
1. Enter plan mode and describe your feature
2. Review the plan Claude presents — do the steps make sense?
3. Ask Claude to revise if anything looks wrong
4. Approve the plan and let Claude execute step by step

## Module 4: Multiple Windows — The Cascade Method

### Concept: Parallel Development

Sometimes you need to work on two related things at once — like building a feature while running the dev server to test it.

**Predict:** Can you have multiple Claude sessions working on the same project at the same time? What might go wrong?

**Reveal:** You can, but they might conflict — two sessions editing the same file creates merge problems. The solution is "worktrees" — separate copies of your code that can be worked on independently and merged later.

### Concept: Double-Double Sessions

The `/double-double` command sets up two parallel workspaces with their own terminals. One can build while the other tests, or each can work on a different part of the feature.

**Predict:** When would parallel sessions be helpful vs. overkill?

**Reveal:** Helpful for:
- Building a feature while testing in a simulator/browser
- Working on frontend and backend simultaneously
- Large refactors where you want to compare approaches

Overkill for:
- Small bug fixes
- Single-file changes
- Learning and exploration

### Exercise: Explore Worktrees

Run `git worktree list` to see your current worktrees. If you're working on something that would benefit from a parallel session, try `/double-double` next time.

## Module 5: Saving Your Work — Session Persistence

### Concept: Automatic Session State

When you close Claude and come back later, the previous conversation is gone. But your session state is automatically saved by hooks that run on `SessionStart`, `Stop`, and `PreCompact` events.

**Predict:** What information would be most useful to have when returning to a project after a break?

**Reveal:** The most useful context is:
- What branch you were on
- What you were working on (last commit message)
- How many uncommitted changes you have
- What you planned to do next

That's exactly what the session hooks save automatically — no manual command needed.

### Concept: Capturing the "Why" in Commits and CLAUDE.md

The session hooks capture "where" — but YOU are responsible for capturing "why." The two places this belongs:

1. **Commit messages** — not just `fix: button` but `fix: button: debounce double-click on slow networks (caused duplicate orders)`. The why lives in the commit body.
2. **CLAUDE.md → Active Gotchas** — when you discover something surprising about the codebase (a non-obvious constraint, an integration quirk, a pattern that tripped you up), add a bullet. Future-you will thank you.

**Predict:** Which of these two places is better for "we chose React Query over SWR because our backend doesn't support If-Modified-Since headers"?

**Reveal:** CLAUDE.md Active Gotchas — because it's a standing decision that affects every future PR, not a one-off change description. Commit messages explain a specific change; CLAUDE.md explains standing context.

### Exercise: Add a Gotcha

Look at your project and find ONE thing that tripped you up recently — something non-obvious about the code, tooling, or workflow. Open CLAUDE.md and add it under **Active Gotchas** as a bullet. That's the muscle you're building: capturing the why before you forget.
