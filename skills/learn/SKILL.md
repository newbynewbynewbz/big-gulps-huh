---
name: learn
description: Interactive tutor — built-in courses (Claude Code, Terminal, Git) + codebase exploration. Start here if you're new.
argument: "[topic|quiz|progress|contribute|achievements]"
model-hint: opus
---

# Learn — Interactive Tutor

An interactive tutor that teaches through Socratic questioning and hands-on exploration. Ships with built-in courses and discovers project-specific topics as your codebase grows.

## Arguments

| Input | Action |
|-------|--------|
| *(empty)* | Show menu: built-in courses + project topics |
| `<topic>` | Start or continue a learning session on that topic |
| `quiz` | Quick quiz on previously covered material |
| `progress` | Show learning progress across all courses/topics |
| `contribute` | Guide for creating a new course pack |
| `achievements` | Show badge progress dashboard |

## Step 1: Discover Available Content

### Built-in Courses

Course discovery uses a two-stage lookup so `/learn` works in any project — scaffolded or not:

1. **Scaffolded projects (preferred):** Scan `docs/courses/` in the current project for directories containing `course.md`. If found, use these — they may have been edited or extended after scaffolding.
2. **Non-scaffolded projects (fallback):** If `docs/courses/` doesn't exist or is empty, fall back to the plugin's built-in curriculum at `${CLAUDE_PLUGIN_ROOT}/template/docs/courses/`. When using the fallback, tell the user: "You're seeing the curated curriculum — run `/big-gulps-huh` if you want these copied into your project so you can edit them."

Read the YAML frontmatter of each `course.md` to get name, description, difficulty, and prerequisites.

Expected built-in courses:
1. Claude Code Basics (no prerequisites)
2. Terminal Basics (prerequisite: claude-code-basics)
3. Git Fundamentals (prerequisite: terminal-basics)
4. Security Basics (prerequisite: claude-code-basics)
5. Code Review Culture (prerequisite: claude-code-basics)
6. Working Smart with AI (prerequisite: claude-code-basics)

### Project Topics (Dynamic)
Count source files (exclude node_modules, .git, docs, scripts, .claude):
```bash
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.js" -o -name "*.jsx" \) | grep -v node_modules | grep -v .git | wc -l
```

| File Count | Behavior |
|------------|----------|
| 0-5 | Show built-in courses only. Message: "Build some features and I'll find things to explore here." |
| 6-20 | Add "Recent changes" topic. Analyze `git log --oneline -10` for teachable areas. |
| 20+ | Analyze project structure. Identify 3-5 major areas (by directory grouping, imports, or module boundaries). Add as topics. |

### Check Progress
For each course/topic, check for `.claude/big-gulps-huh-progress/<name>.json` (plugin-owned per-project state — not scaffolded, auto-created on first write). Show completion status:
- Not started
- In progress (N/M sessions)
- Completed

## Step 2: Present Menu

### If no argument provided:

```
Welcome to /learn! Here's what I can teach you:

  Built-in courses:
    1. Claude Code Basics     [status]    <- Start here
    2. Terminal Basics         [status]
    3. Git Fundamentals        [status]

  Project topics:                          <- appears when codebase has substance
    4. [topic name]            (path/to/area/)
    5. [topic name]            (path/to/area/)
    ...

Pick a number, name a topic, or type 'surprise me'
```

Use AskUserQuestion with course names as options.

### If `quiz` argument: Skip to Step 6.
### If `progress` argument: Skip to Step 7.
### If `contribute` argument: Skip to Step 8.
### If `achievements` argument: Run `/achievements`.
### If topic name provided: Skip to Step 3 with that topic.

## Step 3: Session Setup

### For built-in courses:
Read the full `docs/courses/<name>/course.md`. This contains all modules, concepts, predict-then-reveal prompts, and exercises. Follow the course content as written — it IS the curriculum.

### For project topics:
Read the relevant source files. Identify 3-5 teachable concepts in that area (patterns, architecture decisions, data flow, error handling, etc.).

### Pick a Mentor

Use AskUserQuestion:

```
Pick your mentor style for this session:

  1. The Professor — structured, builds from fundamentals
     "Let's understand WHY before HOW"

  2. The Practitioner — hands-on, example-driven
     "Let me show you what happens when..."

  3. The Philosopher — Socratic, explores trade-offs
     "What would happen if we chose differently?"
```

Load existing progress from `.claude/big-gulps-huh-progress/<topic>.json` if it exists. Resume from where they left off.

## Step 4: Teaching Session (3-5 Rounds)

### For built-in courses:
Follow the modules in course.md sequentially. Each module has:
- **Concept** sections with predict-then-reveal prompts
- **Exercise** sections with hands-on tasks

Present one concept at a time. Use AskUserQuestion for predictions. Reveal answers, then connect to broader patterns.

### For project topics:
Use the predict-then-reveal method with actual project code:
1. **Set up:** Show a code snippet from the project
2. **Predict:** Ask what they think it does or why it's written this way
3. **Reveal:** Explain the actual behavior and reasoning
4. **Connect:** Link to broader patterns in the codebase
5. **Challenge:** Pose a "what if" variation

### Difficulty Scaling
- Correct predictions → increase difficulty (more complex code, deeper concepts)
- Incorrect predictions → simplify (break down further, more context)

### Adaptive Learning

Read `.claude/learning-state.json` to personalize. If the file doesn't exist (the user hasn't run `/big-gulps-huh` yet), create it with the default shape:

```json
{
  "version": 1,
  "experience_level": "unknown",
  "courses_completed": [],
  "courses_in_progress": {},
  "skills_used": {},
  "common_mistakes": [],
  "streak_days": 0,
  "last_session": null
}
```

Then personalize:
- If `common_mistakes` includes patterns relevant to current topic, emphasize those areas
- If quiz accuracy for this topic is > 90%, offer to skip ahead
- If quiz accuracy is < 60%, slow down and add more examples
- Track `skills_used` to suggest hands-on exercises with skills the user hasn't tried

Update `.claude/learning-state.json` after each session:
```json
{
  "version": 1,
  "experience_level": "some",
  "courses_completed": ["claude-code-basics"],
  "courses_in_progress": { "git-fundamentals": { "module": 2, "score": 85 } },
  "skills_used": { "health": 12, "preflight": 8, "code-review": 3 },
  "common_mistakes": ["console-log-left-in", "missing-catch"],
  "streak_days": 5,
  "last_session": "2026-03-08"
}
```

### Mentor Voice
Adapt presentation style to the chosen mentor:
- **Professor:** Structured explanations, analogies, "the reason this matters is..."
- **Practitioner:** "Watch what happens when...", debugging scenarios, real examples
- **Philosopher:** Questions back at them, trade-off exploration, "but what if..."

## Step 5: Wrap-Up

After 3-5 rounds:

1. **Hands-on challenge** — small coding task related to what was covered. Use real project files. Guide with hints, not solutions.

2. **Key takeaways** — 3-5 bullet points summarizing what was learned.

3. **Update progress** — Write `.claude/big-gulps-huh-progress/<topic>.json` (mkdir -p the directory on first write — it's plugin-owned per-project state, not scaffolded):
```json
{
  "topic": "claude-code-basics",
  "sessions": 1,
  "lastSession": "2026-03-06",
  "modulesCompleted": ["what-is-claude-code", "skills"],
  "modulesTotal": 5,
  "questionsCorrect": 8,
  "questionsTotal": 10,
  "difficulty": "beginner",
  "nextModule": "claude-md",
  "mentor": "professor"
}
```

3b. **Update learning state** — Write `.claude/learning-state.json`:
- Update `courses_in_progress` or `courses_completed`
- Update `skills_used` if any skills were demonstrated
- Track accuracy in `common_mistakes` if incorrect predictions were about common issues

4. **Suggest next** — Based on what was learned, suggest the next course or topic.

5. **Review questions** — Generate 2-3 questions to revisit next session.

## Step 6: Quiz Mode

When `quiz` argument is passed:

1. Scan all progress.json files for completed or in-progress courses
2. Generate 5 questions mixing:
   - **Recall** — "What does `git stash` do?"
   - **Application** — Show a code snippet, ask what command to run
   - **Analysis** — "Why does this project use conventional commits?"
3. Use actual project code where possible (for project topics)
4. Score and identify weak areas
5. Suggest review sessions for low-scoring topics

If no progress exists: "You haven't started any courses yet. Try `/learn` to begin with Claude Code Basics."

## Step 7: Progress Dashboard

When `progress` argument is passed:

```
Learning Progress
==================

Built-in Courses:
  Claude Code Basics    ████████░░  4/5 modules | 80% accuracy
  Terminal Basics        ██████░░░░  3/5 modules | 90% accuracy
  Git Fundamentals       ░░░░░░░░░░  Not started

Project Topics:
  Authentication flow    ██░░░░░░░░  1 session | 60% accuracy
  State management       ░░░░░░░░░░  Not started

Total sessions: 8 | Overall accuracy: 78%

Suggestion: Continue Terminal Basics (2 modules remaining)
```

## Step 8: Contribute a Course

When `contribute` argument is passed:

1. Show the course pack format:
```
Want to create a course? Here's how:

  1. Create a folder: docs/courses/your-topic/
  2. Create course.md with this structure:

     ---
     name: Your Course Name
     description: One-line description
     difficulty: beginner|intermediate|advanced
     estimated_sessions: 2-4
     prerequisites: []
     ---

     # Course Name

     ## Module 1: Topic Name

     ### Concept: What Is X?
     [Explain the concept]

     **Predict:** [Ask what they think]
     **Reveal:** [Show the answer]

     ### Exercise: Try X
     [Hands-on task with real commands]

  3. Your course appears in /learn automatically

Tips:
  - Use predict-then-reveal for every concept
  - Include hands-on exercises with real commands
  - Keep modules focused — one concept each
  - Add prerequisites if your course builds on others
  - Test your course by running /learn <your-topic>
```

2. Auto-suggest course ideas based on the codebase:
   - Complex areas with many files or dependencies
   - Areas with low or no test coverage
   - Recently refactored code worth documenting
   - Patterns that appear in multiple places across the project
