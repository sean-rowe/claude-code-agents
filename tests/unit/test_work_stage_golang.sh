#!/bin/bash
# Unit tests for work stage - Go language code generation

# Source test helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

echo "========================================="
echo "Running Work Stage (Go) Unit Tests"
echo "========================================="
echo ""

# Test 1: Go test file generation
test_go_test_file_generation() {
    setup_test_env

    # Create Go project structure
    mkdir -p src
    cat > go.mod << 'EOF'
module example.com/testproject

go 1.21
EOF

    # Create requirements
    mkdir -p .pipeline
    cat > .pipeline/requirements.md << 'EOF'
# Requirements

## Story: USER-123
Add user authentication

**Acceptance Criteria:**
- Validate user credentials
- Return authentication token
- Handle invalid credentials
EOF

    # Create state with story
    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "USER-123",
  "stories": {
    "USER-123": {
      "title": "Add user authentication",
      "status": "in_progress"
    }
  }
}
EOF

    # Run work stage
    if bash "$PIPELINE_SH" work USER-123 >/dev/null 2>&1; then
        # Check if test file was created
        if find . -name "*_test.go" -type f | grep -q "."; then
            echo "PASS: Go test file generated"
            return 0
        else
            echo "FAIL: No Go test file found"
            find . -type f -name "*.go"
            return 1
        fi
    else
        echo "FAIL: work stage failed for Go project"
        return 1
    fi
}

# Test 2: Go test file syntax
test_go_test_syntax() {
    setup_test_env

    # Create Go project
    mkdir -p src
    cat > go.mod << 'EOF'
module example.com/testproject

go 1.21
EOF

    mkdir -p .pipeline
    cat > .pipeline/requirements.md << 'EOF'
# Requirements
## Story: USER-124
Calculate sum of two numbers
EOF

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "USER-124",
  "stories": {
    "USER-124": {
      "title": "Calculate sum",
      "status": "in_progress"
    }
  }
}
EOF

    # Run work stage
    bash "$PIPELINE_SH" work USER-124 >/dev/null 2>&1

    # Find generated test file
    TEST_FILE=$(find . -name "*_test.go" -type f | head -1)

    if [ -n "$TEST_FILE" ] && [ -f "$TEST_FILE" ]; then
        # Check for Go test syntax
        if grep -q "^package " "$TEST_FILE" && \
           grep -q "import.*testing" "$TEST_FILE" && \
           grep -q "func Test" "$TEST_FILE" && \
           grep -q "\*testing\.T" "$TEST_FILE"; then
            echo "PASS: Go test file has valid syntax"
            return 0
        else
            echo "FAIL: Go test file missing required elements"
            echo "Content:"
            cat "$TEST_FILE"
            return 1
        fi
    else
        echo "FAIL: No test file generated"
        return 1
    fi
}

# Test 3: Go implementation file generation
test_go_implementation_generation() {
    setup_test_env

    # Create Go project
    mkdir -p src
    cat > go.mod << 'EOF'
module example.com/testproject

go 1.21
EOF

    mkdir -p .pipeline
    cat > .pipeline/requirements.md << 'EOF'
# Requirements
## Story: USER-125
Implement user validation
EOF

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "USER-125",
  "stories": {
    "USER-125": {
      "title": "Implement user validation",
      "status": "in_progress"
    }
  }
}
EOF

    # Run work stage
    bash "$PIPELINE_SH" work USER-125 >/dev/null 2>&1

    # Check for implementation file
    IMPL_FILE=$(find . -name "*.go" -type f ! -name "*_test.go" | head -1)

    if [ -n "$IMPL_FILE" ] && [ -f "$IMPL_FILE" ]; then
        # Verify it has package and function
        if grep -q "^package " "$IMPL_FILE" && \
           grep -q "^func " "$IMPL_FILE"; then
            echo "PASS: Go implementation file generated with valid syntax"
            return 0
        else
            echo "FAIL: Go implementation file invalid"
            cat "$IMPL_FILE"
            return 1
        fi
    else
        echo "FAIL: No Go implementation file generated"
        find . -name "*.go"
        return 1
    fi
}

# Test 4: Go mod file detection
test_go_project_detection() {
    setup_test_env

    # Create Go project indicators
    cat > go.mod << 'EOF'
module example.com/test

go 1.21
EOF

    mkdir -p .pipeline
    cat > .pipeline/requirements.md << 'EOF'
# Requirements
## Story: USER-126
Test detection
EOF

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "USER-126",
  "stories": {
    "USER-126": {
      "title": "Test",
      "status": "in_progress"
    }
  }
}
EOF

    # Run work stage - should detect Go
    if bash "$PIPELINE_SH" work USER-126 >/dev/null 2>&1; then
        # Should have created .go files, not .js or .py
        GO_COUNT=$(find . -name "*.go" | wc -l)
        JS_COUNT=$(find . -name "*.js" | wc -l)
        PY_COUNT=$(find . -name "*.py" | wc -l)

        if [ "$GO_COUNT" -gt 0 ] && [ "$JS_COUNT" -eq 0 ] && [ "$PY_COUNT" -eq 0 ]; then
            echo "PASS: Go project correctly detected"
            return 0
        else
            echo "FAIL: Wrong language detected (Go: $GO_COUNT, JS: $JS_COUNT, PY: $PY_COUNT)"
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

for test_func in test_go_test_file_generation test_go_test_syntax test_go_implementation_generation test_go_project_detection; do
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
