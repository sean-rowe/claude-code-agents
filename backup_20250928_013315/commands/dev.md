# Dev Agent

Simple entry point for autonomous development. Just type `/dev` and watch it work.

## Usage
```
/dev
```

That's it. No parameters needed.

## What This Agent Does

`/dev` is your single command that:
1. Figures out what needs to be done
2. Does it with the right agents
3. Commits clean, tested code
4. Moves to the next task
5. Keeps going until done

## Automatic Detection

### Detects Your Project Type
- Node.js/TypeScript → Uses npm, jest, tsc
- Python → Uses pip, pytest, mypy
- C++ → Uses make, cmake, gtest
- SQL → Uses tSQLt procedures
- Mixed → Handles multiple languages

### Finds Work Automatically
```
Priority Order:
1. 🔴 Broken builds/tests (must fix first)
2. 🟡 Type/lint errors (fix before features)
3. 🟢 User stories (new features)
4. 🔵 TODO comments (cleanup tasks)
5. ⚪ Documentation (if missing)
```

## Workflow

### Step 1: Initial Analysis
```
/dev
Analyzing codebase...
✓ TypeScript project detected
✓ Jest test framework found
✓ 2 failing tests
✓ 34 type errors
✓ Story PROJ-123 found
✓ 5 TODO comments

Creating work plan...
```

### Step 2: Auto-Dispatch Agents
```
Dispatching agents:
1. fixAgent → Fix 34 type errors
2. tddAgent → Fix 2 failing tests
3. storyAgent → Implement PROJ-123
4. reviewAgent → Code review
5. solidAgent → Ensure SOLID

Working...
```

### Step 3: Progress Updates
```
[10:45] ✅ Fixed all type errors
[10:47] ✅ Tests passing
[10:52] 🔄 Implementing user story...
[11:05] ✅ Story complete
[11:08] ✅ Code review passed
[11:10] ✅ SOLID principles verified
[11:11] ✅ Committed: feat(auth): add user login (PROJ-123)

Looking for next task...
```

## Smart Behaviors

### Handles Broken State
If your code is broken, `/dev` fixes it first:
```
/dev
⚠️ Build failing - fixing first...
- Running fixAgent...
- Running test suite...
✅ Build restored

Now proceeding with development...
```

### Picks Up Where You Left Off
If you have uncommitted changes:
```
/dev
Found uncommitted changes in auth.ts
Analyzing changes...
- Looks like incomplete login feature
- Found related tests
Continuing implementation...
```

### Learns Your Patterns
Reads from your codebase:
- Code style from existing files
- Test patterns from test files
- Commit format from git history
- Architecture from project structure

## Configuration (Optional)

Create `.claude/dev.config.json`:
```json
{
  "autoCommit": true,
  "commitPrefix": "feat|fix|refactor|test|docs",
  "testCoverage": 90,
  "maxFileSize": 200,
  "maxFunctionLength": 20,
  "priorityOrder": ["tests", "types", "stories", "todos"],
  "skipPatterns": ["*.generated.ts", "*.mock.ts"],
  "storySource": "github|jira|local"
}
```

## Work Sources

`/dev` finds work from:

### GitHub Issues
```markdown
# Issue #45: Add password reset
Users need ability to reset forgotten passwords
- [ ] Send reset email
- [ ] Verify token
- [ ] Update password
```

### JIRA Tickets
```
PROJ-123: As a user, I want to login
Acceptance Criteria:
- Email/password authentication
- Remember me option
- Rate limiting
```

### Local Files
```markdown
# stories/sprint-15.md
- [ ] USER-001: Login feature
- [ ] USER-002: Password reset
- [ ] USER-003: Profile page
```

### TODO Comments
```typescript
// TODO: Add input validation
// FIXME: Handle network errors
// HACK: Temporary workaround - fix properly
```

## Continuous Mode

`/dev` keeps working until:
- No more stories
- No more TODOs
- No more issues
- All tests pass
- No type errors
- No lint issues

Then reports:
```
=== DEV SESSION COMPLETE ===
Duration: 2 hours 15 minutes

Completed:
✅ 3 user stories
✅ Fixed 67 type errors
✅ Fixed 5 failing tests
✅ Resolved 12 TODOs
✅ 100% test coverage
✅ 0 lint issues

Commits: 8
- feat(auth): implement login (PROJ-123)
- feat(auth): add password reset (PROJ-124)
- feat(profile): create user profile (PROJ-125)
- fix(types): resolve type errors
- test: increase coverage to 100%
- refactor: apply SOLID principles
- docs: update API documentation
- chore: remove TODO comments

Codebase Status: PRODUCTION READY ✅
=============================
```

## Interrupt Handling

Press Ctrl+C or type "stop" to pause:
```
Stopping development...
✅ Current task completed
✅ Code committed
📋 Remaining work saved to .claude/dev.state

Resume with: /dev --continue
```

## Examples

### Morning Startup
```bash
/dev
# Checks CI status, fixes any overnight breaks,
# then starts on highest priority story
```

### After Pull Request
```bash
git pull origin main
/dev
# Resolves conflicts, fixes issues,
# continues development
```

### End of Sprint
```bash
/dev --sprint-close
# Completes all stories for current sprint,
# ensures everything is tested and documented
```

## Agent Chain

`/dev` typically runs this chain:

```
dev
 ├── fixAgent (if issues)
 ├── tddAgent (if test failures)
 ├── storyAgent (for features)
 │   ├── requirements
 │   ├── gherkin
 │   ├── testFirst
 │   └── implement
 ├── reviewAgent
 ├── solidAgent
 └── commitTdd
```

## Why Use /dev?

Instead of:
```bash
/fixAgent all
/testFirst auth
/implement AUTH-123
/reviewAgent
/solidAgent refactor
/commitTdd green
```

Just type:
```bash
/dev
```

And everything happens automatically, in the right order, with proper validation.

## The Promise

`/dev` promises to:
- Never leave your code broken
- Always write tests first
- Follow your project's patterns
- Commit working code
- Document what it does
- Keep going until done

Just type `/dev` and start coding!