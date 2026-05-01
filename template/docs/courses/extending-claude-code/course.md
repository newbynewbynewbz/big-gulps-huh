---
name: Extending Claude Code
description: Learn the building blocks for shaping Claude — subagents, output styles, hooks, and MCP servers
difficulty: intermediate
estimated_sessions: 3-4
prerequisites: [claude-code-basics]
---

# Extending Claude Code

Skills are just one way to shape how Claude works. This course covers the four other primitives you'll meet as you go deeper: **subagents**, **output styles**, **hooks**, and **MCP servers**. Each one solves a specific problem, and together they let you build workflows that feel custom to your project.

## Module 1: Subagents — Isolated Workers

### Concept: What's a Subagent?
A subagent is a separate Claude instance that you dispatch from your main conversation. It runs in its own context window, does a focused task, and returns a single message back. Think of it like asking a colleague to research something — you brief them, they go off and do the work, they come back with a summary.

**Predict:** Why would you want a separate Claude instance instead of just asking the main one to do more work?

**Reveal:** Three reasons. First, **isolation** — the subagent's exploration doesn't pollute your main conversation with thousands of lines of file reads. Second, **parallelism** — you can dispatch three subagents at once and they all work in parallel. Third, **specialization** — different subagents can use different models (a lookup task on Haiku, a design task on Opus) and have different tool permissions.

### Concept: When to Dispatch
| Situation | Use a subagent? |
|-----------|-----------------|
| "Find where X is defined" — single file, known location | No, just Read it |
| "How does the auth flow work?" — needs to read 5+ files | Yes, dispatch an Explore agent |
| Three independent research questions | Yes, dispatch three in parallel |
| "Fix this typo on line 42" | No, just Edit it |
| "Review my PR for security issues" | Yes, fresh-context review avoids same-session bias |

**Key insight:** The cost of a subagent is the prompt itself — you have to brief them like a colleague who just walked into the room. If the briefing takes longer than the task, just do the task directly.

### Exercise: Dispatch Your First Agent
Pick a moderately complex question about your project — something you'd normally explore yourself, like "how is state managed?" or "where do API errors get handled?". Ask Claude to dispatch an Explore agent for it. Notice how the response comes back as a structured summary instead of raw file dumps.

## Module 2: Output Styles — Shaping the Voice

### Concept: What's an Output Style?
Output styles change how Claude responds without changing what Claude does. They're like personality presets. The default style is concise and direct; the `learning` style adds Insight boxes and asks for your input on design decisions; an `explanatory` style narrates reasoning.

**Predict:** If you switch from default to `learning` style mid-project, would Claude write different code?

**Reveal:** Mostly no, but slightly yes. The same task produces the same files, but the **explanations around the code change** — Insight blocks appear, trade-offs get surfaced, and Claude asks you to make small design calls instead of deciding silently. It's the difference between a senior dev who just ships and one who explains as they go. Useful when you're learning, noisy when you're shipping.

### Concept: When Each Style Earns Its Keep
| Style | When It's Right |
|-------|-----------------|
| Default | Production work where you trust the patterns |
| Learning | Onboarding, exploring an unfamiliar codebase, teaching yourself a new framework |
| Explanatory | Code review of someone else's PR, post-mortems, when you need the "why" written down |

You can switch via `/output-style` or set a default in your settings.

### Exercise: A/B Your Voice
Run the same prompt — something simple, like "add a function that capitalizes the first letter of a string" — twice in two different sessions: once with default style, once with learning style. Compare what's different. The code will be nearly identical; the framing won't be.

## Module 3: Hooks — Automated Reactions

### Concept: Beyond the Safety Net
You met hooks in Claude Code Basics — the .env blocker, the console-log warning. Those are *protective* hooks. But hooks can also *react*: log every tool call, run a type checker after every Edit, post a Slack message when Claude finishes, save state before context compaction.

**Predict:** What's the difference between a hook and a skill?

**Reveal:** Skills are things YOU invoke (`/preflight`). Hooks fire AUTOMATICALLY in response to events Claude generates (a tool call, a session start, a stop). Skills require intent; hooks enforce policy. If you want something to happen "every time X" without remembering to ask, you want a hook, not a skill.

### Concept: The Lifecycle Events
| Event | When It Fires | Common Use |
|-------|---------------|------------|
| `PreToolUse` | Before any tool runs | Block dangerous actions, warn on patterns |
| `PostToolUse` | After a tool finishes | Type check, log changes, validate output |
| `SessionStart` | When `claude` opens | Load context, print a streak banner |
| `Stop` | When the conversation ends | Save state, send notifications |
| `PreCompact` | Before automatic context compaction | Snapshot important context to disk |
| `UserPromptSubmit` | After you hit enter | Prepend reminders, log prompts |

### Exercise: Read Your Own Hooks
Open `.claude/settings.local.json` in your project. Find the `hooks` section. Pick one hook and trace what it does — read the script it points to, understand when it fires, predict what would happen if you removed it. (Don't actually remove it.)

## Module 4: MCP Servers — Borrowed Superpowers

### Concept: What's MCP?
MCP (Model Context Protocol) is how Claude Code talks to external tools — web scrapers, databases, design tools, your calendar. An MCP server is a small program that exposes a set of tools, and Claude can call them just like it calls Read or Bash. The tools live OUTSIDE Claude Code, but Claude can use them as if they were built in.

**Predict:** Why not just write a skill that runs `curl` instead of using an MCP server for web scraping?

**Reveal:** Two reasons. First, MCP servers are **stateful** — `firecrawl` keeps API quota, `context7` indexes documentation, your Telegram bot remembers chat IDs. Skills can't hold state across calls. Second, MCP servers handle the **gnarly stuff** — auth, retries, rate limits, response parsing. Writing that yourself in a skill is fine for one-off scripts but quickly turns into a maintenance bog.

### Concept: Common MCP Servers
| Server | What It Adds |
|--------|--------------|
| `firecrawl` | Web scraping, search, content extraction |
| `context7` | Live documentation lookup (React, Prisma, etc.) |
| `chrome` | Browser automation — click, type, screenshot |
| `gmail` / `calendar` | Read mail, schedule events |
| `telegram` | Send messages to your phone |

You install MCP servers via your settings or via plugins that bundle them. Each one shows up as a set of tools (e.g., `mcp__firecrawl__scrape`) that Claude can call.

### Exercise: Use One You Already Have
Run `/mcp` to see which MCP servers are connected in your current session. Pick one and ask Claude to use it for something small — fetch a webpage with firecrawl, look up React hooks docs with context7. Notice how the tool call has a different prefix (`mcp__...`) than built-in tools.

## Module 5: Composition — Using Them Together

### Concept: The Real Power Is Combining
Each primitive is useful alone. They're transformative together. A skill that dispatches three subagents in parallel, each using firecrawl through MCP, with a SessionStart hook that pre-loads relevant context — that's a workflow no single tool gives you.

**Predict:** If you wanted Claude to research three competing libraries for a decision, which primitives would you reach for?

**Reveal:** All four. Subagents (one per library, in parallel for speed). Output style (`learning` so the comparison surfaces trade-offs, not just facts). MCP — `context7` for the docs of each library. Hook (a `PostToolUse` log so you can audit which sources each subagent actually read).

### Concept: When It's Too Much
| Situation | Skip the machinery |
|-----------|---------------------|
| One-off task you'll never repeat | Just ask directly |
| Less than 3 minutes of work | Subagent overhead isn't worth it |
| Pure code editing in a single file | Read + Edit, no orchestration |
| You're not sure what you want yet | Brainstorm first, structure later |

The primitives reward repeatable workflows. They punish reinventing-the-wheel for one-shot tasks.

### Exercise: Sketch a Workflow
Pick a task you do regularly — code review, dependency updates, weekly project status, anything. Write down which primitives would automate the boring parts of it. You don't have to build it. Just notice that you now know what tools fit the job.
