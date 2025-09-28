---
description: Implement feature to make tests pass (TDD Green phase)
argument-hint: <story-id> <component>
allowed-tools: Write, Edit, MultiEdit, Bash, Read
---

Implement $ARGUMENTS to make the failing tests pass.

Requirements:
1. Verify tests exist and are currently failing
2. Write the MINIMUM code to make tests pass (no over-engineering)
3. NO placeholder implementations allowed:
   - No TODO comments
   - No hardcoded values
   - No empty catch blocks
   - Complete error handling required

4. Run tests continuously during implementation
5. When ALL tests pass, stop (save refactoring for later)

Validation:
- All tests must pass
- No compilation warnings
- No placeholder code
- Proper error handling implemented

This is the GREEN phase of Red-Green-Refactor.
Focus on making tests pass, not on perfect code (that's for refactor phase).