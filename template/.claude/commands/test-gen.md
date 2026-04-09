---
name: test-gen
description: Test gap analyzer + generator — finds untested code, generates test skeletons, validates quality
model-hint: sonnet
---

# Test Gen — Test Gap Analyzer & Generator

Analyze test coverage gaps and generate test files for the most critical untested code.

## Step 1: Coverage Analysis (Explore agent)

Launch an Explore agent to:

1. Identify the project's test runner and configuration
2. Find all source files and their corresponding test files
3. Identify files with NO test coverage (no corresponding test file)
4. If a coverage tool is available, run it and parse results:
   - Jest/Vitest: `--coverage --silent`
   - Pytest: `--cov`
   - Go: `-cover`
   - Cargo: Use `cargo tarpaulin` or `cargo llvm-cov`
5. Rank untested files by criticality:
   - Stores/state > Services > Hooks/utilities > Components/views

## Step 2: Pattern Extraction (Explore agent)

After Step 1, launch an Explore agent to:

1. Read 2-3 existing test files to extract testing patterns
2. Document:
   - Test framework and assertion style
   - Mock patterns (how are dependencies mocked?)
   - Test file naming convention
   - Setup/teardown patterns
   - Common test utilities or helpers
3. Output a "Test Pattern Guide" for the next agent

## Step 3: Test Generation (general-purpose agent)

After Step 2, launch a general-purpose agent:

1. Read the top 3 untested files (from Step 1 ranking)
2. For each file, generate a complete test file that:
   - Follows the exact patterns from the Test Pattern Guide
   - Tests all exported functions/classes
   - Covers happy path, error cases, and edge cases
   - Uses the project's assertion style
   - Includes proper types (if TypeScript)
3. DO NOT write the files — output the complete test content for review

## Step 4: Present Results

1. **Coverage Summary** — Table of files sorted by coverage
2. **Priority Ranking** — Top 10 untested files by criticality
3. **Generated Tests** — Complete test file content for top 3 files
4. **Next Steps** — What to test after these are added

Ask the user which test files they want to write to disk.
