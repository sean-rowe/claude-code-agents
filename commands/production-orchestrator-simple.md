# Production Orchestrator (Simplified)

Ensures stories are implemented with real, working, tested code.

## Usage
```
/production-orchestrator story STORY-123
```

## What It Actually Does

### 1. Detect Project Type
- Node.js → `npm run build` & `npm test`
- Rust → `cargo build` & `cargo test`
- Go → `go build` & `go test`
- Python → `pytest`
- Makefile → `make` & `make test`

### 2. Implement Story
- Dispatches story-worker agent
- Enforces TDD (tests first)
- No placeholder code allowed

### 3. Verify Build
- Runs actual build command
- Shows real output
- Fixes errors if found
- Retries until passing

### 4. Verify Tests
- Runs actual test suite
- Shows test results
- Fixes failures if found
- Retries until passing

### 5. Check for Placeholders
- Greps for TODO/FIXME/XXX
- Replaces with real code
- Verifies clean

### 6. Optional Checks
- Runs lint if available
- Runs typecheck if available
- Auto-fixes when possible

### 7. Evidence Report
Shows proof:
- Build command & output
- Test command & results
- Placeholder scan results
- Timestamp

## Example Output

```
=== ORCHESTRATOR EXECUTION ===
1. Detected: Node.js project
2. Dispatching story-worker for STORY-123
3. Running: npm run build
   Output: ✓ Built in 2.3s
4. Running: npm test
   Output: 15 passing, 0 failing
5. Scanning for placeholders... CLEAN
6. Story COMPLETE with evidence

Evidence:
- Build: SUCCESS (exit code 0)
- Tests: 15/15 passing
- Placeholders: NONE
- Timestamp: 2024-01-15T10:30:00Z
===========================
```

## What It Guarantees

✅ Code actually builds
✅ Tests actually pass
✅ No placeholder code
✅ Evidence provided

## What It Doesn't Do

❌ Security scanning
❌ Performance testing
❌ Database migrations
❌ CI/CD generation
❌ Deployment

Keep it simple. Make it work.