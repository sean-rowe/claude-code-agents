# Implement Command

## What It Does
Implements a story using TDD.

## Usage
`/implement [STORY-ID]`

## Steps
1. Create feature branch
2. Write failing tests
3. Implement to pass tests
4. Commit and push

## Implementation
Use the implementer agent:
```javascript
await Task({
  subagent_type: "general-purpose",
  description: "Story implementation",
  prompt: "Use implementer agent to implement story ${STORY_ID}"
});
```

## Output
```
[1/5] Working on: STORY-123
[2/5] Creating feature branch
[3/5] Writing tests (red phase)
[4/5] Implementing (green phase)
[5/5] Committing
✓ Story STORY-123 complete
```