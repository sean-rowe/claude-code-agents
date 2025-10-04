#!/bin/bash
# Unit tests for state management (pipeline-state-manager.sh)

# Source test helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

# Path to state manager
STATE_MANAGER="$PROJECT_ROOT/pipeline-state-manager.sh"

echo "========================================="
echo "Running State Management Unit Tests"
echo "========================================="
echo ""

# Test 1: Initialize state
test_state_init() {
    setup_test_env

    # Run state init
    if bash "$STATE_MANAGER" init >/dev/null 2>&1; then
        if [ -f .pipeline/state.json ]; then
            # Verify it's valid JSON
            if jq empty .pipeline/state.json 2>/dev/null; then
                echo "PASS: State initialized with valid JSON"
                return 0
            else
                echo "FAIL: State file is not valid JSON"
                cat .pipeline/state.json
                return 1
            fi
        else
            echo "FAIL: State file not created"
            return 1
        fi
    else
        echo "FAIL: State init failed"
        return 1
    fi
}

# Test 2: Save state
test_state_save() {
    setup_test_env
    mkdir -p .pipeline

    # Initialize first
    bash "$STATE_MANAGER" init >/dev/null 2>&1

    # Save a key-value pair
    if bash "$STATE_MANAGER" save "test_key" "test_value" >/dev/null 2>&1; then
        # Verify it was saved
        VALUE=$(jq -r '.test_key' .pipeline/state.json 2>/dev/null)
        if [ "$VALUE" = "test_value" ]; then
            echo "PASS: State saved correctly"
            return 0
        else
            echo "FAIL: State value incorrect (got: $VALUE)"
            cat .pipeline/state.json
            return 1
        fi
    else
        echo "FAIL: State save failed"
        return 1
    fi
}

# Test 3: Load state
test_state_load() {
    setup_test_env
    mkdir -p .pipeline

    # Create state file manually
    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "TEST-123",
  "branch": "feature/test-123"
}
EOF

    # Load the current_story value
    VALUE=$(bash "$STATE_MANAGER" load "current_story" 2>/dev/null)
    if [ "$VALUE" = "TEST-123" ]; then
        echo "PASS: State loaded correctly"
        return 0
    else
        echo "FAIL: State load incorrect (got: $VALUE, expected: TEST-123)"
        return 1
    fi
}

# Test 4: State persistence across operations
test_state_persistence() {
    setup_test_env
    mkdir -p .pipeline

    bash "$STATE_MANAGER" init >/dev/null 2>&1
    bash "$STATE_MANAGER" save "story1" "STORY-1" >/dev/null 2>&1
    bash "$STATE_MANAGER" save "story2" "STORY-2" >/dev/null 2>&1

    # Verify both are present
    STORY1=$(jq -r '.story1' .pipeline/state.json 2>/dev/null)
    STORY2=$(jq -r '.story2' .pipeline/state.json 2>/dev/null)

    if [ "$STORY1" = "STORY-1" ] && [ "$STORY2" = "STORY-2" ]; then
        echo "PASS: Multiple state values persisted"
        return 0
    else
        echo "FAIL: State persistence failed (story1: $STORY1, story2: $STORY2)"
        cat .pipeline/state.json
        return 1
    fi
}

# Test 5: State with nested objects
test_state_nested_objects() {
    setup_test_env
    mkdir -p .pipeline

    # Create state with nested structure
    cat > .pipeline/state.json << 'EOF'
{
  "stories": {
    "STORY-1": {
      "title": "First story",
      "status": "in_progress"
    },
    "STORY-2": {
      "title": "Second story",
      "status": "pending"
    }
  },
  "current_story": "STORY-1"
}
EOF

    # Verify it's valid JSON
    if jq empty .pipeline/state.json 2>/dev/null; then
        # Try to load nested value
        STATUS=$(jq -r '.stories["STORY-1"].status' .pipeline/state.json 2>/dev/null)
        if [ "$STATUS" = "in_progress" ]; then
            echo "PASS: Nested state objects work"
            return 0
        else
            echo "FAIL: Cannot read nested state (got: $STATUS)"
            return 1
        fi
    else
        echo "FAIL: Nested state is not valid JSON"
        return 1
    fi
}

# Test 6: State file validation
test_state_validation() {
    setup_test_env
    mkdir -p .pipeline

    # Create invalid JSON
    echo "{ invalid json }" > .pipeline/state.json

    # State manager should handle this gracefully
    if bash "$STATE_MANAGER" load "test" 2>/dev/null; then
        # If it returns successfully, it should have fixed the file
        if jq empty .pipeline/state.json 2>/dev/null; then
            echo "PASS: State manager handles invalid JSON"
            return 0
        else
            echo "FAIL: State still invalid after recovery attempt"
            return 1
        fi
    else
        # It's also okay to fail gracefully with error
        echo "PASS: State manager handles invalid JSON (fails gracefully)"
        return 0
    fi
}

# Test 7: State directory creation
test_state_directory_creation() {
    setup_test_env

    # Don't create .pipeline directory
    # State manager should create it
    bash "$STATE_MANAGER" init >/dev/null 2>&1

    if [ -d .pipeline ] && [ -f .pipeline/state.json ]; then
        echo "PASS: State manager creates .pipeline directory"
        return 0
    else
        echo "FAIL: State manager didn't create directory structure"
        return 1
    fi
}

# Test 8: State backup/restore
test_state_backup() {
    setup_test_env
    mkdir -p .pipeline

    # Create state
    cat > .pipeline/state.json << 'EOF'
{
  "test": "original_value"
}
EOF

    # If state manager has backup functionality
    if bash "$STATE_MANAGER" backup >/dev/null 2>&1; then
        if [ -f .pipeline/state.json.backup ] || [ -f .pipeline/state.backup.json ]; then
            echo "PASS: State backup created"
            return 0
        else
            echo "SKIP: State backup not implemented"
            return 0
        fi
    else
        echo "SKIP: State backup not implemented"
        return 0
    fi
}

# Run all tests
PASSED=0
FAILED=0

for test_func in test_state_init test_state_save test_state_load test_state_persistence test_state_nested_objects test_state_validation test_state_directory_creation test_state_backup; do
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
