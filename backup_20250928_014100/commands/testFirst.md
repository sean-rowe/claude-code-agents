---
description: Create failing tests before implementation (TDD Red phase)
argument-hint: <component> <test-type>
allowed-tools: Write, MultiEdit, Bash, Read
---

Generate failing tests for $ARGUMENTS following TDD principles.

Test types:
- unit: Unit tests for individual functions/methods
- integration: Integration tests for component interactions
- tsqlt: tSQLt tests for SQL stored procedures
- e2e: End-to-end tests

Requirements:
1. Write comprehensive test cases that cover:
   - Happy path scenarios
   - Edge cases
   - Error conditions
   - Boundary values

2. Ensure tests:
   - Compile but FAIL initially (Red phase)
   - Have descriptive names explaining what they test
   - Use specific assertions (no placeholder assertions)
   - Include realistic test data

3. Anti-fake checks:
   - NO Assert.Pass() or similar fake assertions
   - NO commented-out test code
   - NO empty test methods
   - All test data must be realistic

4. After creating tests, verify they fail by running them

The implementation should NOT be written yet - only the tests.
This is the RED phase of Red-Green-Refactor.