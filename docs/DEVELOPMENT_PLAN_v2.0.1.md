# Development Plan for v2.0.1

**Status:** Planning
**Target Release:** Optional enhancements
**Priority:** Medium

---

## Overview

v2.0.1 focuses on optional enhancements identified in the fourth code review that improve the developer experience without being release blockers.

---

## Planned Enhancements

### 1. Add Syntax Validation for Generated Code

**Priority:** HIGH
**Effort:** Medium
**Impact:** Prevents runtime errors from malformed generated code

**Implementation:**

Add validation after code generation in `pipeline.sh` work stage:

```bash
# After generating Python files
if command -v python3 &>/dev/null; then
  echo "Validating Python syntax..."
  if python3 -m py_compile "$IMPL_DIR/${STORY_NAME}.py" 2>/dev/null; then
    echo "✓ Python implementation syntax valid"
  else
    echo "⚠ Python implementation has syntax errors"
    python3 -m py_compile "$IMPL_DIR/${STORY_NAME}.py"
  fi

  if python3 -m py_compile "$TEST_DIR/test_${STORY_NAME}.py" 2>/dev/null; then
    echo "✓ Python test syntax valid"
  else
    echo "⚠ Python test has syntax errors"
    python3 -m py_compile "$TEST_DIR/test_${STORY_NAME}.py"
  fi
fi

# After generating JavaScript files
if command -v node &>/dev/null; then
  echo "Validating JavaScript syntax..."
  if node --check "src/${STORY_NAME}.js" 2>/dev/null; then
    echo "✓ JavaScript implementation syntax valid"
  else
    echo "⚠ JavaScript implementation has syntax errors"
    node --check "src/${STORY_NAME}.js"
  fi

  if node --check "src/${STORY_NAME}.test.js" 2>/dev/null; then
    echo "✓ JavaScript test syntax valid"
  else
    echo "⚠ JavaScript test has syntax errors"
    node --check "src/${STORY_NAME}.test.js"
  fi
fi

# After generating Go files
if command -v go &>/dev/null; then
  echo "Validating Go syntax..."
  if go vet "./${STORY_NAME}.go" 2>/dev/null; then
    echo "✓ Go implementation syntax valid"
  else
    echo "⚠ Go implementation has issues"
    go vet "./${STORY_NAME}.go"
  fi

  if go vet "./${STORY_NAME}_test.go" 2>/dev/null; then
    echo "✓ Go test syntax valid"
  else
    echo "⚠ Go test has issues"
    go vet "./${STORY_NAME}_test.go"
  fi
fi
```

**Benefits:**
- Catches syntax errors immediately
- Better developer experience
- Prevents wasted time running tests with broken code

**Location:** `pipeline.sh` work stage (after file generation, before git commit)

---

### 2. Improve Python Import Handling

**Priority:** MEDIUM
**Effort:** Medium
**Impact:** Fixes Python import path issues identified in fourth review

**Current Issue:**

```python
# tests/test_story_name.py
from story_name import implement, validate  # Fails if story_name.py is in src/
```

**Solution 1: Add __init__.py to make it a package**

```bash
# In Python implementation section
mkdir -p "$IMPL_DIR"

# Add __init__.py if in src/ or package directory
if [ "$IMPL_DIR" != "." ]; then
  touch "$IMPL_DIR/__init__.py"
fi

cat > "$IMPL_DIR/${STORY_NAME}.py" <<EOF
...
EOF
```

**Solution 2: Use relative imports in tests**

```bash
# Update test template for Python
cat > "$TEST_DIR/test_${STORY_NAME}.py" <<EOF
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

# Import from implementation directory
if Path('src/${STORY_NAME}.py').exists():
    from src.${STORY_NAME} import implement, validate
elif Path('${IMPL_DIR}/${STORY_NAME}.py').exists():
    from ${IMPL_DIR}.${STORY_NAME} import implement, validate
else:
    from ${STORY_NAME} import implement, validate

def test_implement():
    assert implement() == True

def test_validate():
    assert validate() == True
EOF
```

**Recommendation:** Use Solution 1 (add __init__.py) as it's simpler and follows Python best practices.

**Benefits:**
- Tests run immediately without manual fixes
- Follows Python package conventions
- Better developer experience

**Location:** `pipeline.sh` work stage (Python implementation section)

---

### 3. Add Basic Integration Tests

**Priority:** LOW
**Effort:** High
**Impact:** Ensures pipeline itself works correctly

**Implementation:**

Create `tests/integration/test_pipeline.sh`:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test setup
TEST_PROJECT_DIR="/tmp/pipeline_test_$$"
mkdir -p "$TEST_PROJECT_DIR"
cd "$TEST_PROJECT_DIR"

echo "========================================"
echo "Pipeline Integration Tests"
echo "========================================"
echo ""

# Test 1: Help command
echo "Test 1: Help command..."
if "$PROJECT_ROOT/pipeline.sh" | grep -q "Pipeline Controller"; then
  echo "✓ PASS: Help displays correctly"
else
  echo "✗ FAIL: Help not displayed"
  exit 1
fi

# Test 2: Help with argument
echo "Test 2: Help with explicit argument..."
if "$PROJECT_ROOT/pipeline.sh" help | grep -q "Pipeline Controller"; then
  echo "✓ PASS: Explicit help works"
else
  echo "✗ FAIL: Explicit help failed"
  exit 1
fi

# Test 3: State initialization
echo "Test 3: State initialization..."
source "$PROJECT_ROOT/pipeline-state-manager.sh"
init_state
if [ -f ".pipeline/state.json" ]; then
  echo "✓ PASS: State file created"
else
  echo "✗ FAIL: State file not created"
  exit 1
fi

# Test 4: State update
echo "Test 4: State update..."
update_state "stage" "test"
STAGE=$(get_state "stage")
if [ "$STAGE" = "test" ]; then
  echo "✓ PASS: State updates correctly"
else
  echo "✗ FAIL: State update failed (got: $STAGE)"
  exit 1
fi

# Test 5: State reset
echo "Test 5: State reset..."
reset_state
if [ ! -d ".pipeline" ]; then
  echo "✓ PASS: State reset works"
else
  echo "✗ FAIL: State reset failed"
  exit 1
fi

# Test 6: Python directory detection
echo "Test 6: Python directory detection..."
mkdir -p mypackage
touch requirements.txt
# Would need to extract and test the directory detection logic

# Cleanup
cd /tmp
rm -rf "$TEST_PROJECT_DIR"

echo ""
echo "========================================"
echo "All Tests Passed!"
echo "========================================"
```

**Benefits:**
- Catches regressions
- Validates fixes work as intended
- Increases confidence in releases

**Location:** New file `tests/integration/test_pipeline.sh`

---

### 4. Enhanced Error Messages with Recovery Commands

**Priority:** LOW
**Effort:** Low
**Impact:** Better developer experience when errors occur

**Implementation:**

Add more specific error messages throughout:

```bash
# Example: When JIRA connection fails
if ! project_exists "$PROJECT_KEY"; then
  echo "❌ ERROR: Cannot connect to JIRA or project $PROJECT_KEY not found"
  echo ""
  echo "Recovery options:"
  echo "  1. Check JIRA credentials: ./scripts/utils/diagnose-jira.sh"
  echo "  2. Create project: ./scripts/setup/setup-jira.sh"
  echo "  3. Verify .env file has correct JIRA_URL and JIRA_API_TOKEN"
  echo ""
  exit 1
fi

# Example: When git push fails
if ! git push -u origin "$BRANCH_NAME" 2>&1; then
  echo ""
  echo "❌ ERROR: Failed to push to remote"
  echo ""
  echo "Common causes:"
  echo "  - No remote configured: git remote add origin <url>"
  echo "  - No permissions: Check GitHub/GitLab access"
  echo "  - Branch protection: May need PR instead of direct push"
  echo ""
  echo "To retry: git push -u origin $BRANCH_NAME"
  echo ""
fi
```

**Benefits:**
- Self-documenting error recovery
- Reduces time to fix issues
- Better UX

**Location:** Various locations in `pipeline.sh`

---

## Implementation Order

### Phase 1: Quick Wins (v2.0.1)
1. ✅ Add syntax validation (1-2 hours)
2. ✅ Improve Python import handling with __init__.py (30 minutes)
3. ✅ Enhanced error messages (1 hour)

### Phase 2: Testing Infrastructure (v2.0.2)
4. Add basic integration tests (4-6 hours)
5. Add CI/CD pipeline for tests (2 hours)

---

## Success Criteria

**v2.0.1 is ready when:**
- ✅ Syntax validation runs after code generation
- ✅ Python imports work without manual fixes
- ✅ Error messages include recovery commands
- ✅ All existing functionality still works
- ✅ Documentation updated

**Testing:**
- Run pipeline on JavaScript project → validate syntax checked
- Run pipeline on Python project → validate imports work
- Trigger errors → validate recovery commands shown
- Run all code review verification tests

---

## Timeline

**Estimated Effort:** 4-5 hours
**Target Completion:** Same day as started
**Release:** When all Phase 1 items complete

---

## Risks and Mitigation

### Risk 1: Syntax validation breaks workflow
**Mitigation:** Make validation warnings, not errors. Don't block on validation failures.

### Risk 2: Python import fixes break existing projects
**Mitigation:** Only add __init__.py if $IMPL_DIR != ".", preserving current behavior for root directory.

### Risk 3: Changes introduce new bugs
**Mitigation:** Test thoroughly, follow same review process as v2.0.0.

---

## Open Questions

1. Should syntax validation block commit, or just warn?
   - **Recommendation:** Warn only, don't block (developers might want to commit and fix later)

2. Should we add syntax validation for Bash generated code?
   - **Recommendation:** Yes, use `bash -n` to check syntax

3. Should Python imports use absolute or relative imports?
   - **Recommendation:** Absolute with __init__.py (more standard)

---

## Documentation Updates Needed

- Update THIRD_REVIEW_FIXES.md to note Python import issue is resolved
- Update stub warning to mention syntax validation
- Add syntax validation to quickstart guide
- Update migration guide if any changes affect existing projects

---

## Future Considerations (v2.1+)

Deferred to later releases:
- Refactor pipeline.sh into modules
- Plugin system for languages
- Enhanced state management
- Web UI for pipeline visualization
- Support for more test frameworks

---

**Plan Status:** ✅ Complete
**Ready to Implement:** Yes
**Approval Required:** No (optional enhancements)
