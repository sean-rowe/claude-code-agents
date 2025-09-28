---
description: Fix all code issues, verify, commit, and push automatically
allowed-tools: TodoWrite, Task, Grep, Read, Edit, MultiEdit, Bash, Write
---

Execute complete automated fix → verify → commit → push workflow.

## AUTONOMOUS WORKFLOW:

### 1. PROJECT TYPE DETECTION & INITIAL AUDIT

FIRST: Detect project type by checking for:
- package.json → TypeScript/JavaScript project (focus on TS/JS issues)
- *.cpp, *.h, CMakeLists.txt → C++ project (focus on C++ issues)
- *.cs, *.csproj → C# project (focus on C# issues)
- requirements.txt, *.py → Python project (focus on Python issues)
- go.mod → Go project (focus on Go issues)
- Cargo.toml → Rust project (focus on Rust issues)

THEN: Run targeted comprehensive scan based on project type:

**UNIVERSAL ISSUES (check in all projects):**
- TODO, FIXME, HACK, XXX comments
- Empty catch blocks
- Hardcoded credentials/secrets
- Placeholder implementations
- Commented out code blocks
- Debug print statements (console.log, cout, print, etc.)

**IF TypeScript/JavaScript Project (PRIORITIZE THESE):**
- Type 'any' in TypeScript (CRITICAL for TS projects)
- Using || instead of ?? for nullish coalescing
- Untyped function parameters/returns
- Missing type annotations
- console.log statements

**IF C++ Project (PRIORITIZE THESE):**
- void* pointers (CRITICAL for C++)
- C-style casts instead of static_cast/dynamic_cast
- Raw pointers instead of smart pointers
- new/delete instead of RAII
- malloc/free in C++ code
- #define macros instead of constexpr/const
- using namespace std in headers
- Missing const correctness
- char* instead of std::string
- C arrays instead of std::array/std::vector
- cout/printf debug statements

**IF C# Project (PRIORITIZE THESE):**
- Type 'Object' when specific type needed
- var when explicit type should be used
- NotImplementedException
- Console.WriteLine debug statements

**IF Python Project (PRIORITIZE THESE):**
- Missing type hints (Python 3.5+)
- print() debug statements
- Bare except: clauses
- Mutable default arguments

The audit should spend 80% effort on language-specific issues for the detected project type.

### 2. PLAN GENERATION (MANDATORY - DO NOT SKIP)
Generate and DISPLAY a concrete action plan with checkboxes BASED ON PROJECT TYPE:

```markdown
## 📋 FIX PLAN - [Project Type: C++/TypeScript/Python/etc.] - [Total Issues: X]

### Project-Specific Critical Issues (80% of focus)
[FOR C++ PROJECT:]
- [ ] **src/memory.cpp:45** - void* buffer → Use std::vector<uint8_t>
- [ ] **src/parser.cpp:23** - (int*)ptr cast → Use static_cast<int*>
- [ ] **src/main.cpp:78** - new int[size] → Use std::unique_ptr<int[]>
- [ ] **include/config.h:12** - using namespace std → Remove from header

[FOR TYPESCRIPT PROJECT:]
- [ ] **src/auth/login.ts:45** - Type 'any' on userData → Define UserData interface
- [ ] **src/api.ts:89** - Missing return type → Add explicit type
- [ ] **src/utils.ts:34** - user.name || 'default' → Use user.name ?? 'default'

[FOR PYTHON PROJECT:]
- [ ] **auth/login.py:45** - Missing type hints → Add def login(user: User) -> bool
- [ ] **utils.py:23** - Bare except: → Use except SpecificException:

### Universal Issues (20% of focus)
- [ ] **src/service.cpp:67** - TODO: implement retry → Add retry logic
- [ ] **tests/unit.test.js:12** - Commented old test → Delete commented code

### High Priority Issues
- [ ] **src/services/payment.js:89** - TODO: implement retry logic → Add exponential backoff retry
- [ ] **src/utils/validator.ts:34** - Missing return type → Add ValidationResult type
- [ ] **config/db.js:15** - Hardcoded connection string → Move to .env file

### Medium Priority Issues
- [ ] **tests/integration/api.test.js:45** - Non-BDD format → Convert to describe/it structure
- [ ] **src/models/user.js:78** - Generic Object type → Create UserProfile interface
- [ ] **debug-script.js** - Script not in /tmp → Move to /tmp/debug-script.js

### Low Priority Issues
- [ ] **src/helpers/format.js:23** - Console.log for debug → Remove debug statement
- [ ] **docs/setup-final.md** - Bad filename → Rename to setup.md
```

IMPORTANT:
- List EVERY issue found with EXACT file:line location
- Show WHAT will be fixed and HOW
- Group by severity
- Use checkboxes for progress tracking
- This plan is your contract - you MUST fix everything listed

### 3. SYSTEMATIC FIXING
For EVERY checkbox item in the plan (DO NOT STOP until all checked):
```
a. Update the plan - mark current item as in progress:
   - [⏳] **file:line** - Working on this...

b. Read the file
c. Understand context (check imports, surrounding code)
d. Implement the EXACT fix described in the plan
e. Save changes
f. VERIFY THE FIX: Run audit on that specific file
   - If still has issues, continue fixing that file
   - Only move on when file is 100% clean
g. Update the plan - mark as completed:
   - [✅] **file:line** - FIXED

h. Show updated plan with progress
i. CONTINUE to next unchecked item (don't stop, don't ask, just continue)
```

IMPORTANT:
- Work through the plan systematically
- Update checkboxes to show progress
- Process ALL items. If plan has 50 items, fix all 50.
- Never stop after 3 or any arbitrary number.

### 4. VERIFICATION LOOP
```
while (issues_exist):
    run_audit()
    if (issues_found):
        add_to_todos()
        fix_all_todos()
    else:
        break
```

### 5. TEST VALIDATION & BDD ENFORCEMENT
- Run test suite
- If tests fail:
  - Fix the implementation (not the tests!)
  - Re-run tests
- Verify all tests follow BDD format:
  - describe() blocks for feature/component
  - it('should...') for behavior specification
  - Given-When-Then structure in test body
  - NO simple unit tests like test('function returns X')
- If non-BDD tests found, convert to BDD format
- Continue until all tests pass AND follow BDD

### 6. CONTINUOUS COMMIT & PUSH
After EACH fix is verified:
```bash
# Stage the change
git add <fixed-file>

# Commit with specific message
git commit -m "fix: resolve issue in <filename>

- Fixed: <specific issue>
- Verified: No issues remain in file"

# Push immediately (don't wait)
git push origin $(git branch --show-current)
```

After ALL fixes complete:
```bash
# Final verification commit
git commit -m "fix: complete removal of all placeholder code

- Total issues fixed: X
- Files cleaned: Y
- All tests passing
- Zero issues remain"

git push origin $(git branch --show-current)
```

### 7. FINAL REPORT
```
============ AUTO-FIX COMPLETE ============
Issues Found:        [X]
Issues Fixed:        [X]
Files Modified:      [count]
Tests Status:        PASSING
Commit SHA:          [hash]
Branch Pushed:       [branch-name]

Verification:        ✅ NO ISSUES REMAINING

Type Safety Report:
- Total 'any' remaining: [count]
- Total 'unknown' remaining: [count]
- Justifications (if any):
  [List EACH use with file:line and SPECIFIC reason]
  Example: "api.ts:45 - External webhook payload from Stripe with no TypeScript definitions"

If ANY 'any' or 'unknown' types remain, they MUST be listed here with justification.
==========================================
```

## STRICT RULES FOR CONSOLE.LOG:
- NO console.log in test files - test runner handles output
- NO console.log in production code - use proper logging library
- NO console.log in any committed code
- "Development scripts" are one-off scripts and belong in /tmp
- If you need logging, use a logger (winston, pino, bunyan, etc.)
- In tests, use test runner output (describe/it messages)

## TYPESCRIPT STRICT RULES:
- ALWAYS use ?? (nullish coalescing) instead of || for default values
- || checks for all falsy values (0, '', false, null, undefined)
- ?? only checks for null/undefined (preserves 0, '', false as valid)
- Example: `const port = config.port ?? 3000` NOT `config.port || 3000`
- NO CHEATING on type fixes:
  ❌ DON'T create generic types like `type UnknownType = any`
  ❌ DON'T replace `any` with `unknown` without fixing usage
  ❌ DON'T create `AnyType`, `GenericData`, `UnknownObject` aliases
  ✅ DO analyze the actual data and create proper interfaces
  ✅ DO use real types like `User`, `Product`, `ApiResponse<T>`

Example:
```typescript
// ❌ CHEATING - just hiding the problem
type UnknownType = any;
function process(data: UnknownType) { }

// ✅ CORRECT - actual type based on usage
interface ProcessData {
  id: number;
  items: Item[];
  metadata: Record<string, string>;
}
function process(data: ProcessData) { }
```

## C++ STRICT RULES:
- NO void* pointers - use templates or proper types
- NO C-style casts - use static_cast, dynamic_cast, reinterpret_cast, const_cast
- NO raw pointers for ownership - use unique_ptr/shared_ptr
- NO manual new/delete - use smart pointers and RAII
- NO malloc/free - this is C++, not C
- NO #define for constants - use constexpr or const
- NO using namespace std in headers - only in .cpp files if needed
- ALWAYS use const correctness - const methods, const& parameters
- NO char* for strings - use std::string or std::string_view
- NO C arrays - use std::array for fixed size, std::vector for dynamic

Example fixes:
```cpp
// ❌ WRONG
void* data = getData();
int* ptr = (int*)data;
char* name = new char[100];
int arr[100];
#define MAX_SIZE 100

// ✅ CORRECT
auto data = getData<int>();
int* ptr = static_cast<int*>(data);
std::string name;
std::array<int, 100> arr;
constexpr int MAX_SIZE = 100;
```

## COMMENTED CODE RULES:
- NO commented out code blocks - either USE it or DELETE it
- Version control (git) preserves history, no need to keep old code commented
- Commented documentation is fine, commented CODE is not
- Examples of what to remove:
  ```javascript
  // const oldFunction = () => { ... }  ← DELETE THIS
  // if (oldCondition) { doSomething() } ← DELETE THIS
  /*
  function deprecatedMethod() {         ← DELETE THIS ENTIRE BLOCK
    return oldLogic();
  }
  */
  ```
- If code might be needed: DELETE IT (git has it if needed later)

## DECISION RULES:
- If TODO says "implement X", research codebase and implement X
- If function returns null/undefined, implement proper return value
- If error is ignored, add logging and proper handling
- If value is hardcoded, check for .env file or config
- If test has no assertion, analyze what it should test
- If type is 'any', analyze usage and define proper interface/type
- If parameter lacks type, infer from usage and add annotation
- If using Object/dynamic, create specific type/interface
- NEVER leave 'any' types - always use proper typing
- ALWAYS write BDD tests - describe/it/should format
- Convert unit tests to BDD: "test X returns Y" → "it should return Y when given X"
- Use Given-When-Then structure in test implementation
- For SQL: Always use tSQLt with proper test class structure
- Put one-off/temporary scripts in /tmp directory ONLY
- Use production-appropriate filenames (userService.js, not comprehensive-user-service-final.js)
- NEVER use comments like "in a real production..." or "this would normally..."
- No conversation artifacts in code (no "final", "comprehensive", "complete" in filenames)

## NO HUMAN INTERVENTION - CRITICAL RULES:
- **NEVER STOP** until all issues are fixed (not 3, not 5, ALL)
- **VERIFY EACH FIX** before moving to next issue
- **COMMIT & PUSH** after each verified fix
- **CONTINUE AUTOMATICALLY** - no pauses, no confirmations
- Make decisions based on code context
- Don't ask for clarification
- Implement best practices
- Complete the ENTIRE workflow
- Only stop when audit returns ZERO issues

## ANTI-STOPPING MEASURES:
If you feel like stopping:
1. CHECK: Are all checkboxes marked [✅]? If NO → CONTINUE
2. CHECK: Does audit still find issues? If YES → CONTINUE
3. You are NOT done until: ALL todos complete AND audit returns ZERO issues
4. After fixing 3 items, explicitly state: "Continuing with remaining X items..."
5. Use TodoWrite to track progress and force continuation

## BANNED TYPE CHEATING:
When fixing type 'any', DON'T:
- Create `type UnknownType = any` (this is just renaming the problem)
- Create `type GenericData = unknown` (still not a real type)
- Create `interface AnyObject { [key: string]: any }` (still using any)
- Replace with 'unknown' and call it fixed (must have real type)
- Create `type DataType = any` (just hiding the problem)
- Create `type Todo = any` (not a real type)
- Create `type FixLater = unknown` (not fixing, just deferring)
- Use `as any` casts to silence errors
- Use `// @ts-ignore` to bypass type checking
- Create generic catch-all types like `Record<string, any>`
- Use `Object` type in TypeScript (use specific interface)
- Create placeholder types with 'any' anywhere in them
- Create "temporary" type aliases that wrap 'any' or 'unknown'
- Use `Function` type (specify actual function signature)

Instead, ANALYZE THE USAGE and create the ACTUAL type:
- If code uses `data.userId`, type needs `userId: string | number`
- If code uses `response.items.map()`, type needs `items: Array<Something>`
- Look at the actual properties and methods used!
- Check function calls to understand parameter types
- Check return statements to understand return types
- Look at test files to understand expected shapes
- Read API documentation for external services
- Check database schemas for data structures

ONLY ALLOWED USE OF 'any' or 'unknown':
- EXTREMELY RARE cases where type truly cannot be determined
- Must be documented in final summary with SPECIFIC justification
- Example justification required: "Line 45: Used 'unknown' for third-party library X version Y that has no @types package and uses dynamic property injection"
- NOT acceptable: "Used 'any' because it was complex" or "Used 'unknown' to fix quickly" or "Used 'any' for flexibility"

## BANNED EXCUSES - DO NOT USE:
- "The remaining issues are minor..." - NO, fix them ALL
- "These would require careful attention..." - Then PAY careful attention
- "Core requirements met..." - ALL requirements must be met, not just "core"
- "Primary issues resolved..." - Secondary issues need fixing too
- "Type refinements can wait..." - NO they can't
- "This might break functionality..." - Then fix it properly
- "Successfully cleaned major issues..." - Minor issues need cleaning too
- "Let me fix the key ones..." - NO, fix ALL of them
- "There are still many type errors..." - FIX THEM ALL
- "Given the extensive issues..." - Extensive means MORE work, not stop
- "The project needs comprehensive type definitions..." - THEN ADD THEM
- "1400+ type errors..." - YES, FIX ALL 1400
- "To properly build this project, you would need to..." - THEN DO IT
- "The build won't complete until..." - THEN COMPLETE IT
- "The build is taking a long time..." - DON'T NARRATE, JUST WAIT
- "Let me summarize the progress..." - DON'T SUMMARIZE, KEEP WORKING

SPECIFIC BANNED EXCUSE about large numbers:
- "There are 1400+ type errors" is NOT a reason to stop
- It's a todo list of 1400 items to fix
- Break it down: Fix 50, commit, fix 50 more, repeat 28 times
- DON'T explain the problem, SOLVE the problem

BANNED WORDS: core, key, major, minor, primary, main, important, significant, critical, extensive, comprehensive, summarize, progress
If there are 1400 issues, fix 1400. Not "too many to handle". ALL 1400.
DON'T provide status updates or narrate delays. Just work.

EVERY issue in the plan must be fixed. NO EXCEPTIONS.
If you can't fix something, explain the SPECIFIC technical blocker, not vague concerns.

## CONTINUOUS WORKFLOW:
1. Find issue → 2. Fix it → 3. Verify fix worked → 4. Commit & Push → 5. Next issue
Repeat until audit is completely clean.

## RESTART PROTOCOL:
If interrupted, the next run should:
1. Re-scan for remaining issues
2. Create new plan for unfixed items
3. Continue where left off
4. Complete ALL remaining work

Begin autonomous fix-all process now and DO NOT STOP until done.