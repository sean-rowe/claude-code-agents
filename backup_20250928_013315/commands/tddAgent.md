# TDD Agent

Strict Test-Driven Development agent that enforces Red-Green-Refactor cycle.

## Usage
```
/tddAgent [Feature] [Component]
```

## What This Agent Does

This agent enforces STRICT TDD:
1. RED: Write failing tests FIRST
2. GREEN: Write MINIMAL code to pass
3. REFACTOR: Clean up while keeping tests green
4. VERIFY: Ensure no fake implementations

## Workflow

### RED Phase (Tests First)
```typescript
// ALWAYS write test BEFORE implementation
describe('UserAuthentication', () => {
  it('should authenticate valid user with JWT', async () => {
    // Given - setup
    const credentials = { email: 'test@example.com', password: 'validPass123' };

    // When - action
    const result = await authenticateUser(credentials);

    // Then - assertion
    expect(result.token).toBeDefined();
    expect(result.user.email).toBe(credentials.email);
  });

  it('should reject invalid credentials', async () => {
    // Test MUST fail initially
  });
});
```

### GREEN Phase (Minimal Implementation)
- Write ONLY enough code to pass the test
- NO extra features
- NO optimization yet
- Just make it work

### REFACTOR Phase
- Clean up duplication
- Improve naming
- Extract constants
- Tests MUST still pass

## Rules This Agent Enforces

### MUST DO:
- Write test FIRST (before ANY implementation)
- Run test to see it FAIL
- Use BDD format (Given-When-Then)
- Test behavior, not implementation
- One assertion per test concept
- Test edge cases and errors

### MUST NOT DO:
- Write implementation before test
- Write fake tests that always pass
- Use `test.skip` or commented tests
- Mock everything (test real behavior)
- Write tests after implementation
- Change tests to make bad code pass

## Test Patterns

### BDD Structure
```typescript
describe('Component', () => {
  describe('when condition', () => {
    it('should expected behavior', () => {
      // Given
      const setup = createSetup();

      // When
      const result = performAction(setup);

      // Then
      expect(result).toMatchExpectation();
    });
  });
});
```

### Database Testing (tSQLt)
```sql
CREATE PROCEDURE [test].[test UserRepository saves user]
AS
BEGIN
  -- Arrange
  EXEC tSQLt.FakeTable 'dbo.Users';

  -- Act
  EXEC dbo.SaveUser @Email = 'test@example.com', @Name = 'Test User';

  -- Assert
  EXEC tSQLt.AssertEquals 1, (SELECT COUNT(*) FROM dbo.Users);
END;
```

## Coverage Requirements
- Minimum 80% code coverage
- 100% coverage of critical paths
- All error paths tested
- All edge cases covered

## Verification Points
- [ ] Test written BEFORE implementation
- [ ] Test failed before implementation
- [ ] Implementation is minimal
- [ ] No placeholder code
- [ ] No console.log
- [ ] No 'any' types
- [ ] All tests passing
- [ ] Coverage meets requirements

## Example Usage
```
/tddAgent "User login" "AuthenticationService"

Agent will:
1. Write failing login tests
2. Implement minimal auth service
3. Refactor for clean code
4. Verify all tests pass
```

## Anti-Patterns Detected
- Implementation without test
- Tests that never failed
- Fake assertions like `expect(true).toBe(true)`
- Over-mocked tests
- Tests with no assertions
- Implementation-coupled tests

## Final Output
- All tests passing
- Clean, refactored code
- No fake implementations
- Proper error handling
- Full test coverage
- Ready for production