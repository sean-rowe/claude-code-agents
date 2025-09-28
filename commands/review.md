# Review Command

## What It Does
Reviews code quality and readiness.

## Usage
`/review`

## Steps
1. Run tests
2. Check for placeholders
3. Run build
4. Quality check

## Implementation
Use the reviewer agent:
```javascript
await Task({
  subagent_type: "general-purpose",
  description: "Code review",
  prompt: "Use reviewer agent to review the code"
});
```

## Output
```
[1/4] Running tests: ✓ Pass
[2/4] Checking placeholders: ✓ Clean
[3/4] Running build: ✓ Success
[4/4] Quality check: ✓ Pass

✓ Code review complete - Ready to merge
```