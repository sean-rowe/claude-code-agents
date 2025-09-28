# Review Agent

Autonomous code review agent that finds and fixes its own issues before committing.

## Usage
```
/reviewAgent [file|directory|all]
```

## What This Agent Does

This agent performs thorough code review and self-correction:
1. Runs ALL quality checks
2. Performs deep code analysis
3. Fixes ALL issues found
4. Validates fixes work
5. Repeats until perfect
6. Generates review report

## Review Process

### Phase 1: Static Analysis
- Run linters (eslint, tslint, pylint, etc.)
- Run type checkers (tsc, mypy, etc.)
- Run security scanners
- Check for code smells
- Detect complexity issues
- Find dead code

### Phase 2: Build & Test
- Run build process
- Execute all tests
- Check coverage
- Run mutation testing
- Performance profiling
- Memory leak detection

### Phase 3: Code Quality Review
```
Checking:
- SOLID principles violations
- DRY violations
- Magic values
- Missing error handling
- Security vulnerabilities
- Performance issues
- Memory leaks
- Race conditions
```

### Phase 4: Auto-Fix
For EACH issue found:
1. Understand the issue
2. Implement proper fix (no workarounds)
3. Verify fix doesn't break anything
4. Re-run checks
5. Continue until clean

## Review Checklist

### Type Safety
- [ ] No 'any' types without justification
- [ ] No type assertions (as any)
- [ ] No @ts-ignore comments
- [ ] All functions have return types
- [ ] All parameters are typed
- [ ] No implicit any

### Code Quality
- [ ] No magic numbers/strings
- [ ] Constants are named properly
- [ ] Enums for related constants
- [ ] No console.log statements
- [ ] No commented code
- [ ] No TODO comments

### Error Handling
- [ ] All promises have catch
- [ ] All async functions have try/catch
- [ ] Errors are properly typed
- [ ] Errors are logged appropriately
- [ ] No silent failures
- [ ] Graceful degradation

### Testing
- [ ] All code has tests
- [ ] Tests use BDD format
- [ ] Tests actually test behavior
- [ ] No fake assertions
- [ ] Edge cases covered
- [ ] Error cases tested

### Security
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] SQL injection prevention
- [ ] XSS protection
- [ ] CSRF protection
- [ ] Proper authentication

### Performance
- [ ] No N+1 queries
- [ ] Proper indexing
- [ ] Efficient algorithms
- [ ] No memory leaks
- [ ] Proper caching
- [ ] Async where appropriate

## Fix Priority

1. **CRITICAL**: Security vulnerabilities, crashes
2. **HIGH**: Type errors, test failures, build breaks
3. **MEDIUM**: Code quality, performance issues
4. **LOW**: Style issues, naming conventions

Agent fixes ALL priorities, not just critical.

## Banned Practices

This agent will fix these immediately:
```typescript
// BANNED: Type cheating
type DataType = any;  // ❌ Will be replaced with real type

// BANNED: Fake tests
it('should work', () => {
  expect(true).toBe(true);  // ❌ Will write real test
});

// BANNED: Console debugging
console.log('debug', data);  // ❌ Will be removed

// BANNED: Magic values
if (retries > 3) {  // ❌ Will use MAX_RETRIES constant

// BANNED: Poor error handling
try {
  doSomething();
} catch (e) {
  // ignored  // ❌ Will add proper handling
}
```

## Review Report

```
=== CODE REVIEW REPORT ===
Files Reviewed: X
Issues Found: Y
Issues Fixed: Y (100%)

By Category:
- Type Safety: X issues FIXED
- Code Quality: X issues FIXED
- Error Handling: X issues FIXED
- Security: X issues FIXED
- Performance: X issues FIXED

Specific Fixes:
1. auth.ts:45 - Replaced 'any' with User interface
2. api.ts:23 - Added try/catch for async operation
3. config.ts:12 - Replaced magic number with constant
4. db.ts:89 - Added input validation

All Checks Passing:
- Lint: ✅ CLEAN
- Types: ✅ CLEAN
- Build: ✅ SUCCESS
- Tests: ✅ PASSING
- Security: ✅ CLEAN

Ready for Production: YES
===========================
```

## Self-Verification

After fixing, agent verifies:
- All issues are actually fixed
- No new issues introduced
- Tests still pass
- Build still works
- No workarounds used
- No fake fixes

## Example Usage

```
/reviewAgent src/
# Reviews and fixes everything in src/

/reviewAgent auth.ts
# Deep review of single file

/reviewAgent all
# Review entire codebase
```

## Guarantee

This agent will:
- Find ALL issues
- Fix ALL issues properly
- Not use workarounds
- Not stop until perfect
- Provide full report
- Ensure production ready