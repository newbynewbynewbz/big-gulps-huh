---
name: Terminal Basics
description: Navigate your computer from the command line — the environment where Claude Code lives
difficulty: beginner
estimated_sessions: 2-3
prerequisites: ["claude-code-basics"]
---

# Terminal Basics

## Module 1: Where Am I?

### Concept: The File System
Your computer organizes everything in folders (directories) and files, like a filing cabinet. The terminal lets you navigate this structure by typing commands instead of clicking.

**Predict:** When you open a terminal, where do you start? How would you find out?

**Reveal:** You start in your "home directory" — usually `/Users/yourname` on Mac. The command `pwd` (print working directory) tells you exactly where you are.

```bash
pwd
# Output: /Users/yourname
```

Think of `pwd` as asking "where am I right now?"

### Exercise: Find Yourself
Run these commands one at a time:
```bash
pwd              # Where am I?
ls               # What's here?
ls -la           # What's here, including hidden files?
```

Notice files starting with `.` (like `.claude/`, `.git/`) — these are hidden files that configure your tools. Claude Code and git both use hidden directories.

## Module 2: Moving Around

### Concept: Navigating Directories
`cd` (change directory) moves you between folders. Think of it like double-clicking a folder, but with typing.

**Predict:** If you're in `/Users/yourname` and you type `cd Desktop`, where are you now?

**Reveal:** You're in `/Users/yourname/Desktop`. You moved one folder deeper.

Key commands:
```bash
cd foldername    # Go into a folder
cd ..            # Go back up one level
cd ~             # Go home (your home directory)
cd -             # Go back to where you just were
```

### Exercise: Navigate Your Project
```bash
cd ~/Desktop          # Go to Desktop
ls                    # See your projects
cd your-project       # Enter your project
ls                    # See what's inside
cd src                # Go into source code (if it exists)
cd ..                 # Come back up
pwd                   # Confirm where you are
```

## Module 3: Looking at Files

### Concept: Reading Without Editing
Sometimes you just want to see what's in a file without opening an editor.

**Predict:** If a file is 10,000 lines long, would you want to see all of it at once?

**Reveal:** Probably not. That's why there are different commands for different situations:

```bash
cat file.txt         # Show the ENTIRE file (good for short files)
head -20 file.txt    # Show first 20 lines
tail -20 file.txt    # Show last 20 lines
less file.txt        # Scrollable view (press q to quit)
wc -l file.txt       # Just count the lines
```

### Exercise: Explore a File
Find a file in your project and try each command:
```bash
cat README.md
head -5 README.md
wc -l README.md
```

Pro tip: You don't need to memorize all this. You can always ask Claude: "How do I see the first 10 lines of a file?"

## Module 4: Finding Things

### Concept: Search Commands
Two essential search commands:
- `find` — searches for FILES by name
- `grep` — searches for TEXT inside files

**Predict:** You remember writing the word "TODO" somewhere in your code but can't remember which file. How would you find it?

**Reveal:**
```bash
grep -r "TODO" .                    # Search all files for "TODO"
grep -rn "TODO" --include="*.ts" .  # Search only .ts files, show line numbers
```

And to find a file by name:
```bash
find . -name "*.md"                 # Find all markdown files
find . -name "README*"              # Find files starting with README
```

### Exercise: Search Your Project
```bash
grep -rn "TODO" . --include="*.md"   # Find TODOs in markdown files
find . -name "*.md" | head -10       # Find first 10 markdown files
```

## Module 5: Creating and Moving Things

### Concept: File Operations
```bash
mkdir my-folder           # Create a directory
touch my-file.txt         # Create an empty file
cp file.txt copy.txt      # Copy a file
mv old.txt new.txt        # Rename (or move) a file
rm file.txt               # Delete a file (careful — no undo!)
rm -r folder/             # Delete a folder and everything in it
```

**Predict:** What's the difference between `mv` and `cp`?

**Reveal:** `cp` creates a duplicate — the original stays. `mv` moves or renames — the original is gone. Think of `cp` as photocopying and `mv` as physically picking something up and putting it somewhere else.

### Exercise: Practice File Operations
```bash
mkdir practice
cd practice
touch hello.txt
echo "Hello world" > hello.txt
cat hello.txt
cp hello.txt goodbye.txt
cat goodbye.txt
mv goodbye.txt see-ya.txt
ls
cd ..
rm -r practice
```

## Module 6: Pipes and Redirection

### Concept: Connecting Commands
The `|` (pipe) character sends the output of one command INTO another command. This is one of the most powerful ideas in the terminal.

**Predict:** What would `ls | wc -l` do?

**Reveal:** `ls` lists files, then `|` sends that list to `wc -l` which counts lines. Result: the number of files in your directory. You combined two simple commands into something useful.

More examples:
```bash
cat file.txt | grep "error"       # Show only lines containing "error"
ls | head -5                      # Show first 5 files
history | grep "git"              # Find git commands you've run before
```

### Exercise: Pipe Some Commands
```bash
ls -la | wc -l                       # How many items in this directory?
find . -name "*.md" | wc -l          # How many markdown files?
cat CLAUDE.md | grep -i "todo"       # Find TODOs in CLAUDE.md
```

## Module 7: You Don't Need to Memorize This

### Concept: Claude Is Your Terminal Tutor
Here's the secret: you're using Claude Code. You can always ask:
- "How do I find all files modified in the last day?"
- "What command shows disk usage?"
- "How do I compress a folder?"

Claude will give you the exact command. Over time, the common ones become muscle memory. The uncommon ones? Just ask.

### Exercise: Ask Claude
Think of something you'd want to do in the terminal. Ask Claude how. Try it. That's the workflow.
