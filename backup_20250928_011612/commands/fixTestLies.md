---
description: Fix fake tests with real assertions
allowed-tools: Bash, Grep, Read, Edit, MultiEdit
---

Find and fix ALL fake test assertions:

1. RUN ALL TESTS FIRST:
   - Execute full test suite (npm test, go test ./..., pytest, etc.)
   - Record failing tests
   - Note test execution time
   - Identify test framework

2. DETECT fake tests:
   - Assert.Pass()
   - Assert.True(true)
   - Assert.False(false)
   - No assertions
   - Commented assertions
   - Try/catch hiding failures

3. UNDERSTAND intent:
   - What should test verify?
   - What is the requirement?
   - What behavior to test?

4. WRITE real assertions:
   - Specific value checks
   - Behavior verification
   - State validation
   - Exception testing
   - Side effect checks

5. VERIFY tests:
   - Tests can fail
   - Tests catch regressions
   - Tests document behavior
   - Tests are maintainable

6. RUN TESTS AGAIN:
   - Ensure all tests still pass
   - Verify fake tests now have real assertions
   - Confirm no regressions introduced

Every test must have meaningful assertions.
Tests are the law - they must be honest.