# Claude Code Action Commands

These slash commands are available directly in Claude Code. Type them in any conversation to execute.

## 🚨 Recovery Commands (Fix Existing Projects)

### `/auditFake`
I will scan your entire codebase for fake/placeholder code and report all findings.

### `/fixAll`
I will automatically fix all detected issues, replacing placeholders with real implementations.

### `/proveNotLying`
I will demonstrate that the code actually works by:
- Running the application with real data
- Showing actual terminal output (not mocked)
- Executing real database queries
- Displaying network traffic
- Mutating code to prove tests catch changes

### `/recovery`
I will perform complete project recovery:
- Fix all dependencies
- Remove all fake code
- Optimize performance
- Validate all tests
- Ensure production readiness

## 🧪 TDD Commands

### `/testFirst [Component] [Type]`
I will create failing tests first (TDD Red phase).
Example: `/testFirst OrderService unit`

### `/implement [StoryID] [Component]`
I will implement code to make tests pass (TDD Green phase).
Example: `/implement PROJ-123 OrderService`

### `/validateImpl [Component]`
I will validate the implementation has no fake code.
Example: `/validateImpl OrderService`

### `/commitTdd [Phase]`
I will create proper TDD commits.
Examples:
- `/commitTdd red` - Commit failing tests
- `/commitTdd green` - Commit passing implementation
- `/commitTdd refactor` - Commit refactored code

## 📋 Story & Requirements

### `/story [ID] [Title]`
I will create a complete user story with acceptance criteria.
Example: `/story PROJ-123 "User Login"`

### `/gherkin [StoryID] [Feature]`
I will generate comprehensive BDD scenarios.
Example: `/gherkin PROJ-123 user-login`

### `/requirements [StoryID]`
I will extract and validate all requirements.
Example: `/requirements PROJ-123`

## 🛡️ Verification Commands

### `/deepVerify`
I will perform deep verification of all code, including:
- Running mutation tests
- Checking test coverage
- Validating implementations
- Security scanning

### `/forceTruth`
I will enter strict mode where I CANNOT write any placeholder code.

### `/proveAuthenticity`
I will prove the code is production-ready by demonstrating all features work with real data.

## 🚀 Batch Commands

### `/initProject [Name] [Type]`
I will initialize a complete project structure.
Examples:
- `/initProject OrderAPI dotnet-api`
- `/initProject UserService node-api`

### `/storyComplete [StoryID]`
I will run the complete story workflow:
test-first → implement → validate → audit → commit

### `/auditQuality`
I will run comprehensive quality checks:
- SOLID principles
- Complexity analysis
- Coverage report
- Security scan
- Dependency audit

## 💪 Power Commands

### `/fixFakeImpl`
I will fix all fake implementations by:
- Showing end-to-end execution
- Breaking code to prove tests work
- Verifying real data persistence
- Demonstrating actual network calls

### `/fixTestLies`
I will fix fake tests by:
- Running mutation testing
- Removing all mocks
- Creating real integration tests
- Proving tests actually validate behavior

## 🎯 Quick Reference

**Most Important Commands:**
- `/auditFake` - Find all fake code
- `/proveNotLying` - Prove it's real
- `/recovery` - Fix everything

**Starting New Work:**
```
/forceTruth
/story PROJ-123 "Feature"
/testFirst Component unit
/implement PROJ-123 Component
```

**Fixing Problems:**
```
/auditFake
/fixAll
/proveNotLying
```

**Emergency Recovery:**
```
/recovery
/forceTruth
/proveAuthenticity
```

## How I Respond to These Commands

When you use any slash command, I will:

1. **Acknowledge the command** - Confirm what action I'm taking
2. **Execute thoroughly** - Run all necessary checks and validations
3. **Show real output** - Display actual results, not simulated
4. **Report findings** - Provide detailed results
5. **Take corrective action** - Fix issues found
6. **Verify success** - Prove the fixes work

## Anti-Fake Patterns I Check

- `TODO`, `FIXME`, `HACK`, `XXX` comments
- `NotImplementedException`
- `return true; // TODO`
- `Assert.Pass()`
- Empty catch blocks
- Hardcoded passwords/secrets
- Debug print statements
- Stub implementations
- Mock-only tests
- Placeholder text

## Enforcement Rules

When `/forceTruth` is active, I CANNOT:
- Write TODO comments
- Use NotImplementedException
- Create empty methods
- Write fake tests
- Use placeholder values
- Skip error handling
- Mock without real implementation
- Use hardcoded secrets

I MUST:
- Write complete implementations
- Create real tests that fail first
- Handle all error cases
- Use environment variables for config
- Validate all inputs
- Implement full business logic
- Show actual execution results