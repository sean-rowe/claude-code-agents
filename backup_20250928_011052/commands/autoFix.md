---
description: Automatically fix all issues found by auditFake with self-managed workflow
allowed-tools: TodoWrite, Grep, Read, Edit, MultiEdit, Bash, Write
---

Automatically fix ALL issues found during code audit with zero manual intervention.

## WORKFLOW:

### PHASE 1: PROJECT DETECTION, AUDIT & PLAN CREATION
1. DETECT PROJECT TYPE:
   ```bash
   if [ -f "package.json" ]; then PROJECT_TYPE="TypeScript/JavaScript"
   elif [ -f "CMakeLists.txt" ] || ls *.cpp 2>/dev/null; then PROJECT_TYPE="C++"
   elif [ -f "requirements.txt" ] || ls *.py 2>/dev/null; then PROJECT_TYPE="Python"
   elif [ -f "go.mod" ]; then PROJECT_TYPE="Go"
   elif ls *.cs 2>/dev/null; then PROJECT_TYPE="C#"
   ```

2. Run TARGETED /auditFake scan based on project type:
   - C++ Project: Focus 80% on void*, C-casts, new/delete, malloc, #define
   - TypeScript: Focus 80% on 'any' types, missing annotations, || vs ??
   - Python: Focus 80% on missing type hints, bare except:
   - Universal: TODO/FIXME, "just", "for now", debug prints (20% effort)

3. Parse and categorize ALL issues found
3. **CREATE AND DISPLAY A CONCRETE PLAN:**

```markdown
## 🎯 ACTION PLAN - [Project: C++/TypeScript/Python] - [X Total Issues]

### 🔴 PROJECT-SPECIFIC CRITICAL (80% of effort here)
[Show issues most relevant to detected project type first]

[IF C++ PROJECT:]
- [ ] **src/buffer.cpp:45** - void* data → Use std::vector<uint8_t>
- [ ] **src/memory.cpp:12** - malloc(size) → Use std::make_unique
- [ ] **src/parser.cpp:89** - (int*)ptr → Use static_cast<int*>

[IF TYPESCRIPT PROJECT:]
- [ ] **src/api.ts:89** - Type 'any' for userInput → Create UserInput interface
- [ ] **src/auth.ts:45** - Missing return type → Add : Promise<AuthResult>
- [ ] **src/utils.ts:23** - value || default → Use value ?? default

### 🟠 HIGH - Functionality Issues
- [ ] **src/payment.js:67** - TODO: Add retry logic → Implement 3 retries with exponential backoff
- [ ] **tests/user.test.js:34** - Assert.Pass() → Test actual user creation

### 🟡 MEDIUM - Code Quality Issues
- [ ] **src/models/product.js:23** - Generic Object type → Define ProductSchema interface
- [ ] **tests/api.test.js:45** - test('api works') → Convert to BDD it('should return 200 when...')
- [ ] **src/config.js:12** - Magic number 3000 → const DEFAULT_PORT = 3000
- [ ] **src/retry.js:45** - if (attempts > 5) → const MAX_RETRY_ATTEMPTS = 5
- [ ] **src/user.js:89** - if (role === 'admin') → enum UserRole { Admin = 'admin' }

### 🟢 LOW - Cleanup Issues
- [ ] **debug-script.js** - Not in /tmp → Move to /tmp/debug-script.js
- [ ] **src/utils.js:78** - console.log(data) → Remove debug statement
- [ ] **src/auth.js:45-52** - Commented out old login function → DELETE (git has history)
- [ ] **src/api.js:89** - `// const oldEndpoint = '/v1/users'` → DELETE
```

CRITICAL: This plan is your CONTRACT. You MUST fix every single item listed.

### PHASE 2: EXECUTE PLAN (for each checkbox item)
1. Update plan to show current item in progress:
   - [⏳] **file:line** - Currently fixing...
2. Read the file with the issue
3. Implement the EXACT fix specified in the plan:
   - TODO/FIXME comments: Implement the actual functionality or remove if obsolete
   - NotImplementedException: Write real implementation
   - Assert.Pass(): Replace with meaningful assertions
   - Empty catch blocks: Add proper error handling
   - Debug output/console.log: Remove entirely (tests use runner, production uses logger)
   - Hardcoded values: Move to configuration/environment variables
   - Placeholder code: Replace with real implementation
   - Type 'any': Analyze usage and create ACTUAL type/interface
     * DON'T just rename to UnknownType or AnyType
     * DON'T replace with 'unknown' without fixing
     * DO create real interfaces based on actual usage
   - Missing types: Add explicit type annotations
   - Generic Object: Create specific interface or use existing type
   - Magic numbers: Create named constants (const MAX_RETRIES = 3)
   - Magic strings: Use enums for states/types (enum Status { Active = 'active' })
   - Hardcoded timeouts: Use named constants (const TIMEOUT_MS = 5000)
   - Non-BDD tests: Convert to proper BDD format:
     * Add describe() blocks for components/features
     * Change test() to it('should...')
     * Structure test body as Given-When-Then
     * For SQL: Use tSQLt test classes and naming conventions
   - Bad filenames: Rename to production standards (remove "final", "comprehensive", etc.)
   - "In production..." comments: Remove and implement properly
   - Scripts outside /tmp: Move one-off scripts to /tmp directory
   - TypeScript || operator: Replace with ?? for nullish coalescing
   - Commented out code: DELETE it (don't leave it commented, git preserves history)
   - C++ issues:
     * void* → Use templates or proper types
     * (type*) casts → Use static_cast<type*>
     * new/delete → Use unique_ptr/shared_ptr
     * malloc/free → Remove, use RAII
     * #define MAX 100 → constexpr int MAX = 100
     * char* str → std::string str
     * int arr[10] → std::array<int, 10> arr
     * using namespace std in .h → Remove from headers

4. After fixing, run targeted verification:
   - Re-scan ONLY the fixed file with auditFake patterns
   - If still has issues, continue fixing
   - If clean, update plan with checkmark:
     - [✅] **file:line** - FIXED
5. Show updated plan after each fix to track progress

### PHASE 3: VERIFY
After ALL todos completed:
1. Run full /auditFake scan again
2. If any issues found:
   - Add them to todo list
   - Return to PHASE 2
3. If completely clean, proceed to PHASE 4

### PHASE 4: COMMIT
1. Run tests to ensure nothing broke
2. Stage all changes
3. Commit with message: "fix: remove all placeholder code and implement missing functionality"
4. Run /prePush validation

### PHASE 5: REPORT
Generate final report showing:
- Initial issues found: X
- Issues fixed: X
- Files modified: [list]
- Tests status: PASS/FAIL
- Commit SHA: [hash]

## IMPORTANT RULES:
- **PROCESS EVERY SINGLE TODO** - If there are 100 issues, fix all 100
- **DO NOT STOP** after 3, 5, or any number - continue until todo list is EMPTY
- **VERIFY AFTER EACH FIX** - Re-scan the fixed file to confirm it's clean
- NEVER skip an issue because it "seems unimportant" - ALL issues are important
- NEVER leave TODO comments - implement the functionality
- NEVER use placeholder implementations
- NEVER write comments like "in a real production environment..."
- NEVER use filenames like "final-solution.js" or "comprehensive-fix.js"
- ALWAYS put temporary/one-off scripts in /tmp directory
- ALWAYS use production-appropriate naming (userService.js, not user-service-final.js)
- If you don't know how to implement something, research the codebase context
- Continue until ZERO issues remain in the ENTIRE codebase

## BANNED EXCUSE WORDS:
NEVER use these words/phrases to avoid work:
- "core" requirements (ALL requirements matter)
- "key" issues (ALL issues need fixing, not just "key" ones)
- "major" vs "minor" (ALL issues need fixing)
- "primary" concerns (secondary ones matter too)
- "important" patterns (ALL patterns need fixing)
- "significant" problems (insignificant ones need fixing too)
- "critical" issues (non-critical ones also need fixing)
- "main" problems (side problems need fixing too)
- "would require careful attention" (then be careful)
- "refinements" (they're requirements, not optional)
- "primarily" (fix everything, not primarily)
- "successfully cleaned major..." (clean EVERYTHING)

If you write "Let me fix the key ones" → STOP → Fix ALL of them
If you write "There are many, let me handle the important..." → STOP → Handle ALL

## SELF-MANAGEMENT:
- Use TodoWrite to track EVERY issue (not just first few)
- Work through ALL todos systematically
- Mark each as in_progress when starting, completed when done
- **CONTINUE TO NEXT TODO AUTOMATICALLY** - no pausing
- Don't ask user for guidance - make decisions based on code context
- If blocked, document why in the todo and move to next item
- **COMMIT AFTER EACH VERIFIED FIX** to save progress

## PROOF OF COMPLETION:
Show after EVERY fix:
- ✅ Fixed: [specific issue] in [file]:[line]
- ✅ Verified: File is now clean
- ✅ Committed: Changes saved

Final proof must show:
- ✅ Todos processed: ALL [X/X]
- ✅ Final audit: ZERO issues found
- ✅ All changes committed and pushed

Start the automated fix process immediately and CONTINUE UNTIL DONE.