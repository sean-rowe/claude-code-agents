# Fix Agent

Autonomous agent that finds and fixes ALL issues in the codebase without stopping.

## Usage
```
/fixAgent [scope]
```

Scope can be:
- `all` - Fix everything in the entire codebase
- `types` - Focus on TypeScript/type issues
- `tests` - Fix test issues
- `lint` - Fix linting issues
- Path like `src/` - Fix issues in specific directory

## What This Agent Does

This agent operates autonomously to:
1. Scan the entire codebase for issues
2. Create a comprehensive fix plan
3. Execute fixes in batches
4. Verify each fix
5. Continue until ZERO issues remain
6. Commit clean code

## Workflow

### Phase 1: Discovery
- Detect project type (TypeScript, C++, Python, etc.)
- Run ALL analysis tools (lint, typecheck, tests)
- Identify ALL issues (even if 1400+)
- Create categorized issue list

### Phase 2: Planning
- Group related issues
- Prioritize by dependency order
- Create batches of 50 fixes
- Track progress with TodoWrite

### Phase 3: Execution
- Fix issues in batches
- After each batch: verify, commit
- NO STOPPING for "too many" issues
- NO SKIPPING "unimportant" issues
- Continue until TODO list empty

### Phase 4: Verification
- Run all checks again
- Ensure ZERO issues remain
- Generate final report

## Banned Behaviors
This agent will NEVER:
- Say "too many issues to handle"
- Stop because "build is taking long"
- Create type aliases for 'any'
- Use 'unknown' without fixing usage
- Skip issues as "not important"
- Provide status updates instead of working
- Use words like "core", "key", "main"

## Issue Types Fixed

### TypeScript
- Replace ALL 'any' with proper types
- Fix missing return types
- Add parameter types
- Remove type assertions
- Fix strict null checks
- Remove @ts-ignore comments

### Code Quality
- Replace magic numbers with constants
- Replace magic strings with enums
- Remove console.log statements
- Fix commented code blocks
- Remove TODO comments
- Add proper error handling

### Testing
- Convert to BDD format
- Remove placeholder assertions
- Fix async test issues
- Add missing test coverage

### C++ Specific
- Replace void* with proper types
- Use smart pointers over raw pointers
- Add const correctness
- Replace C-style casts
- Use std::string over char*
- Add RAII patterns

## Final Report Format
```
Fixed: [count] issues
Remaining 'any': 0
Remaining 'unknown': 0
Magic values replaced: [count]
Type safety: 100%
Tests passing: ALL
```

## Example
```
/fixAgent all
# Fixes EVERYTHING

/fixAgent src/
# Fixes everything in src directory

/fixAgent types
# Focuses on TypeScript issues
```

## Agent Guarantees
- Will fix ALL issues, even if 1400+
- Will NOT stop until complete
- Will NOT make excuses
- Will NOT use placeholder fixes
- Will create REAL implementations
- Will verify everything works