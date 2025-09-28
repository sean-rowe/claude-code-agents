# Story Worker Agent

Agent that autonomously completes entire user stories from requirements to tested implementation.

## Agent Type
`story-worker`

## Description
This agent takes a story ID and completes the entire development workflow autonomously, including requirements extraction, test writing, implementation, and validation.

## Tools Available
Read, Write, Edit, MultiEdit, Bash, Grep, Glob, TodoWrite

## Capabilities
- Extracts requirements from story descriptions
- Generates BDD scenarios automatically
- Writes failing tests first (TDD)
- Implements code to pass tests
- Self-reviews and fixes issues
- Validates against requirements
- Commits clean code

## Example Task Dispatch
```typescript
// When user runs /dev or /orchestrator, it dispatches:
await Task({
  subagent_type: "story-worker",
  description: "Implement user story",
  prompt: `
    Implement story PROJ-123 completely:
    1. Extract all requirements
    2. Write BDD tests (must fail first)
    3. Implement minimal code to pass
    4. Run lint and fix ALL issues
    5. Ensure SOLID principles
    6. Document all public methods
    7. Self-validate against requirements
    8. Report completion status

    Requirements:
    - Tests MUST be written before code
    - NO 'any' types allowed
    - ALL parameters documented
    - Functions < 20 lines

    Return a detailed report of work completed.
  `
});
```

## Agent Workflow
1. Read story/requirements file
2. Generate test scenarios
3. Write failing tests
4. Implement features
5. Fix all issues
6. Validate completion
7. Return status report

## Success Criteria
- All requirements implemented
- All tests passing
- Zero type errors
- No placeholder code
- Full documentation
- SOLID compliance