# Story Agent

Execute a complete story workflow autonomously from requirements to implementation.

## Usage
```
/storyAgent [StoryID] [Description]
```

## What This Agent Does

This agent autonomously:
1. Extracts and validates requirements from the story
2. Generates Gherkin scenarios for BDD testing
3. Writes failing tests first (TDD Red phase)
4. Implements code to make tests pass (Green phase)
5. Refactors if needed (Refactor phase)
6. Validates no placeholder code exists
7. Runs all tests to ensure they pass
8. Commits the code with proper TDD commit messages

## Workflow

### Phase 1: Requirements Analysis
- Extract acceptance criteria from story
- Identify technical requirements
- Create implementation checklist
- Validate requirements completeness

### Phase 2: BDD Scenario Generation
- Generate Given-When-Then scenarios
- Cover happy path and edge cases
- Ensure scenarios match requirements
- Create scenario outline templates

### Phase 3: Test-First Development
- Write failing BDD tests based on Gherkin
- Ensure tests follow project conventions
- Run tests to confirm they fail (Red phase)
- No placeholder test implementations

### Phase 4: Implementation (SOLID & Clean Code)
- Implement ONLY enough code to pass tests
- No placeholder code or TODO comments
- Use proper types (no 'any' or fake types)
- Follow existing code conventions

#### SOLID Principles Enforcement:
- **S**ingle Responsibility: Each class/function does ONE thing
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable
- **I**nterface Segregation: Many specific interfaces over general
- **D**ependency Inversion: Depend on abstractions, not concretions

#### Clean Code Requirements:
- Functions < 20 lines
- Classes < 200 lines
- Max 3 parameters per function
- Descriptive names (no abbreviations)
- No nested ifs > 2 levels
- Early returns over else blocks
- Extract complex conditions to named functions

#### Documentation Requirements:
```typescript
/**
 * Authenticates a user with provided credentials.
 *
 * @param credentials - User login credentials
 * @param credentials.email - User's email address
 * @param credentials.password - User's password
 * @returns Promise resolving to authenticated user with JWT token
 * @throws {AuthenticationError} When credentials are invalid
 * @throws {RateLimitError} When too many attempts
 *
 * @example
 * const user = await authenticateUser({
 *   email: 'user@example.com',
 *   password: 'securePass123'
 * });
 */
export async function authenticateUser(credentials: LoginCredentials): Promise<AuthenticatedUser> {
  // Implementation
}
```

### Phase 5: Verification
- Run all tests and ensure they pass
- Check for type safety violations
- Scan for placeholder code
- Verify no console.log statements
- Check for magic values

### Phase 6: Self-Code Review & Fix

#### Clean Code Review:
- Check function length (< 20 lines)
- Check class size (< 200 lines)
- Check parameter count (≤ 3)
- Check nesting depth (≤ 2)
- Check naming (descriptive, no abbreviations)
- Check for code duplication
- Verify DRY principle

#### SOLID Review:
- Verify Single Responsibility
- Check for Open/Closed violations
- Validate Liskov Substitution
- Check Interface Segregation
- Verify Dependency Inversion

#### Documentation Review:
- Every public method has docblock
- All parameters documented
- Return types documented
- Exceptions documented
- Examples provided for complex methods
- No missing @param tags
- No missing @returns tags
- Run linting (eslint, tslint, ruff, etc.)
- Run type checking (tsc, mypy, etc.)
- Run build process
- Fix ALL issues found:
  * Linting errors
  * Type errors
  * Build failures
  * Import issues
- Re-run all checks until clean
- Perform code review:
  * Check for code smells
  * Verify SOLID principles
  * Check for DRY violations
  * Review error handling
  * Check for security issues
- Fix any issues found in review

### Phase 7: Self-Validation
- Re-read original requirements
- Verify EVERY requirement is implemented
- Check for cheating patterns:
  * Type aliases hiding 'any'
  * Fake test assertions
  * Placeholder implementations
  * Skipped requirements
  * console.log statements
- Run mutation testing to verify tests are real
- Compare implementation against acceptance criteria
- Generate compliance report

### Phase 8: Code Commit
- Stage all changes
- Create descriptive commit message
- Include story ID in commit
- Push to feature branch if configured
- Include validation report in commit message

## Example
```
/storyAgent PROJ-123 "Add user authentication with JWT"
```

## Success Criteria
- All tests passing
- Zero type errors
- No placeholder code
- No magic values
- Proper error handling
- Code follows conventions
- Committed to repository
- 100% requirements coverage
- Self-validation passed

## Self-Validation Checklist
Agent MUST verify it didn't:
- Create UnknownType or similar type aliases
- Write tests with fake assertions
- Skip any requirements
- Implement different behavior than specified
- Use TODO comments or placeholders
- Mock critical functionality in tests
- Change requirements to match implementation
- Use 'any' without documentation
- Create tests that always pass

## Validation Report Format
```
=== BUILD & QUALITY REPORT ===
Lint Status: PASSED ✓
Type Check: PASSED ✓
Build: SUCCESS ✓
Tests: ALL PASSING ✓
Coverage: XX%

Issues Fixed During Review:
- Fixed 12 linting errors
- Fixed 3 type errors
- Removed 2 console.log statements
- Added error handling to 4 functions

=== SELF-VALIDATION REPORT ===
Requirements Implemented: X/X ✓
Tests Written First: YES ✓
All Tests Failed Initially: YES ✓
No Placeholder Code: YES ✓
No Type Cheating: YES ✓
Acceptance Criteria Met: X/X ✓
Mutation Testing Score: XX%

Requirements Traceability:
- REQ-1: Implemented in UserAuth.ts:45 ✓
- REQ-2: Implemented in JWT.ts:23 ✓
- REQ-3: Tested in auth.test.ts:67 ✓

Code Review Checks:
- SOLID Principles: PASSED ✓
  * Single Responsibility: ✓
  * Open/Closed: ✓
  * Liskov Substitution: ✓
  * Interface Segregation: ✓
  * Dependency Inversion: ✓
- Clean Code: PASSED ✓
  * Function length: Max 18 lines ✓
  * Class size: Max 175 lines ✓
  * Parameter count: Max 3 ✓
  * Nesting depth: Max 2 ✓
- Documentation: COMPLETE ✓
  * All public methods: Documented ✓
  * All parameters: Documented ✓
  * All returns: Documented ✓
  * Examples provided: YES ✓
- DRY Principle: PASSED ✓
- Error Handling: COMPLETE ✓
- Security Review: PASSED ✓

No cheating detected ✓
==============================
```

## Agent Rules
- MUST write tests before implementation
- MUST use BDD format (Given-When-Then)
- CANNOT use 'any' type without justification
- CANNOT leave TODO comments
- CANNOT use console.log for debugging
- MUST handle all error cases
- MUST complete ALL requirements
- NO STOPPING until story is complete
- MUST self-validate against original requirements
- MUST prove tests actually test the requirements
- MUST trace each requirement to implementation
- CANNOT modify requirements to match implementation
- MUST fail if cheating is detected