#!/bin/bash
# Unit tests for utility functions in pipeline.sh
# Tests: acquire_lock, release_lock, retry_command, with_timeout, require_command, require_file, error_handler

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

PIPELINE="$PROJECT_ROOT/pipeline.sh"

echo "========================================="
echo "Running Utility Functions Unit Tests"
echo "========================================="
echo ""

# Extract functions from pipeline.sh
setup_utility_test_env() {
    setup_test_env

    # Create test script with utility functions
    cat > test_utility.sh <<'EOF'
#!/bin/bash
set -euo pipefail

# Error codes
readonly E_SUCCESS=0
readonly E_GENERIC=1
readonly E_INVALID_ARGS=2
readonly E_MISSING_DEPENDENCY=3
readonly E_TIMEOUT=8

# Configuration
MAX_RETRIES=${MAX_RETRIES:-3}
RETRY_DELAY=${RETRY_DELAY:-1}
OPERATION_TIMEOUT=${OPERATION_TIMEOUT:-30}

# Logging stubs
log_error() { echo "[ERROR] $1" >&2; }
log_warn() { echo "[WARN] $1" >&2; }
log_debug() { :; }
log_info() { :; }
EOF

    # Extract functions
    sed -n '/^acquire_lock()/,/^}/p' "$PIPELINE" >> test_utility.sh
    sed -n '/^release_lock()/,/^}/p' "$PIPELINE" >> test_utility.sh
    sed -n '/^retry_command()/,/^}/p' "$PIPELINE" >> test_utility.sh
    sed -n '/^with_timeout()/,/^}/p' "$PIPELINE" >> test_utility.sh
    sed -n '/^require_command()/,/^}/p' "$PIPELINE" >> test_utility.sh
    sed -n '/^require_file()/,/^}/p' "$PIPELINE" >> test_utility.sh
    sed -n '/^error_handler()/,/^}/p' "$PIPELINE" >> test_utility.sh

    # Add dispatcher
    cat >> test_utility.sh <<'EOF'

# Allow calling functions from command line
"$@"
EOF
    chmod +x test_utility.sh
}

#==============================================================================
# TESTS FOR acquire_lock() and release_lock() - CONCURRENCY CONTROL
#==============================================================================

# Test 1: acquire_lock creates lock directory
test_acquire_lock_creates_lock() {
    setup_utility_test_env

    lock_file=".pipeline/test.lock"
    rm -rf "$lock_file"

    # Acquire lock
    if bash test_utility.sh acquire_lock "$lock_file" 2>/dev/null; then
        :
    else
        echo "FAIL: acquire_lock failed to create lock"
        teardown_test_env
        return 1
    fi

    # Verify lock directory exists
    if [ ! -d "$lock_file" ]; then
        echo "FAIL: Lock directory was not created"
        teardown_test_env
        return 1
    fi

    # Verify PID file exists
    if [ ! -f "$lock_file/pid" ]; then
        echo "FAIL: PID file was not created"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: acquire_lock creates lock directory with PID"
    return 0
}

# Test 2: acquire_lock fails when lock already held
test_acquire_lock_fails_when_held() {
    setup_utility_test_env

    lock_file=".pipeline/test.lock"
    rm -rf "$lock_file"

    # Acquire lock first time
    bash test_utility.sh acquire_lock "$lock_file" 1 2>/dev/null

    # Try to acquire same lock again (should fail quickly with timeout=1)
    if bash test_utility.sh acquire_lock "$lock_file" 1 2>/dev/null; then
        echo "FAIL: acquire_lock succeeded when lock already held"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: acquire_lock fails when lock already held"
    return 0
}

# Test 3: release_lock removes lock directory
test_release_lock() {
    setup_utility_test_env

    lock_file=".pipeline/test.lock"
    rm -rf "$lock_file"

    # Acquire then release
    bash test_utility.sh acquire_lock "$lock_file" 2>/dev/null
    bash test_utility.sh release_lock "$lock_file" 2>/dev/null

    # Verify lock removed
    if [ -d "$lock_file" ]; then
        echo "FAIL: Lock directory still exists after release"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: release_lock removes lock directory"
    return 0
}

# Test 4: Stale lock detection
test_acquire_lock_stale_detection() {
    setup_utility_test_env

    lock_file=".pipeline/test.lock"
    rm -rf "$lock_file"

    # Create stale lock with non-existent PID
    mkdir -p "$lock_file"
    echo "999999" > "$lock_file/pid"

    # Try to acquire - should detect stale lock and succeed
    if bash test_utility.sh acquire_lock "$lock_file" 5 2>/dev/null; then
        :
    else
        echo "FAIL: acquire_lock did not remove stale lock"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: acquire_lock detects and removes stale locks"
    return 0
}

#==============================================================================
# TESTS FOR retry_command() - RESILIENCE
#==============================================================================

# Test 5: retry_command succeeds on first try
test_retry_command_success() {
    setup_utility_test_env

    # Command that succeeds
    if bash test_utility.sh retry_command true 2>/dev/null; then
        :
    else
        echo "FAIL: retry_command failed for successful command"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: retry_command succeeds on first try"
    return 0
}

# Test 6: retry_command retries on failure
test_retry_command_retries() {
    setup_utility_test_env

    # Create script that fails twice then succeeds
    cat > flaky_cmd.sh <<'FLAKY'
#!/bin/bash
if [ ! -f attempts.txt ]; then
    echo "1" > attempts.txt
    exit 1
elif [ "$(cat attempts.txt)" = "1" ]; then
    echo "2" > attempts.txt
    exit 1
else
    exit 0
fi
FLAKY
    chmod +x flaky_cmd.sh

    # Should succeed after retries
    if MAX_RETRIES=3 RETRY_DELAY=0 bash test_utility.sh retry_command ./flaky_cmd.sh 2>/dev/null; then
        :
    else
        echo "FAIL: retry_command did not retry"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: retry_command retries on failure"
    return 0
}

# Test 7: retry_command fails after max retries
test_retry_command_max_retries() {
    setup_utility_test_env

    # Command that always fails
    if MAX_RETRIES=2 RETRY_DELAY=0 bash test_utility.sh retry_command false 2>/dev/null; then
        echo "FAIL: retry_command succeeded for always-failing command"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: retry_command fails after max retries"
    return 0
}

#==============================================================================
# TESTS FOR require_command() and require_file() - DEPENDENCY CHECKING
#==============================================================================

# Test 8: require_command succeeds for existing command
test_require_command_exists() {
    setup_utility_test_env

    # bash should always exist
    if bash test_utility.sh require_command bash 2>/dev/null; then
        :
    else
        echo "FAIL: require_command failed for bash"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: require_command succeeds for existing commands"
    return 0
}

# Test 9: require_command fails for missing command
test_require_command_missing() {
    setup_utility_test_env

    # This command definitely doesn't exist
    if bash test_utility.sh require_command nonexistent_command_xyz123 2>/dev/null; then
        echo "FAIL: require_command succeeded for missing command"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: require_command fails for missing commands"
    return 0
}

# Test 10: require_file succeeds for existing file
test_require_file_exists() {
    setup_utility_test_env

    # Create test file
    echo "test" > test_file.txt

    if bash test_utility.sh require_file test_file.txt 2>/dev/null; then
        :
    else
        echo "FAIL: require_file failed for existing file"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: require_file succeeds for existing files"
    return 0
}

# Test 11: require_file fails for missing file
test_require_file_missing() {
    setup_utility_test_env

    if bash test_utility.sh require_file nonexistent_file.txt 2>/dev/null; then
        echo "FAIL: require_file succeeded for missing file"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: require_file fails for missing files"
    return 0
}

#==============================================================================
# TESTS FOR with_timeout() - OPERATION TIMEOUT
#==============================================================================

# Test 12: with_timeout succeeds for fast command
test_with_timeout_success() {
    setup_utility_test_env

    # Fast command with generous timeout
    if bash test_utility.sh with_timeout 10 echo "test" >/dev/null 2>&1; then
        :
    else
        echo "FAIL: with_timeout failed for fast command"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: with_timeout succeeds for fast commands"
    return 0
}

# Test 13: with_timeout kills slow command
test_with_timeout_kills_slow() {
    setup_utility_test_env

    # Slow command with short timeout (should timeout)
    if bash test_utility.sh with_timeout 1 sleep 10 2>/dev/null; then
        echo "FAIL: with_timeout did not kill slow command"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: with_timeout kills slow commands"
    return 0
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0

    # Lock tests
    if test_acquire_lock_creates_lock; then ((passed++)); else ((failed++)); fi
    if test_acquire_lock_fails_when_held; then ((passed++)); else ((failed++)); fi
    if test_release_lock; then ((passed++)); else ((failed++)); fi
    if test_acquire_lock_stale_detection; then ((passed++)); else ((failed++)); fi

    # Retry tests
    if test_retry_command_success; then ((passed++)); else ((failed++)); fi
    if test_retry_command_retries; then ((passed++)); else ((failed++)); fi
    if test_retry_command_max_retries; then ((passed++)); else ((failed++)); fi

    # Dependency tests
    if test_require_command_exists; then ((passed++)); else ((failed++)); fi
    if test_require_command_missing; then ((passed++)); else ((failed++)); fi
    if test_require_file_exists; then ((passed++)); else ((failed++)); fi
    if test_require_file_missing; then ((passed++)); else ((failed++)); fi

    # Timeout tests
    if test_with_timeout_success; then ((passed++)); else ((failed++)); fi
    if test_with_timeout_kills_slow; then ((passed++)); else ((failed++)); fi

    echo ""
    echo "========================================="
    echo "Results: $passed passed, $failed failed"
    echo "========================================="

    return $failed
}

# Run tests if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_all_tests
    exit $?
fi
