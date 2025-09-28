---
description: TDD-focused commit workflow
argument-hint: <phase>
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*)
---

## Context
- Current git status: !`git status`
- Current git diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`

Create a TDD-phase commit for phase: $ARGUMENTS

Phases:
- red: Commit failing tests
- green: Commit minimal implementation that passes tests
- refactor: Commit code improvements

Commit message format:
- Red: "test: add failing tests for [feature]"
- Green: "feat: implement [feature] to pass tests"
- Refactor: "refactor: improve [component] implementation"

Requirements:
1. Verify appropriate files are staged
2. Ensure commit matches TDD phase
3. No placeholder code in commits
4. All tests appropriate to phase

Stage and commit the changes with appropriate message.