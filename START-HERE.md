# Ready to build some cool shit?

Someone sent you this because they want to build with you. You don't need to know how to code — you need to know how to tell an AI what to build. That's what this sets you up for.

10 minutes. Let's go.

---

## What you're about to get

An AI-powered workspace where you describe what you want and Claude builds it. You think, you direct, you decide — Claude writes the code. It's like having a senior developer who never sleeps, never judges your questions, and actually listens.

You'll also get:
- **Guardrails** so you can't accidentally break things
- **8 portable skills** for code review, security, testing, and more
- **6 built-in courses** that teach you interactively (Claude Code, terminal, git, security, code review, working smart with AI)
- **Achievement system** that tracks your progress and badges earned
- **Learning paths** that adapt based on your experience level

---

## Step 1: Install Claude Code

If you haven't already, grab it here:
https://code.claude.com/docs/en/overview

This is the AI that does the building. It lives in your terminal — that's the black window with the blinking cursor that hackers use in movies. Except you're going to use it for real.

---

## Step 2: Open your terminal

**Mac:** Press Cmd + Space, type "Terminal", press Enter
**Windows:** Press the Windows key, type "Terminal", press Enter

A window with a blinking cursor appears. That's it. You're in.

---

## Step 3: Install the Big Gulps Huh plugin

First, find the folder you downloaded. If it's on your desktop it's probably at `~/Desktop/big-gulps-huh` — remember wherever it is, you'll paste that path in a moment.

Open a terminal in any folder (the plugin is global once installed — you don't have to be "inside" it). Then start Claude Code:

    claude

Once Claude is running, add the Big Gulps Huh marketplace, then install the plugin:

    /plugin marketplace add ~/Desktop/big-gulps-huh

    /plugin install big-gulps-huh@big-gulps-huh

(Replace `~/Desktop/big-gulps-huh` with the actual path if you downloaded it somewhere else. The `@big-gulps-huh` suffix on the install command is the marketplace name — it happens to match the plugin name, which is fine.)

You only need to add the marketplace once per machine. After that, `/plugin install big-gulps-huh@big-gulps-huh` works from anywhere.

---

## Step 4: Create your project

From inside Claude:

    /big-gulps-huh new my-first-project

Call it whatever you want — `my-app`, `cool-thing`, `world-domination`. Claude will ask a couple questions, set everything up, and get you ready to build.

---

## Now what?

Build something. Tell Claude what you want to make:
- "Build me a personal website"
- "Make a to-do app"
- "Create a countdown timer for my birthday"
- "I want to build a recipe organizer"

You don't need a grand plan. Start small. Start weird. Start anywhere.

When you get stuck or curious about how things work, type `/learn` — there are built-in lessons that teach you interactively. But you don't have to study first. Build first, learn as questions come up.

---

## Got a passcode?

If someone gave you one:

    /big-gulps-huh new my-project --passcode YOUR_CODE

This skips the guided setup. You know the deal already.

---

## Stuck?

Just tell Claude. "I have no idea what I'm doing" is a perfectly valid thing to type. That's literally what it's here for.

You're not supposed to know everything. You're supposed to build things and figure it out along the way. That's how everyone does it — even the people who sent you this link.

---

*Now go make something.*
