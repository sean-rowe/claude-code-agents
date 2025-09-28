---
description: Fix all errors and warnings until tests pass
argument-hint: [component?]
allowed-tools: Bash, Read, Edit, MultiEdit, Grep
---

Fix ALL compilation errors, warnings, and test failures for: $ARGUMENTS

Workflow:
1. Compile the project and identify ALL issues
2. Fix compilation errors first (in order of dependency)
3. Address ALL warnings (treat warnings as errors)
4. Run tests and fix ALL failures
5. Repeat until clean

Requirements:
- ZERO compilation errors
- ZERO warnings
- ALL tests must pass
- No placeholder code remains

Do not stop until everything builds cleanly and all tests pass.
Every error matters - fix them all, no matter how trivial they seem.

Remember: "It doesn't matter how important or unimportant you think an error is, it needs to be fixed."