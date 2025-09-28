---
description: Scan entire codebase for placeholder/fake code
argument-hint: [scope?]
allowed-tools: Grep, Read, Edit, MultiEdit
---

Scan the codebase for placeholder text, fake implementations, and incomplete code.

FIRST: Detect project type:
- Check for package.json → TypeScript/JavaScript (focus 80% on TS/JS issues)
- Check for *.cpp, CMakeLists.txt → C++ (focus 80% on C++ issues)
- Check for *.py, requirements.txt → Python (focus 80% on Python issues)
- Check for *.cs, *.csproj → C# (focus 80% on C# issues)
- Check for go.mod → Go (focus 80% on Go issues)

THEN: Prioritize detection patterns based on project type:
- TODO, FIXME, HACK, XXX comments
- "placeholder", "fake", "dummy", "mock" (except mocking frameworks)
- "just", "for now" (indicates temporary/incomplete implementation)
- "hardcoded", "magic number"
- Assert.Pass(), Assert.True(true), Assert.False(false)
- throw new NotImplementedException
- Console.WriteLine/console.log anywhere (including tests - use test runner)
- Empty catch blocks
- Hardcoded credentials or connection strings
- Type 'any' in TypeScript/JavaScript
- Generic 'Object' type when specific type should be used
- Missing type annotations on parameters/returns
- var/dynamic when explicit types should be used
- Magic numbers (hardcoded numeric values without names)
- Magic strings (hardcoded string literals for states/types)
- Values that should be enums or named constants
- Non-BDD test patterns:
  - test('function name') instead of it('should...')
  - Missing describe() blocks
  - Tests without Given-When-Then structure
  - Simple assertions instead of behavior verification
- Anti-patterns in code/comments:
  - Comments like "in a real production..." or "this would normally..."
  - Filenames with "final", "comprehensive", "complete", etc.
  - Scripts/temp files not in /tmp directory
  - Non-production naming conventions
- TypeScript issues:
  - Using || instead of ?? for default values
  - Missing nullish coalescing where appropriate
  - Type 'any' or 'unknown' without proper types
  - Fake type aliases like UnknownType, AnyType, GenericData
- Commented out code:
  - Old functions left commented
  - Previous implementations kept as comments
  - Any executable code in comments (not documentation)
- C++ specific issues:
  - void* pointers instead of proper types
  - C-style casts like (int*) instead of static_cast
  - Raw pointers with new/delete instead of smart pointers
  - malloc/free in C++ code
  - #define constants instead of constexpr
  - using namespace std in header files
  - char* instead of std::string
  - C arrays instead of std::array/std::vector
  - Missing const correctness
  - cout/printf debug statements
  - Magic numbers instead of named constants
  - Hardcoded values instead of enums

For each issue found:
1. Report the file and line number
2. Show the problematic code
3. Categorize the issue (placeholder, fake test, security risk, etc.)
4. Provide a specific fix

Generate a remediation plan prioritized by impact.

Scope: $ARGUMENTS (if not specified, scan entire codebase)

IMPORTANT: Be thorough and find ALL instances. No placeholder code is acceptable.