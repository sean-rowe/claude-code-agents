---
description: Create stored procedure with tSQLt tests
argument-hint: <procedure-name> <parameters> [return-type]
allowed-tools: Write, MultiEdit, Bash
---

Create stored procedure: $ARGUMENTS

Workflow:
1. Create tSQLt test class first
2. Write comprehensive failing tests:
   - Happy path scenarios
   - Error conditions
   - Edge cases
   - NULL handling
   - Transaction rollback scenarios

3. Implement stored procedure:
   - Parameter validation
   - Business logic
   - Error handling with TRY/CATCH
   - Proper transaction management
   - Meaningful error messages

4. Verify all tests pass

Requirements:
- Tests must cover all code paths
- Follow naming conventions
- No dynamic SQL without validation
- Complete error handling
- No hardcoded values

Test-first approach is mandatory!