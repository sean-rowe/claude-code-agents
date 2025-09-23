---
description: Fix fake tests with real assertions
allowed-tools: Grep, Read, Edit, MultiEdit
---

Find and fix ALL fake test assertions:

1. DETECT fake tests:
   - Assert.Pass()
   - Assert.True(true)
   - Assert.False(false)
   - No assertions
   - Commented assertions
   - Try/catch hiding failures

2. UNDERSTAND intent:
   - What should test verify?
   - What is the requirement?
   - What behavior to test?

3. WRITE real assertions:
   - Specific value checks
   - Behavior verification
   - State validation
   - Exception testing
   - Side effect checks

4. VERIFY tests:
   - Tests can fail
   - Tests catch regressions
   - Tests document behavior
   - Tests are maintainable

Every test must have meaningful assertions.
Tests are the law - they must be honest.