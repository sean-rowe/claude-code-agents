# Dev Agent Command

Master command that orchestrates multiple specialized agents to handle development tasks autonomously.

## Usage
```
/dev-agent [story-id]
```
Or just:
```
/dev-agent
```

## What This Command Does

This command launches specialized agents using the Task tool to:
1. Analyze your codebase
2. Identify work to be done
3. Dispatch appropriate agents
4. Coordinate their work
5. Ensure quality standards

## Implementation

When you run `/dev-agent`, it executes:

```typescript
// Analyze codebase first
const analysis = await analyzeCodebase();

// Dispatch code-fixer agent if issues found
if (analysis.hasIssues) {
  await Task({
    subagent_type: "general-purpose",
    description: "Fix code issues",
    prompt: `
      You are a code-fixer agent. Fix ALL issues found:
      - ${analysis.typeErrors} type errors
      - ${analysis.lintErrors} lint errors
      - ${analysis.testFailures} test failures

      Rules:
      - Fix ALL issues, even if 1400+
      - No 'any' types
      - No UnknownType aliases
      - No stopping until complete

      Use these tools: Read, Edit, MultiEdit, Bash, Grep
      Return detailed fix report.
    `
  });
}

// Dispatch story-worker agent for features
if (analysis.hasStories) {
  await Task({
    subagent_type: "general-purpose",
    description: "Implement story",
    prompt: `
      You are a story-worker agent. Implement story ${analysis.nextStory}:

      1. Extract requirements
      2. Write BDD tests (must fail first)
      3. Implement code to pass tests
      4. Ensure SOLID principles
      5. Document all methods

      Rules:
      - Tests before code (TDD)
      - No 'any' types
      - Functions < 20 lines
      - Full documentation

      Use these tools: Read, Write, Edit, Bash, TodoWrite
      Return implementation report.
    `
  });
}

// Dispatch review agent
await Task({
  subagent_type: "general-purpose",
  description: "Review code",
  prompt: `
    You are a code-review agent. Review all code for:

    1. SOLID principles compliance
    2. Clean code metrics (function length, etc.)
    3. Type safety (no 'any')
    4. Documentation completeness
    5. Test coverage

    Fix any issues found.
    Return review report with metrics.
  `
});
```

## Agent Coordination

The command coordinates multiple agents:

```mermaid
graph TD
    A[/dev-agent] --> B[Analyze]
    B --> C{Issues?}
    C -->|Yes| D[code-fixer agent]
    C -->|No| E{Stories?}
    D --> E
    E -->|Yes| F[story-worker agent]
    E -->|No| G{TODOs?}
    F --> H[review agent]
    G --> H
    H --> I[Complete]
```

## Parallel Agent Execution

For faster execution, agents can run in parallel:

```typescript
// Run multiple agents simultaneously
await Promise.all([
  Task({
    subagent_type: "general-purpose",
    description: "Fix types",
    prompt: "Fix all TypeScript type errors..."
  }),
  Task({
    subagent_type: "general-purpose",
    description: "Fix tests",
    prompt: "Fix all failing tests..."
  }),
  Task({
    subagent_type: "general-purpose",
    description: "Fix lint",
    prompt: "Fix all linting issues..."
  })
]);
```

## Progress Tracking

Agents report progress through TodoWrite:

```
=== AGENT PROGRESS ===
✅ code-fixer: Fixed 145/145 type errors
✅ code-fixer: Fixed 23/23 lint issues
🔄 story-worker: Implementing LOGIN-123 (60%)
⏳ review-agent: Waiting
⏳ solid-agent: Waiting
======================
```

## Configuration

Agents read configuration from:
- `.claude/agents.config.json`
- `.claude/rules.md`
- `package.json` scripts
- Project README

## Example Workflows

### Fix Everything First
```bash
/dev-agent --fix-first
# Ensures clean slate before features
```

### Implement Specific Story
```bash
/dev-agent PROJ-123
# Focuses on single story
```

### Continuous Development
```bash
/dev-agent --continuous
# Keeps working until no tasks remain
```

## Agent Rules

All agents follow these rules:
1. NO 'any' types
2. NO placeholder code
3. NO console.log
4. NO magic values
5. MUST write tests first
6. MUST document methods
7. MUST fix ALL issues
8. MUST validate work

## Success Report

```
=== DEV-AGENT COMPLETE ===
Duration: 45 minutes

Agents Dispatched: 4
- code-fixer: ✅ Fixed 178 issues
- story-worker: ✅ Implemented LOGIN-123
- review-agent: ✅ Code reviewed
- solid-agent: ✅ SOLID compliant

Work Completed:
- Type errors: 0
- Lint issues: 0
- Test failures: 0
- Stories done: 1
- Coverage: 95%

Status: PRODUCTION READY ✅
==========================
```

This is a TRUE agent-based command that uses Claude's Task tool to dispatch specialized agents!