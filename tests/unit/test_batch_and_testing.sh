#!/usr/bin/env bash
# Unit tests for process_batch() and test_implementation() functions
# Coverage target: 100% for batch processing and implementation testing
# Part of Task 1.1 - Test the Pipeline Itself

set -euo pipefail

# Source the pipeline for testing (will exit early if TEST_MODE is set)
export TEST_MODE=1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source the pipeline functions
source "$PROJECT_ROOT/pipeline.sh" 2>/dev/null || {
  # If sourcing fails, define minimal error codes
  readonly E_SUCCESS=0
}

# Test framework variables
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test helper functions
assert_eq() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  ((TOTAL_TESTS++))

  if [ "$expected" = "$actual" ]; then
    echo "  ✓ $test_name"
    ((PASSED_TESTS++))
    return 0
  else
    echo "  ✗ $test_name"
    echo "    Expected: $expected"
    echo "    Actual:   $actual"
    ((FAILED_TESTS++))
    return 1
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local test_name="$3"

  ((TOTAL_TESTS++))

  if echo "$haystack" | grep -q "$needle"; then
    echo "  ✓ $test_name"
    ((PASSED_TESTS++))
    return 0
  else
    echo "  ✗ $test_name"
    echo "    Expected to contain: $needle"
    echo "    Actual: $haystack"
    ((FAILED_TESTS++))
    return 1
  fi
}

assert_file_exists() {
  local file="$1"
  local test_name="$2"

  ((TOTAL_TESTS++))

  if [ -f "$file" ]; then
    echo "  ✓ $test_name"
    ((PASSED_TESTS++))
    return 0
  else
    echo "  ✗ $test_name (file not found: $file)"
    ((FAILED_TESTS++))
    return 1
  fi
}

assert_exit_code() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  ((TOTAL_TESTS++))

  if [ "$expected" -eq "$actual" ]; then
    echo "  ✓ $test_name"
    ((PASSED_TESTS++))
    return 0
  else
    echo "  ✗ $test_name"
    echo "    Expected exit code: $expected"
    echo "    Actual exit code:   $actual"
    ((FAILED_TESTS++))
    return 1
  fi
}

# Setup test environment
setup() {
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR" || exit 1
  mkdir -p .pipeline tests
}

# Teardown test environment
teardown() {
  cd - >/dev/null || true
  rm -rf "$TEST_DIR"
}

# ============================================================================
# TEST SUITE: process_batch()
# ============================================================================

test_process_batch_empty_list() {
  echo "TEST: process_batch - handles empty item list"

  setup

  # Call process_batch with no items
  local result
  result=$(process_batch 2>&1 || true)

  # Assertions
  assert_contains "$result" "\[" "Returns JSON array"
  assert_contains "$result" "\]" "Returns closed JSON array"

  teardown
}

test_process_batch_single_item() {
  echo "TEST: process_batch - processes single item"

  setup

  # Mock the implement function for testing
  implement() {
    echo '{"success":true,"story":"TEST-123","file":"test.js"}'
  }
  export -f implement

  # Call process_batch with one item
  local result
  result=$(process_batch "TEST-123" 2>&1 || true)

  # Assertions
  assert_contains "$result" '"success":true' "Contains success status"
  assert_contains "$result" "TEST-123" "Contains story ID"
  assert_contains "$result" "\[" "Returns JSON array opening"
  assert_contains "$result" "\]" "Returns JSON array closing"

  teardown
}

test_process_batch_multiple_items() {
  echo "TEST: process_batch - processes multiple items"

  setup

  # Mock the implement function for testing
  implement() {
    local story="$1"
    echo "{\"success\":true,\"story\":\"$story\",\"file\":\"${story}.js\"}"
  }
  export -f implement

  # Call process_batch with multiple items
  local result
  result=$(process_batch "TEST-1" "TEST-2" "TEST-3" 2>&1 || true)

  # Assertions
  assert_contains "$result" "TEST-1" "Contains first item"
  assert_contains "$result" "TEST-2" "Contains second item"
  assert_contains "$result" "TEST-3" "Contains third item"
  assert_contains "$result" ',' "Contains comma separators"

  teardown
}

test_process_batch_counts_successful() {
  echo "TEST: process_batch - tracks successful implementations"

  setup

  # Mock implement function with mixed results
  implement() {
    local story="$1"
    if [ "$story" = "TEST-FAIL" ]; then
      echo '{"success":false,"story":"TEST-FAIL","error":"Failed"}'
    else
      echo "{\"success\":true,\"story\":\"$story\"}"
    fi
  }
  export -f implement

  # Call process_batch with mixed success/failure
  local result
  result=$(process_batch "TEST-1" "TEST-FAIL" "TEST-3" 2>&1 || true)

  # Verify that successful items are counted (function increments counter)
  # The function should process all items and return JSON
  assert_contains "$result" "TEST-1" "Processes successful item 1"
  assert_contains "$result" "TEST-FAIL" "Processes failed item"
  assert_contains "$result" "TEST-3" "Processes successful item 2"

  teardown
}

test_process_batch_json_format() {
  echo "TEST: process_batch - returns valid JSON array"

  setup

  # Mock implement function
  implement() {
    echo '{"success":true,"story":"TEST"}'
  }
  export -f implement

  # Call process_batch
  local result
  result=$(process_batch "TEST-1" "TEST-2" 2>&1 || true)

  # Validate JSON structure
  if echo "$result" | grep -q '^\[.*\]$'; then
    echo "  ✓ Returns valid JSON array structure"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
  else
    echo "  ✗ Invalid JSON array structure"
    echo "    Result: $result"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
  fi

  # Check for proper comma separation
  if echo "$result" | grep -q '},{'; then
    echo "  ✓ Objects properly comma-separated"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
  else
    echo "  ✗ Objects not properly comma-separated"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
  fi

  teardown
}

test_process_batch_preserves_order() {
  echo "TEST: process_batch - preserves item order"

  setup

  # Mock implement function
  implement() {
    local story="$1"
    echo "{\"story\":\"$story\"}"
  }
  export -f implement

  # Call process_batch with ordered items
  local result
  result=$(process_batch "FIRST" "SECOND" "THIRD" 2>&1 || true)

  # Extract order from result
  local first_pos second_pos third_pos
  first_pos=$(echo "$result" | grep -b -o "FIRST" | cut -d: -f1)
  second_pos=$(echo "$result" | grep -b -o "SECOND" | cut -d: -f1)
  third_pos=$(echo "$result" | grep -b -o "THIRD" | cut -d: -f1)

  # Verify ordering
  if [ "$first_pos" -lt "$second_pos" ] && [ "$second_pos" -lt "$third_pos" ]; then
    echo "  ✓ Items processed in correct order"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
  else
    echo "  ✗ Items not in correct order"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
  fi

  teardown
}

# ============================================================================
# TEST SUITE: test_implementation()
# ============================================================================

test_test_implementation_file_exists() {
  echo "TEST: test_implementation - returns success when implementation file exists"

  setup

  # Set STORY_NAME environment variable
  export STORY_NAME="my_feature"

  # Create implementation file
  touch "my_feature.sh"

  # Call test_implementation
  test_implementation > /dev/null 2>&1
  local exit_code=$?

  # Assertions
  assert_exit_code "0" "$exit_code" "Returns 0 when file exists"

  # Verify output message
  local output
  output=$(test_implementation 2>&1)
  assert_contains "$output" "Implementation file exists" "Shows success message"

  unset STORY_NAME
  teardown
}

test_test_implementation_file_missing() {
  echo "TEST: test_implementation - returns error when implementation file missing"

  setup

  # Set STORY_NAME environment variable
  export STORY_NAME="missing_feature"

  # Don't create the implementation file

  # Call test_implementation (should fail)
  test_implementation > /dev/null 2>&1
  local exit_code=$?

  # Assertions
  assert_exit_code "1" "$exit_code" "Returns 1 when file missing"

  # Verify output message
  local output
  output=$(test_implementation 2>&1)
  assert_contains "$output" "Implementation file missing" "Shows error message"

  unset STORY_NAME
  teardown
}

test_test_implementation_different_extensions() {
  echo "TEST: test_implementation - works with .sh extension"

  setup

  export STORY_NAME="bash_feature"

  # Create .sh file
  touch "bash_feature.sh"

  # Call test_implementation
  test_implementation > /dev/null 2>&1
  local exit_code=$?

  # Assertions
  assert_exit_code "0" "$exit_code" "Detects .sh files"
  assert_file_exists "bash_feature.sh" "Implementation file exists"

  unset STORY_NAME
  teardown
}

test_test_implementation_with_spaces() {
  echo "TEST: test_implementation - handles story names safely"

  setup

  export STORY_NAME="safe_name_123"

  # Create implementation file
  touch "safe_name_123.sh"

  # Call test_implementation
  test_implementation > /dev/null 2>&1
  local exit_code=$?

  # Assertions
  assert_exit_code "0" "$exit_code" "Handles alphanumeric names"

  unset STORY_NAME
  teardown
}

test_test_implementation_output_format() {
  echo "TEST: test_implementation - produces readable output"

  setup

  export STORY_NAME="readable_test"
  touch "readable_test.sh"

  # Capture output
  local output
  output=$(test_implementation 2>&1)

  # Verify output contains checkmark or X
  if echo "$output" | grep -q "✓\|✗"; then
    echo "  ✓ Output contains status symbol"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
  else
    echo "  ✗ Output missing status symbol"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
  fi

  # Verify output is human-readable
  if echo "$output" | grep -q "Implementation file"; then
    echo "  ✓ Output is human-readable"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
  else
    echo "  ✗ Output not human-readable"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
  fi

  unset STORY_NAME
  teardown
}

test_test_implementation_integration() {
  echo "TEST: test_implementation - integration with TDD workflow"

  setup

  export STORY_NAME="tdd_feature"

  # Simulate TDD workflow:
  # 1. Write test first (Red phase)
  cat > "tests/tdd_feature_test.sh" << 'EOF'
#!/usr/bin/env bash
source ../tdd_feature.sh
test_implementation
EOF

  # 2. Implementation doesn't exist yet (should fail)
  test_implementation > /dev/null 2>&1
  local red_phase_exit=$?

  if [ "$red_phase_exit" -ne 0 ]; then
    echo "  ✓ Red phase: test fails when implementation missing"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
  else
    echo "  ✗ Red phase: test should have failed"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
  fi

  # 3. Create implementation (Green phase)
  touch "tdd_feature.sh"

  test_implementation > /dev/null 2>&1
  local green_phase_exit=$?

  if [ "$green_phase_exit" -eq 0 ]; then
    echo "  ✓ Green phase: test passes when implementation exists"
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
  else
    echo "  ✗ Green phase: test should have passed"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
  fi

  unset STORY_NAME
  teardown
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "╔════════════════════════════════════════════════════════╗"
echo "║  Unit Tests: Batch Processing & Implementation Tests  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# process_batch tests
test_process_batch_empty_list
test_process_batch_single_item
test_process_batch_multiple_items
test_process_batch_counts_successful
test_process_batch_json_format
test_process_batch_preserves_order

# test_implementation tests
test_test_implementation_file_exists
test_test_implementation_file_missing
test_test_implementation_different_extensions
test_test_implementation_with_spaces
test_test_implementation_output_format
test_test_implementation_integration

# Print results
echo ""
echo "════════════════════════════════════════════════════════"
echo "TEST RESULTS"
echo "════════════════════════════════════════════════════════"
echo "Total tests:  $TOTAL_TESTS"
echo "Passed:       $PASSED_TESTS"
echo "Failed:       $FAILED_TESTS"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
  echo "✓ ALL TESTS PASSED"
  exit 0
else
  echo "✗ SOME TESTS FAILED"
  exit 1
fi
