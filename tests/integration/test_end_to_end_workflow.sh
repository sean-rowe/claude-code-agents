#!/bin/bash
# Integration test for complete pipeline workflow
# Tests: requirements → gherkin → stories → work → complete

# Source test helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

echo "========================================="
echo "Running End-to-End Workflow Integration Test"
echo "========================================="
echo ""

# Test 1: Complete workflow for JavaScript project
test_complete_javascript_workflow() {
    setup_test_env

    echo "Setting up JavaScript project..."
    # Create package.json to indicate JavaScript project
    cat > package.json << 'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "scripts": {
    "test": "jest"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  }
}
EOF

    # Initialize git
    git init >/dev/null 2>&1
    git config user.email "test@example.com"
    git config user.name "Test User"

    echo "Step 1: Generate requirements..."
    # Run requirements stage
    if ! bash "$PIPELINE_SH" requirements "User authentication system" >/dev/null 2>&1; then
        echo "FAIL: Requirements stage failed"
        return 1
    fi

    # Verify requirements.md exists
    if [ ! -f .pipeline/requirements.md ]; then
        echo "FAIL: requirements.md not created"
        return 1
    fi

    echo "Step 2: Generate Gherkin scenarios..."
    # Run gherkin stage
    if ! bash "$PIPELINE_SH" gherkin >/dev/null 2>&1; then
        echo "FAIL: Gherkin stage failed"
        return 1
    fi

    # Verify gherkin files exist
    if [ ! -d .pipeline/gherkin ]; then
        echo "FAIL: Gherkin directory not created"
        return 1
    fi

    echo "Step 3: Create user stories (dry-run - no JIRA)..."
    # Run stories stage in dry-run mode (no actual JIRA calls)
    if ! bash "$PIPELINE_SH" --dry-run stories >/dev/null 2>&1; then
        echo "FAIL: Stories stage failed"
        return 1
    fi

    echo "Step 4: Simulate work stage..."
    # Manually create state for a story (simulating JIRA story creation)
    mkdir -p .pipeline
    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "TEST-001",
  "epic_id": "TEST-EPIC",
  "stories": {
    "TEST-001": {
      "title": "Implement user login",
      "status": "in_progress",
      "branch": "feature/TEST-001-user-login"
    }
  }
}
EOF

    # Run work stage
    if ! bash "$PIPELINE_SH" work TEST-001 >/dev/null 2>&1; then
        echo "FAIL: Work stage failed"
        return 1
    fi

    # Verify test and implementation files were created
    TEST_COUNT=$(find . -name "*.test.js" -o -name "*.spec.js" | wc -l)
    IMPL_COUNT=$(find . -name "*.js" ! -name "*.test.js" ! -name "*.spec.js" | grep -v node_modules | wc -l)

    if [ "$TEST_COUNT" -eq 0 ]; then
        echo "FAIL: No test files generated"
        find . -name "*.js"
        return 1
    fi

    if [ "$IMPL_COUNT" -eq 0 ]; then
        echo "FAIL: No implementation files generated"
        find . -name "*.js"
        return 1
    fi

    echo "Step 5: Complete stage (dry-run)..."
    # Run complete stage in dry-run
    if ! bash "$PIPELINE_SH" --dry-run complete TEST-001 >/dev/null 2>&1; then
        echo "FAIL: Complete stage failed"
        return 1
    fi

    echo "PASS: Complete JavaScript workflow succeeded"
    return 0
}

# Test 2: Complete workflow for Python project
test_complete_python_workflow() {
    setup_test_env

    echo "Setting up Python project..."
    # Create requirements.txt to indicate Python project
    cat > requirements.txt << 'EOF'
pytest==7.4.0
EOF

    # Initialize git
    git init >/dev/null 2>&1
    git config user.email "test@example.com"
    git config user.name "Test User"

    echo "Running Python workflow (requirements → work)..."

    # Requirements
    bash "$PIPELINE_SH" requirements "Data validation utility" >/dev/null 2>&1

    # Gherkin
    bash "$PIPELINE_SH" gherkin >/dev/null 2>&1

    # Create story state
    mkdir -p .pipeline
    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "PY-001",
  "stories": {
    "PY-001": {
      "title": "Validate email format",
      "status": "in_progress"
    }
  }
}
EOF

    # Work stage
    bash "$PIPELINE_SH" work PY-001 >/dev/null 2>&1

    # Verify Python files created
    TEST_COUNT=$(find . -name "test_*.py" | wc -l)
    IMPL_COUNT=$(find . -name "*.py" ! -name "test_*" | wc -l)

    if [ "$TEST_COUNT" -gt 0 ] && [ "$IMPL_COUNT" -gt 0 ]; then
        echo "PASS: Complete Python workflow succeeded"
        return 0
    else
        echo "FAIL: Python files not generated (tests: $TEST_COUNT, impl: $IMPL_COUNT)"
        find . -name "*.py"
        return 1
    fi
}

# Test 3: Workflow state transitions
test_workflow_state_transitions() {
    setup_test_env

    # Create minimal project
    echo '{"name": "test"}' > package.json

    git init >/dev/null 2>&1
    git config user.email "test@example.com"
    git config user.name "Test User"

    echo "Testing state transitions..."

    # After requirements stage
    bash "$PIPELINE_SH" requirements "Test feature" >/dev/null 2>&1
    if [ ! -f .pipeline/state.json ]; then
        echo "FAIL: State not created after requirements"
        return 1
    fi

    # State should be valid JSON
    if ! jq empty .pipeline/state.json 2>/dev/null; then
        echo "FAIL: State is not valid JSON after requirements"
        cat .pipeline/state.json
        return 1
    fi

    # After gherkin stage
    bash "$PIPELINE_SH" gherkin >/dev/null 2>&1

    # State should still be valid
    if ! jq empty .pipeline/state.json 2>/dev/null; then
        echo "FAIL: State corrupted after gherkin"
        return 1
    fi

    echo "PASS: Workflow state transitions work correctly"
    return 0
}

# Test 4: Cleanup stage
test_cleanup_stage() {
    setup_test_env

    # Create project structure
    echo '{"name": "test"}' > package.json
    mkdir -p .pipeline
    echo '{"test": "data"}' > .pipeline/state.json
    echo "# Requirements" > .pipeline/requirements.md

    # Run cleanup
    if bash "$PIPELINE_SH" cleanup >/dev/null 2>&1; then
        # .pipeline directory should be removed
        if [ ! -d .pipeline ]; then
            echo "PASS: Cleanup stage removes .pipeline directory"
            return 0
        else
            echo "FAIL: Cleanup didn't remove .pipeline"
            ls -la .pipeline/
            return 1
        fi
    else
        echo "FAIL: Cleanup stage failed"
        return 1
    fi
}

# Test 5: Status command
test_status_command() {
    setup_test_env

    mkdir -p .pipeline
    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "STATUS-001",
  "epic_id": "STATUS-EPIC",
  "stories": {
    "STATUS-001": {
      "title": "Test status",
      "status": "in_progress"
    }
  }
}
EOF

    # Run status command
    OUTPUT=$(bash "$PIPELINE_SH" status 2>&1)

    # Should show current story
    if echo "$OUTPUT" | grep -q "STATUS-001"; then
        echo "PASS: Status command shows current story"
        return 0
    else
        echo "FAIL: Status command doesn't show story info"
        echo "Output: $OUTPUT"
        return 1
    fi
}

# Test 6: Dry-run mode across all stages
test_dry_run_mode() {
    setup_test_env

    echo '{"name": "test"}' > package.json
    git init >/dev/null 2>&1
    git config user.email "test@example.com"
    git config user.name "Test User"

    echo "Testing dry-run mode..."

    # Dry-run requirements - should not create files
    bash "$PIPELINE_SH" --dry-run requirements "Test" >/dev/null 2>&1

    # Should NOT create requirements.md
    if [ -f .pipeline/requirements.md ]; then
        echo "FAIL: Dry-run created requirements.md"
        return 1
    fi

    # Manually create minimal structure for next stages
    mkdir -p .pipeline
    echo "# Requirements" > .pipeline/requirements.md

    # Dry-run gherkin
    bash "$PIPELINE_SH" --dry-run gherkin >/dev/null 2>&1

    # Should NOT create gherkin directory
    if [ -d .pipeline/gherkin ]; then
        echo "FAIL: Dry-run created gherkin directory"
        return 1
    fi

    echo "PASS: Dry-run mode works across stages"
    return 0
}

# Run all integration tests
PASSED=0
FAILED=0

for test_func in test_complete_javascript_workflow test_complete_python_workflow test_workflow_state_transitions test_cleanup_stage test_status_command test_dry_run_mode; do
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
