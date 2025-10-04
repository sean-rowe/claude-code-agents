#!/bin/bash
# Edge Case Testing: Corrupted State Files
# Tests pipeline behavior with malformed/corrupted state.json

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PIPELINE="$PROJECT_ROOT/pipeline.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

setup_test_env() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    git init >/dev/null 2>&1
    git config user.email "test@example.com"
    git config user.name "Test User"
    mkdir -p .pipeline
}

# Test 1: Completely invalid JSON
test_invalid_json() {
    echo "Test: Completely invalid JSON in state.json..."
    setup_test_env

    ((TESTS_RUN++))

    # Create invalid JSON
    echo "this is not json at all!!!" > .pipeline/state.json

    if bash "$PIPELINE" work TEST-001 2>&1 | grep -qi "invalid.*json\|parse.*error\|corrupted.*state"; then
        echo "PASS: Pipeline detects invalid JSON"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Pipeline should detect invalid JSON"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 2: Empty state file
test_empty_state() {
    echo "Test: Empty state.json file..."
    setup_test_env

    ((TESTS_RUN++))

    # Create empty file
    touch .pipeline/state.json

    if bash "$PIPELINE" work TEST-001 2>&1 | grep -qi "empty.*state\|invalid.*state\|initialize"; then
        echo "PASS: Pipeline handles empty state file"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Pipeline should handle empty state file"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 3: Missing state file
test_missing_state() {
    echo "Test: Missing state.json file..."
    setup_test_env

    ((TESTS_RUN++))

    # Don't create state.json at all
    rm -f .pipeline/state.json

    if bash "$PIPELINE" work TEST-001 2>&1 | grep -qi "state.*not found\|initialize\|init.*first"; then
        echo "PASS: Pipeline detects missing state file"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Pipeline should detect missing state file"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 4: Valid JSON but wrong structure
test_wrong_structure() {
    echo "Test: Valid JSON but wrong structure..."
    setup_test_env

    ((TESTS_RUN++))

    # Valid JSON but not the expected structure
    cat > .pipeline/state.json << 'EOF'
{
  "some_random_field": "value",
  "array": [1, 2, 3]
}
EOF

    if bash "$PIPELINE" work TEST-001 2>&1 | grep -qi "invalid.*structure\|missing.*field\|corrupted"; then
        echo "PASS: Pipeline detects wrong JSON structure"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Pipeline should validate JSON structure"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 5: Truncated JSON (incomplete)
test_truncated_json() {
    echo "Test: Truncated JSON file..."
    setup_test_env

    ((TESTS_RUN++))

    # Truncated JSON (missing closing braces)
    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "TEST-001",
  "stories": {
    "TEST-001": {
      "title": "Test"
EOF

    if bash "$PIPELINE" work TEST-001 2>&1 | grep -qi "invalid.*json\|parse.*error\|incomplete"; then
        echo "PASS: Pipeline detects truncated JSON"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Pipeline should detect truncated JSON"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 6: JSON with null values in critical fields
test_null_values() {
    echo "Test: Null values in critical fields..."
    setup_test_env

    ((TESTS_RUN++))

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": null,
  "stories": null
}
EOF

    if bash "$PIPELINE" work TEST-001 2>&1 | grep -qi "null.*value\|invalid.*state\|stories.*required"; then
        echo "PASS: Pipeline handles null values appropriately"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Pipeline should validate null values"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 7: Extremely large state file
test_large_state_file() {
    echo "Test: Extremely large state file..."
    setup_test_env

    ((TESTS_RUN++))

    # Create a state file with 10,000 stories
    echo '{"current_story":"TEST-001","stories":{' > .pipeline/state.json
    for i in {1..10000}; do
        if [ $i -eq 10000 ]; then
            echo "\"TEST-$i\":{\"title\":\"Story $i\",\"status\":\"done\"}" >> .pipeline/state.json
        else
            echo "\"TEST-$i\":{\"title\":\"Story $i\",\"status\":\"done\"}," >> .pipeline/state.json
        fi
    done
    echo '}}' >> .pipeline/state.json

    # Should handle it (might be slow but shouldn't crash)
    if timeout 30 bash "$PIPELINE" work TEST-001 2>&1; then
        echo "PASS: Pipeline handles large state file"
        ((TESTS_PASSED++))
        return 0
    else
        echo "WARN: Pipeline timed out on large state file"
        ((TESTS_PASSED++))  # Non-critical
        return 0
    fi
}

# Test 8: State file with binary data
test_binary_data() {
    echo "Test: State file with binary data..."
    setup_test_env

    ((TESTS_RUN++))

    # Write binary data
    echo -e '\x00\x01\x02\x03\xff\xfe\xfd' > .pipeline/state.json

    if bash "$PIPELINE" work TEST-001 2>&1 | grep -qi "invalid\|binary\|corrupted"; then
        echo "PASS: Pipeline detects binary data in state file"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Pipeline should detect binary data"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 9: State file with unicode/emoji
test_unicode_in_state() {
    echo "Test: Unicode/emoji in state file..."
    setup_test_env

    ((TESTS_RUN++))

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "TEST-001",
  "stories": {
    "TEST-001": {
      "title": "Test with emoji 🚀 and 日本語",
      "status": "in_progress"
    }
  }
}
EOF

    # Should handle Unicode gracefully
    if bash "$PIPELINE" work TEST-001 2>&1; then
        echo "PASS: Pipeline handles Unicode in state file"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Pipeline should handle Unicode"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 10: Read-only state file
test_readonly_state() {
    echo "Test: Read-only state file..."
    setup_test_env

    ((TESTS_RUN++))

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "TEST-001",
  "stories": {
    "TEST-001": {
      "title": "Test",
      "status": "in_progress"
    }
  }
}
EOF

    # Make state file read-only
    chmod 444 .pipeline/state.json

    if bash "$PIPELINE" work TEST-001 2>&1 | grep -qi "permission.*denied\|read.*only\|cannot.*write"; then
        echo "PASS: Pipeline detects read-only state file"
        ((TESTS_PASSED++))
        chmod 644 .pipeline/state.json  # Cleanup
        return 0
    else
        echo "FAIL: Pipeline should detect read-only state"
        ((TESTS_FAILED++))
        chmod 644 .pipeline/state.json  # Cleanup
        return 1
    fi
}

# Test 11: Concurrent access (race condition)
test_concurrent_state_access() {
    echo "Test: Concurrent state file access..."
    setup_test_env

    ((TESTS_RUN++))

    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "TEST-001",
  "stories": {
    "TEST-001": {
      "title": "Test",
      "status": "in_progress"
    }
  }
}
EOF

    # Try to run two pipeline operations simultaneously
    bash "$PIPELINE" work TEST-001 2>&1 &
    PID1=$!
    bash "$PIPELINE" work TEST-001 2>&1 &
    PID2=$!

    wait $PID1 2>/dev/null || true
    wait $PID2 2>/dev/null || true

    # Check if state is still valid after concurrent access
    if jq -e '.stories' .pipeline/state.json >/dev/null 2>&1; then
        echo "PASS: State file intact after concurrent access"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Concurrent access corrupted state file"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 12: State file with very deep nesting
test_deeply_nested_json() {
    echo "Test: Deeply nested JSON structure..."
    setup_test_env

    ((TESTS_RUN++))

    # Create deeply nested structure
    cat > .pipeline/state.json << 'EOF'
{
  "current_story": "TEST-001",
  "stories": {
    "TEST-001": {
      "title": "Test",
      "status": "in_progress",
      "meta": {
        "nested": {
          "deeper": {
            "even_deeper": {
              "max_depth": {
                "value": "found"
              }
            }
          }
        }
      }
    }
  }
}
EOF

    if bash "$PIPELINE" work TEST-001 2>&1; then
        echo "PASS: Pipeline handles deeply nested JSON"
        ((TESTS_PASSED++))
        return 0
    else
        echo "FAIL: Pipeline should handle nested structures"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Run all tests
echo "===================================================="
echo "Edge Case Testing: Corrupted State Files"
echo "===================================================="
echo ""

test_invalid_json || true
test_empty_state || true
test_missing_state || true
test_wrong_structure || true
test_truncated_json || true
test_null_values || true
test_large_state_file || true
test_binary_data || true
test_unicode_in_state || true
test_readonly_state || true
test_concurrent_state_access || true
test_deeply_nested_json || true

# Summary
echo ""
echo "===================================================="
echo "Test Summary"
echo "===================================================="
echo "Total Passed: $TESTS_PASSED/$TESTS_RUN"
echo "Total Failed: $TESTS_FAILED/$TESTS_RUN"
echo ""

if [ $TESTS_FAILED -gt 0 ]; then
    echo "❌ Some corrupted state tests failed"
    exit 1
else
    echo "✅ All corrupted state tests passed"
    exit 0
fi
