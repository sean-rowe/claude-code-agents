---
description: Fix issues iteratively with self-verification after each fix
allowed-tools: TodoWrite, Grep, Read, Edit, MultiEdit, Bash
---

Fix code issues with continuous self-verification loop.

## INTELLIGENT FIX WORKFLOW:

### STEP 1: SCAN & CREATE DETAILED PLAN
Run initial audit and create a VISIBLE, CONCRETE plan:

```markdown
## 📋 VERIFICATION PLAN - [Total: X issues]

### Files to Fix (grouped by component)

#### Authentication Module
- [ ] **src/auth/login.js:45** - TODO: implement OAuth → Add Google OAuth integration
- [ ] **src/auth/login.js:89** - Type 'any' → Define LoginCredentials interface
- [ ] **src/auth/session.js:23** - Hardcoded secret → Move to process.env.JWT_SECRET

#### Payment Service
- [ ] **src/payment/processor.js:67** - NotImplementedException → Implement Stripe webhook handler
- [ ] **src/payment/retry.js:34** - TODO: exponential backoff → Add retry with delays [1s, 2s, 4s]

#### Test Suite
- [ ] **tests/auth.test.js:12** - test('login') → Convert to it('should authenticate valid user')
- [ ] **tests/payment.test.js:45** - Assert.Pass() → Test actual payment processing

Progress: 0/X fixed
```

This plan is your roadmap - you MUST complete every item.

### STEP 2: CONTEXT-AWARE FIXING

For each file with issues:
1. **Read entire file first** - understand the full context
2. **Check related files** - imports, interfaces, tests
3. **Fix ALL issues in that file** in one operation
4. **Verify just that file** immediately

### Fix Strategies:

#### TODO/FIXME Comments
```javascript
// Before: // TODO: Add validation
// After: Implement actual validation based on business rules found in tests/specs
```

#### NotImplementedException
```csharp
// Before: throw new NotImplementedException();
// After: Implement based on interface contract and test expectations
```

#### Fake Assertions
```javascript
// Before: assert.Pass()
// After: assert.equal(result.status, 'success')
//        assert.notNull(result.data)
```

#### Empty Catch Blocks
```java
// Before: catch(Exception e) {}
// After: catch(Exception e) {
//          logger.error("Operation failed", e);
//          throw new ServiceException("Unable to process request", e);
//        }
```

### STEP 3: INCREMENTAL VERIFICATION

After EACH file is fixed:
```bash
# Verify only the fixed file
grep -E "TODO|FIXME|Assert\.Pass|NotImplementedException" <fixed_file>

# If clean, mark todo complete
# If not clean, fix remaining issues
# Don't move to next file until current is perfect
```

### STEP 4: FULL VERIFICATION

After all todos complete:
1. Run complete /auditFake scan
2. If new issues found (maybe from fixes creating new patterns):
   - Add to todo list
   - Continue fixing
3. Repeat until pristine

### STEP 5: VALIDATION

Run these checks:
- Build/compilation check
- Test suite execution
- Linter verification
- Type checking (if applicable)

If any fail, fix the issues (not the tests!)

### STEP 6: COMMIT WITH CONFIDENCE

Create detailed commit:
```
fix: eliminate all placeholder code

Files cleaned: X
- src/auth/login.js: Implemented TODO validation
- tests/user.test.js: Replaced fake assertions
- services/payment.js: Completed implementation

All tests passing
No placeholder code remains
```

## SMART DECISIONS:

### When you see "TODO: implement this":
1. Look at tests to understand expected behavior
2. Check interfaces/types for contracts
3. Review similar implementations in codebase
4. Implement completely

### When you see empty/fake implementation:
1. Understand what it should do from context
2. Check calling code to see usage
3. Implement proper functionality
4. Add error handling

### When you see hardcoded values:
1. Check if .env.example exists
2. Look for config files
3. Move to appropriate configuration
4. Use sensible defaults

### When you see 'any' type:
1. Analyze how the variable is ACTUALLY used in the code
2. Check what properties are accessed, what methods are called
3. Define REAL interface based on actual usage
4. NEVER leave as 'any' - always use specific types
5. DON'T CHEAT by creating UnknownType or similar aliases

```typescript
// ❌ CHEATING - these are all wrong:
type UnknownType = any;
type GenericData = unknown;
type AnyObject = any;
interface UnknownData { [key: string]: any; }

// ✅ CORRECT - analyze and create real types:
// If you see: data.name, data.email, data.id being used
interface UserData {
  id: number;
  name: string;
  email: string;
}
```

### When creating/fixing tests:
1. ALWAYS use BDD format (describe/it/should)
2. Structure test as Given-When-Then:
   ```javascript
   describe('UserService', () => {
     it('should validate email format when registering user', () => {
       // Given: invalid email
       const invalidEmail = 'notanemail';

       // When: attempting registration
       const result = userService.register(invalidEmail, 'password');

       // Then: should return validation error
       expect(result.error).toBe('Invalid email format');
     });
   });
   ```
3. For SQL: Use tSQLt with test class structure
4. NEVER write simple unit tests like `test('add returns sum')`

### Production code standards:
1. NO comments like "in a real production environment..."
2. NO filenames with "final", "comprehensive", "complete"
3. Use standard naming: userService.js, NOT user-service-final.js
4. Put temporary scripts in /tmp directory ONLY
5. Write code as if it's going straight to production
6. NO console.log ANYWHERE:
   - Tests: Use test runner output (describe/it messages show progress)
   - Production: Use proper logger (winston, pino, bunyan)
   - Debug: Remove entirely, don't leave commented out
7. "Development scripts" = one-off scripts → must be in /tmp/
8. TypeScript: ALWAYS use ?? instead of ||:
   ```typescript
   // ❌ WRONG - treats 0, '', false as falsy
   const port = process.env.PORT || 3000;
   const name = user.name || 'Anonymous';

   // ✅ CORRECT - only null/undefined trigger default
   const port = process.env.PORT ?? 3000;
   const name = user.name ?? 'Anonymous';
   ```
9. NO COMMENTED OUT CODE:
   ```javascript
   // ❌ DELETE THESE:
   // const oldFunction = () => { ... }
   // if (deprecatedCheck) { ... }
   /*
   function oldImplementation() {
     return something;
   }
   */

   // ✅ OK (documentation):
   // This function handles user authentication
   // Returns: AuthToken object
   ```
   Git preserves history - DELETE commented code, don't keep it

10. MAGIC VALUES AND ENUMS:
   ```typescript
   // ❌ WRONG - Magic values everywhere
   if (status === 'active') { }
   if (retries > 3) { }
   if (timeout > 5000) { }
   if (userType === 2) { }

   // ✅ CORRECT - Named constants and enums
   enum Status { Active = 'active', Pending = 'pending' }
   const MAX_RETRIES = 3;
   const DEFAULT_TIMEOUT_MS = 5000;
   enum UserType { Guest, Regular, Admin }

   if (status === Status.Active) { }
   if (retries > MAX_RETRIES) { }
   if (timeout > DEFAULT_TIMEOUT_MS) { }
   if (userType === UserType.Admin) { }
   ```

11. C++ MODERN STANDARDS:
   ```cpp
   // ❌ WRONG - C-style/outdated
   void* buffer = malloc(100);
   int* ptr = (int*)buffer;
   char name[256];
   #define BUFFER_SIZE 256
   delete ptr;
   using namespace std; // in .h file

   // ✅ CORRECT - Modern C++
   auto buffer = std::make_unique<std::array<uint8_t, 100>>();
   int* ptr = static_cast<int*>(buffer.get());
   std::string name;
   constexpr size_t BUFFER_SIZE = 256;
   // smart pointer auto-deletes
   // never using namespace in headers
   ```

## VERIFICATION PROOF:

After EVERY fix, show:
```
✅ Fixed: [issue] in [file]:[line]
✅ Verified: No issues remain in [file]
✅ Tests: Still passing
```

Final proof:
```
✅ Full audit: ZERO issues found
✅ All tests: PASSING
✅ Build: SUCCESS
```

Start the iterative fix-and-verify process.