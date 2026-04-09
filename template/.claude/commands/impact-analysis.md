---
name: impact-analysis
description: Change blast radius analyzer — maps dependencies, rates risk, suggests test scope before you modify a file
argument: "<file>"
model-hint: sonnet
---

# Impact Analysis — Change Blast Radius Analyzer

Analyze the blast radius of changing a specific file before you modify it. Use before modifying any shared utility, type definition, store, or service file.

**Target file:** $ARGUMENTS

If `$ARGUMENTS` is empty, ask the user which file to analyze.

## Step 1: Launch Explore Agent

Launch one agent with `subagent_type: "Explore"`:

```
Analyze the change blast radius for: [TARGET_FILE]

Step 1: Read the target file. List ALL its exports (functions, types, interfaces, constants, classes).

Step 2: Find all DIRECT importers — files that import from the target file. For each, note which specific exports they use.

Step 3: For each direct importer, find ITS importers (TRANSITIVE dependents, one level deep). This shows cascade depth.

Step 4: Check test coverage:
- Does the target file have a corresponding test file?
- Do the direct importers have test files?
- Which specific exports are tested?

Step 5: Determine risk level:
- LOW: 0-2 direct dependents, all tested
- MEDIUM: 3-5 direct dependents
- HIGH: 6+ direct dependents
- CRITICAL: File is a type/interface definition or core utility (changes cascade everywhere)

Step 6: Output:

## Target File Analysis
- File: [path]
- Exports: [count] ([list])
- Lines of code: [count]

## Dependency Graph

### Direct Importers ([count])
| File | Imports Used | Has Tests |
(sorted by import count)

### Transitive Dependents ([count])
| File | Via (direct importer) | Depth |

## Test Coverage
- Target file tested: yes/no (test file path if yes)
- Direct importers tested: X/Y
- Coverage assessment: GOOD / PARTIAL / POOR

## Risk Level: [LOW/MEDIUM/HIGH/CRITICAL]

## Recommended Actions Before Changing
1. [specific tests to run]
2. [specific files to review after changing]
3. [specific patterns to preserve for backward compatibility]

## Safe Change Checklist
- [ ] Run existing tests for target file
- [ ] Run tests for direct importers
- [ ] Check type compatibility if changing exports
- [ ] Run type checker after changes
```

## Step 2: Present Results

After the agent completes, present the full analysis. Highlight the risk level prominently. If CRITICAL, warn the user to proceed with extra caution.
