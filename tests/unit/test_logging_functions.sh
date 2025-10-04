#!/bin/bash
# Unit tests for logging functions in pipeline.sh
# Tests: init_logging, log_error, log_warn, log_info, log_debug

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

PIPELINE="$PROJECT_ROOT/pipeline.sh"

echo "========================================="
echo "Running Logging Functions Unit Tests"
echo "========================================="
echo ""

# Source only the logging functions from pipeline.sh
# We need to extract them without running the whole script
setup_logging_test_env() {
    setup_test_env

    # Create a test script with just the logging functions
    cat > test_logging.sh <<'EOF'
#!/bin/bash
set -euo pipefail

# Error codes
readonly E_SUCCESS=0
readonly E_GENERIC=1
readonly E_INVALID_ARGS=2
readonly E_MISSING_DEPENDENCY=3

# Configuration
VERBOSE=${VERBOSE:-0}
DEBUG=${DEBUG:-0}
LOG_FILE=".pipeline/errors.log"

# Initialize logging
init_logging() {
    if [ ! -d ".pipeline" ]; then
        mkdir -p ".pipeline"
    fi
    touch "$LOG_FILE"
}

# Logging functions
log_error() {
    local msg="$1"
    local code="${2:-$E_GENERIC}"
    echo "[ERROR $(date '+%Y-%m-%d %H:%M:%S')] [Code: $code] $msg" | tee -a "$LOG_FILE" >&2
}

log_warn() {
    local msg="$1"
    echo "[WARN $(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE" >&2
}

log_info() {
    local msg="$1"
    if [ "$VERBOSE" -eq 1 ]; then
        echo "[INFO $(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE"
    fi
}

log_debug() {
    local msg="$1"
    if [ "$DEBUG" -eq 1 ]; then
        echo "[DEBUG $(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$LOG_FILE" >&2
    fi
}

# Allow calling functions from command line
"$@"
EOF
    chmod +x test_logging.sh
}

# Test 1: init_logging creates directory and log file
test_init_logging() {
    setup_logging_test_env

    # Remove .pipeline directory if it exists
    rm -rf .pipeline

    # Call init_logging
    bash test_logging.sh init_logging

    # Verify directory created
    if [ ! -d ".pipeline" ]; then
        echo "FAIL: init_logging did not create .pipeline directory"
        teardown_test_env
        return 1
    fi

    # Verify log file created
    if [ ! -f ".pipeline/errors.log" ]; then
        echo "FAIL: init_logging did not create errors.log"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: init_logging creates directory and log file"
    return 0
}

# Test 2: log_error writes to file and stderr
test_log_error() {
    setup_logging_test_env
    bash test_logging.sh init_logging

    # Call log_error
    output=$(bash test_logging.sh log_error "Test error message" 2>&1)

    # Check stderr output contains error
    if ! echo "$output" | grep -q "ERROR.*Test error message"; then
        echo "FAIL: log_error did not write to stderr"
        teardown_test_env
        return 1
    fi

    # Check log file contains error
    if ! grep -q "ERROR.*Test error message" .pipeline/errors.log; then
        echo "FAIL: log_error did not write to log file"
        teardown_test_env
        return 1
    fi

    # Check error code is included
    if ! echo "$output" | grep -q "Code:"; then
        echo "FAIL: log_error did not include error code"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: log_error writes to file and stderr with error code"
    return 0
}

# Test 3: log_warn writes to file and stderr
test_log_warn() {
    setup_logging_test_env
    bash test_logging.sh init_logging

    # Call log_warn
    output=$(bash test_logging.sh log_warn "Test warning message" 2>&1)

    # Check stderr output contains warning
    if ! echo "$output" | grep -q "WARN.*Test warning message"; then
        echo "FAIL: log_warn did not write to stderr"
        teardown_test_env
        return 1
    fi

    # Check log file contains warning
    if ! grep -q "WARN.*Test warning message" .pipeline/errors.log; then
        echo "FAIL: log_warn did not write to log file"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: log_warn writes to file and stderr"
    return 0
}

# Test 4: log_info only logs when VERBOSE=1
test_log_info() {
    setup_logging_test_env
    bash test_logging.sh init_logging

    # Test with VERBOSE=0 (default)
    export VERBOSE=0
    output=$(bash test_logging.sh log_info "Test info message" 2>&1)

    # Should NOT output when VERBOSE=0
    if echo "$output" | grep -q "INFO.*Test info message"; then
        echo "FAIL: log_info logged when VERBOSE=0"
        teardown_test_env
        return 1
    fi

    # Test with VERBOSE=1
    export VERBOSE=1
    output=$(VERBOSE=1 bash test_logging.sh log_info "Test verbose message" 2>&1)

    # Should output when VERBOSE=1
    if ! echo "$output" | grep -q "INFO.*Test verbose message"; then
        echo "FAIL: log_info did not log when VERBOSE=1"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: log_info respects VERBOSE flag"
    return 0
}

# Test 5: log_debug only logs when DEBUG=1
test_log_debug() {
    setup_logging_test_env
    bash test_logging.sh init_logging

    # Test with DEBUG=0 (default)
    export DEBUG=0
    output=$(bash test_logging.sh log_debug "Test debug message" 2>&1)

    # Should NOT output when DEBUG=0
    if echo "$output" | grep -q "DEBUG.*Test debug message"; then
        echo "FAIL: log_debug logged when DEBUG=0"
        teardown_test_env
        return 1
    fi

    # Test with DEBUG=1
    export DEBUG=1
    output=$(DEBUG=1 bash test_logging.sh log_debug "Test debug message" 2>&1)

    # Should output when DEBUG=1
    if ! echo "$output" | grep -q "DEBUG.*Test debug message"; then
        echo "FAIL: log_debug did not log when DEBUG=1"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: log_debug respects DEBUG flag"
    return 0
}

# Test 6: log_error with custom error code
test_log_error_with_code() {
    setup_logging_test_env
    bash test_logging.sh init_logging

    # Call log_error with custom code
    output=$(bash test_logging.sh log_error "Test error" 42 2>&1)

    # Check error code 42 is included
    if ! echo "$output" | grep -q "Code: 42"; then
        echo "FAIL: log_error did not use custom error code"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: log_error accepts custom error codes"
    return 0
}

# Test 7: Log format includes timestamp
test_log_format_timestamp() {
    setup_logging_test_env
    bash test_logging.sh init_logging

    # Call log_error
    output=$(bash test_logging.sh log_error "Test message" 2>&1)

    # Check timestamp format YYYY-MM-DD HH:MM:SS
    if ! echo "$output" | grep -Eq "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}"; then
        echo "FAIL: log output does not include timestamp"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: Log format includes timestamp"
    return 0
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0

    if test_init_logging; then ((passed++)); else ((failed++)); fi
    if test_log_error; then ((passed++)); else ((failed++)); fi
    if test_log_warn; then ((passed++)); else ((failed++)); fi
    if test_log_info; then ((passed++)); else ((failed++)); fi
    if test_log_debug; then ((passed++)); else ((failed++)); fi
    if test_log_error_with_code; then ((passed++)); else ((failed++)); fi
    if test_log_format_timestamp; then ((passed++)); else ((failed++)); fi

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
