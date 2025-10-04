#!/bin/bash
# Unit tests for work stage - Bash language code generation

# Source test helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

echo "========================================="
echo "Running Work Stage (Bash) Unit Tests"
echo "========================================="
echo ""

# Test 1: Bash test file generation
test_bash_test_file_generation() {
    setup_test_env

    # Create Bash project structure (no package.json, go.mod, or requirements.txt)
    mkdir -p scripts

    # Create requirements
    mkdir -p .pipeline
    cat > .pipeline/requirements.md << 'EOF'
# Requirements

## Story: BASH-101
Create backup script

**Acceptance Criteria:**
- Create backup of specified directory
- Add timestamp to backup name
- Validate source directory exists
EOF

    # Create state
    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "BASH-101",
  "stories": {
    "BASH-101": {
      "title": "Create backup script",
      "status": "in_progress"
    }
  }
}
EOF

    # Run work stage
    if bash "$PIPELINE_SH" work BASH-101 >/dev/null 2>&1; then
        # Check for test file (should have test_ prefix or _test suffix)
        if find . -name "test_*.sh" -o -name "*_test.sh" | grep -q "."; then
            echo "PASS: Bash test file generated"
            return 0
        else
            echo "FAIL: No Bash test file found"
            find . -name "*.sh" -type f
            return 1
        fi
    else
        echo "FAIL: work stage failed for Bash project"
        return 1
    fi
}

# Test 2: Bash test file has shebang
test_bash_test_shebang() {
    setup_test_env

    mkdir -p scripts
    mkdir -p .pipeline
    cat > .pipeline/requirements.md << 'EOF'
# Requirements
## Story: BASH-102
File validation script
EOF

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "BASH-102",
  "stories": {
    "BASH-102": {
      "title": "File validation",
      "status": "in_progress"
    }
  }
}
EOF

    # Run work stage
    bash "$PIPELINE_SH" work BASH-102 >/dev/null 2>&1

    # Find test file
    TEST_FILE=$(find . -name "test_*.sh" -o -name "*_test.sh" | head -1)

    if [ -n "$TEST_FILE" ] && [ -f "$TEST_FILE" ]; then
        # Check for shebang
        if head -1 "$TEST_FILE" | grep -q "^#!/.*bash"; then
            echo "PASS: Bash test file has correct shebang"
            return 0
        else
            echo "FAIL: Bash test file missing shebang"
            head -5 "$TEST_FILE"
            return 1
        fi
    else
        echo "FAIL: No test file generated"
        return 1
    fi
}

# Test 3: Bash implementation file generation
test_bash_implementation_generation() {
    setup_test_env

    mkdir -p scripts
    mkdir -p .pipeline
    cat > .pipeline/requirements.md << 'EOF'
# Requirements
## Story: BASH-103
Log rotation utility
EOF

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "BASH-103",
  "stories": {
    "BASH-103": {
      "title": "Log rotation utility",
      "status": "in_progress"
    }
  }
}
EOF

    # Run work stage
    bash "$PIPELINE_SH" work BASH-103 >/dev/null 2>&1

    # Find implementation file (not test file)
    IMPL_FILE=$(find . -name "*.sh" -type f ! -name "test_*" ! -name "*_test.sh" ! -name "run_all_tests.sh" | head -1)

    if [ -n "$IMPL_FILE" ] && [ -f "$IMPL_FILE" ]; then
        # Check for shebang and function
        if head -1 "$IMPL_FILE" | grep -q "^#!/.*bash" && \
           grep -q "^[a-z_]*() {" "$IMPL_FILE"; then
            echo "PASS: Bash implementation file generated with shebang and function"
            return 0
        else
            echo "FAIL: Bash implementation file invalid"
            cat "$IMPL_FILE"
            return 1
        fi
    else
        echo "FAIL: No Bash implementation file generated"
        return 1
    fi
}

# Test 4: Bash project detection (no package managers)
test_bash_project_detection() {
    setup_test_env

    # Don't create package.json, go.mod, or requirements.txt
    # Bash should be default/fallback
    mkdir -p scripts

    mkdir -p .pipeline
    cat > .pipeline/requirements.md << 'EOF'
# Requirements
## Story: BASH-104
Default to bash
EOF

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "BASH-104",
  "stories": {
    "BASH-104": {
      "title": "Default",
      "status": "in_progress"
    }
  }
}
EOF

    # Run work stage
    if bash "$PIPELINE_SH" work BASH-104 >/dev/null 2>&1; then
        # Should create .sh files, not .js, .py, or .go
        SH_COUNT=$(find . -name "*.sh" ! -name "run_all_tests.sh" | wc -l)
        JS_COUNT=$(find . -name "*.js" | wc -l)
        PY_COUNT=$(find . -name "*.py" | wc -l)
        GO_COUNT=$(find . -name "*.go" | wc -l)

        if [ "$SH_COUNT" -gt 0 ] && [ "$JS_COUNT" -eq 0 ] && [ "$PY_COUNT" -eq 0 ] && [ "$GO_COUNT" -eq 0 ]; then
            echo "PASS: Bash detected as default language"
            return 0
        else
            echo "FAIL: Wrong language (SH: $SH_COUNT, JS: $JS_COUNT, PY: $PY_COUNT, GO: $GO_COUNT)"
            find . -type f \( -name "*.sh" -o -name "*.js" -o -name "*.py" -o -name "*.go" \)
            return 1
        fi
    else
        echo "FAIL: work stage failed"
        return 1
    fi
}

# Run all tests
PASSED=0
FAILED=0

for test_func in test_bash_test_file_generation test_bash_test_shebang test_bash_implementation_generation test_bash_project_detection; do
    if $test_func; then
        ((PASSED++))
    else
        ((FAILED++))
    fi
    echo ""
done

echo "========================================="
echo "Results: $PASSED passed, $FAILED failed"
echo "========================================="

exit $FAILED
