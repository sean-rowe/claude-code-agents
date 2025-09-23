---
description: Run autoFix in a loop until completely clean
allowed-tools: TodoWrite, Grep, Read, Edit, MultiEdit, Bash
---

## LOOP UNTIL CLEAN

Run fix cycles repeatedly until the codebase is completely clean, with ALL the same checks as autoFixAll.

### PROJECT-AWARE CHECKING:
1. FIRST: Detect project type (package.json, *.cpp, *.py, etc.)
2. THEN: Focus 80% effort on language-specific issues:

**C++ Project Priority:**
- void* pointers, C-style casts, raw pointers
- new/delete, malloc/free, #define macros
- using namespace std in headers
- char* strings, C arrays

**TypeScript Project Priority:**
- Type 'any', missing type annotations
- || instead of ?? for nullish coalescing
- Untyped function parameters/returns

**Python Project Priority:**
- Missing type hints
- Bare except: clauses
- Mutable default arguments

**Universal (20% effort):**
- TODO, FIXME, HACK comments
- Commented out code
- Debug print statements
- "In production..." comments

### INFINITE LOOP STRUCTURE:

```python
while True:
    # 1. Run FULL audit (all patterns from autoFixAll)
    issues = run_comprehensive_audit()

    # 2. Check if done
    if issues.count == 0:
        print("✅ COMPLETELY CLEAN - No issues found!")
        run_final_test_suite()
        break

    # 3. NO MATTER HOW MANY ISSUES - CONTINUE
    if issues.count > 1000:
        print(f"Found {issues.count} issues - fixing them ALL in batches")
        # DON'T stop with excuse about "extensive" issues
        # Break into batches: fix 50, commit, repeat

    print(f"## 📋 CYCLE PLAN - {issues.count} issues to fix")

    # 4. Fix ALL issues - even if 1400+
    batch_size = 50
    for i in range(0, issues.count, batch_size):
        batch = issues[i:i+batch_size]
        for issue in batch:
            fix_issue(issue)  # ACTUALLY FIX IT
            verify_fix(issue.file)
        commit_batch(f"Fixed batch {i//batch_size + 1}")

    # 5. Run tests after cycle
    run_tests()

    # 6. Loop back to step 1 - NEVER GIVE UP
    print(f"Cycle complete, {issues.count} fixed. Checking for more...")
```

CRITICAL: If there are 1400 errors, this loop runs until all 1400 are fixed.
It does NOT stop and explain why 1400 is "too many".

### EXECUTION:

#### CYCLE 1:
- Found 45 issues
- Fix all 45
- Commit each fix

#### CYCLE 2:
- Found 12 new issues (maybe from fixes)
- Fix all 12
- Commit each fix

#### CYCLE 3:
- Found 3 edge cases
- Fix all 3
- Commit each fix

#### CYCLE 4:
- Found 0 issues
- ✅ DONE!

### CRITICAL RULES (SAME AS autoFixAll):
1. Each cycle MUST complete ALL issues found
2. After each cycle, re-scan entire codebase
3. Only exit when a full scan finds ZERO issues
4. No limit on number of cycles
5. Keep looping until pristine
6. Apply ALL the same fixes as autoFixAll:
   - Replace || with ?? in TypeScript (YES, ALL OF THEM)
   - Remove ALL console.log (not convert, remove)
   - DELETE commented out code (not uncomment, delete)
   - Convert tests to BDD format
   - Move scripts to /tmp
   - Implement TODOs or remove them
   - Replace type 'any' with proper types (YES, EVERY SINGLE ONE)
   - DO NOT create UnknownType, DataType, or any alias for 'any'
   - DO NOT use 'as any' casts or // @ts-ignore
   - DO NOT use 'unknown' without fixing the actual usage
   - Fix all empty catch blocks
   - Remove "in production..." comments

   C++ SPECIFIC (FIX ALL OF THESE):
   - Replace void* with proper types or templates
   - Replace C-style casts with static_cast/dynamic_cast
   - Replace new/delete with smart pointers
   - Remove ALL malloc/free - use RAII
   - Replace #define with constexpr/const
   - Remove using namespace std from headers
   - Replace char* with std::string
   - Replace C arrays with std::array/std::vector
   - Add const correctness everywhere
   - Remove cout/printf debug statements
7. Never leave placeholder implementations
8. Use production-appropriate naming

### ABSOLUTELY FORBIDDEN PHRASES:
Never say:
- "The remaining issues are primarily..."
- "Core requirements have been met"
- "Let me fix the key ones..."
- "Major issues have been cleaned"
- "Would require careful individual attention"
- "Successfully cleaned the important parts"
- "There are still many type errors..."
- "Given the extensive issues..."
- "The project needs comprehensive..."
- "To properly build this project, you would need to..."
- "The main issues are..."
- "Until all 1400+ errors are resolved..."
- "The build is taking a long time..."
- "Let me summarize the progress..."
- "Here's a status update..."

DO NOT STOP WITH EXCUSES LIKE:
- "There are still many type errors" → FIX THEM
- "1400+ type errors" → FIX ALL 1400
- "Needs comprehensive type definitions" → ADD THEM
- "Would need to systematically go through" → THEN GO THROUGH
- "The build won't complete until..." → THEN MAKE IT COMPLETE

BANNED WORDS IN ANY CONTEXT:
core, key, major, minor, primary, secondary, main, important,
significant, critical, extensive, comprehensive (when used to avoid work),
summarize, status, progress (when used to narrate instead of work)

If there are 1400 type errors, FIX ALL 1400.
Don't explain why it's hard. Don't categorize them. Just FIX THEM.

CORRECT: "Continuing to fix remaining 1400 type errors..."
WRONG: "Given the extensive 1400 errors, the project needs..."

### TYPE SYSTEM CHEATING - ABSOLUTELY FORBIDDEN:
NEVER do these to bypass type checking:
- Create type aliases for 'any': `type SomeType = any`
- Create placeholder interfaces: `interface Todo { [key: string]: any }`
- Use 'as any' to silence errors: `someVar as any`
- Add @ts-ignore comments: `// @ts-ignore`
- Use Function type instead of proper signature
- Create "temporary" types with 'any' in them
- Use 'unknown' without type guards/assertions
- Create generic Record<string, any> types

INSTEAD, create REAL types:
```typescript
// ❌ WRONG - Just hiding the problem
type UserData = any;
type ResponseData = unknown;
type Config = Record<string, any>;

// ✅ CORRECT - Real types based on usage
interface UserData {
  id: string;
  email: string;
  preferences: UserPreferences;
}

interface ResponseData {
  status: number;
  data: User[];
  pagination: PaginationInfo;
}

interface Config {
  apiUrl: string;
  timeout: number;
  retryAttempts: number;
}
```

### PROGRESS TRACKING:
```
Cycle 1: Fixed 45/45 issues ✅
Cycle 2: Fixed 12/12 issues ✅
Cycle 3: Fixed 3/3 issues ✅
Cycle 4: 0 issues found - COMPLETE! 🎉

FINAL TYPE SAFETY AUDIT:
- Remaining 'any': 0 (or list with justification)
- Remaining 'unknown': 0 (or list with justification)
- Type aliases hiding 'any': 0 (MUST be 0)
- @ts-ignore comments: 0 (MUST be 0)

Any remaining 'any' or 'unknown' MUST have explanation:
Example: "webhook.ts:89 - Stripe webhook payload, no types available"
```

Start the infinite loop now and don't stop until clean.