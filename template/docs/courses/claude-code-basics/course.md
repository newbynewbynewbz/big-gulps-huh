---
name: Claude Code Basics
description: Learn how Claude Code works — skills, CLAUDE.md, hooks, and how to work with AI effectively
difficulty: beginner
estimated_sessions: 2-3
prerequisites: []
---

# Claude Code Basics

## Module 1: What Is Claude Code?

### Concept: Your AI Pair Programmer
Claude Code is an AI assistant that lives in your terminal. It can read your files, write code, run commands, and help you build things. Think of it as a really smart collaborator who knows a lot about programming but needs YOU to tell it what to build.

**Predict:** When you type a message to Claude Code, what do you think it can see about your project?

**Reveal:** Claude Code can:
- Read any file in your project
- See your git history (what changed and when)
- Run terminal commands
- Read CLAUDE.md for project-specific context
- But it CANNOT see your browser, your email, or anything outside your project folder

**Key insight:** Claude Code is powerful but not magic. It works best when you're specific about what you want.

### Exercise: Your First Interaction
Try these commands and observe what happens:
1. Ask Claude: "What files are in this project?"
2. Ask Claude: "What does CLAUDE.md say?"
3. Ask Claude: "What branch am I on?"

Notice how Claude reads real files and runs real commands — it's not guessing.

## Module 2: Skills (Slash Commands)

### Concept: What Are Skills?
Skills are pre-written instructions that tell Claude HOW to do something specific. Instead of explaining what you want every time, you type a slash command.

**Predict:** What do you think happens when you type `/health`?

**Reveal:** `/health` runs 6 checks on your project in parallel — types, tests, dependencies, TODOs, file sizes, and code stats — then gives you a report card. Without the skill, you'd have to ask Claude to do each of those things separately.

**Think of skills like recipes.** You could describe how to make a sandwich every time, or you could just say "make me a sandwich" and the recipe handles the details.

### Concept: Your Available Skills
| Skill | What It Does | When to Use It |
|-------|-------------|----------------|
| `/health` | Project health report | "Is everything working?" |
| `/preflight` | Pre-push checks | Before pushing code |
| `/code-review` | AI code review | Before making a PR |
| `/learn` | This! Interactive tutor | Anytime you want to learn |
| `/vibes` | Focus & motivation | Start of a session |
| `/retro` | Session retrospective | End of a session |

### Exercise: Try a Skill
Run `/health` right now. Read the output. Then ask Claude: "What does the grade mean?"

## Module 3: CLAUDE.md — The Project Constitution

### Concept: Why CLAUDE.md Matters
CLAUDE.md is a file at the root of your project that Claude reads at the START of every conversation. It tells Claude about YOUR specific project — the tech stack, file structure, coding patterns, and common gotchas.

**Predict:** If two different projects both use TypeScript, would Claude behave the same way in both?

**Reveal:** Without CLAUDE.md, yes — Claude gives generic TypeScript advice. WITH CLAUDE.md, Claude knows that Project A uses React with Zustand state management and Project B uses Vue with Pinia. It writes code that matches YOUR patterns, not generic patterns.

**Analogy:** CLAUDE.md is like onboarding docs for a new hire, except the new hire is an AI that reads really fast and starts with zero institutional knowledge.

### Exercise: Read Your CLAUDE.md
Open CLAUDE.md in your project. Find the TODO sections. Pick ONE and fill it in (Tech Stack is the easiest to start with). Then start a new Claude Code conversation and notice how Claude uses that information.

## Module 4: Hooks — Your Safety Net

### Concept: What Are Hooks?
Hooks are automatic checks that run when Claude does certain things. Some hooks block dangerous actions (like editing .env files). Others warn you about potential issues (like leaving debug statements in code).

**Predict:** Why would you want to BLOCK Claude from editing .env files?

**Reveal:** .env files contain secrets — API keys, database passwords, authentication tokens. If Claude edits them, those secrets appear in your conversation history. If that history is logged or shared, your secrets are exposed. The hook makes it physically impossible for Claude to touch .env files.

### Concept: Hook Types
| Type | What Happens | Example |
|------|-------------|---------|
| **Blocking** | Prevents the action entirely | .env file protection |
| **Warning** | Shows a message but lets it through | "You left a console.log" |
| **Info** | Just shows information | Session greeting with branch name |

### Exercise: See Hooks in Action
Ask Claude to "add a console.log to any file." After it edits the file, watch for the warning message. That's the console sentinel hook doing its job.

## Module 5: Working With Claude Effectively

### Concept: How to Ask for What You Want
Claude works best when you're specific. Compare:
- Vague: "Make the app better" — Claude doesn't know what "better" means to you
- Specific: "Add a loading spinner to the login button while the API call is in progress" — Claude knows exactly what to build

**Predict:** Which request gets better results: "Fix the bug" or "The login form submits twice when I click fast — add debouncing to prevent double submission"?

**Reveal:** The second one, every time. Claude can't see your screen or reproduce your bugs. The more context you give about WHAT is happening and WHAT should happen instead, the better the result.

### Concept: The Workflow Loop
1. **Ask** — tell Claude what you want to build or fix
2. **Review** — read what Claude wrote before accepting
3. **Test** — run the code and verify it works
4. **Commit** — save your work with a descriptive message

Never let Claude write 500 lines without reviewing. Small steps, frequent checks.

### Exercise: Build Something Small
Pick something tiny — rename a variable, add a comment, create a placeholder file. Go through the full loop: ask Claude, review the change, test it, commit it. This is the rhythm of working with AI.
