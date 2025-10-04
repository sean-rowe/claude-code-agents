#!/bin/bash
# Unit tests for error handling framework

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

test_dry_run_flag_prevents_file_creation() {
    setup_test_env

    # Run requirements with --dry-run
    run_pipeline --dry-run requirements "Test" >/dev/null 2>&1

    # Should NOT create requirements.md
    if [ -f .pipeline/requirements.md ]; then
        echo "FAIL: Dry-run mode created files (should not create any files)"
        teardown_test_env
        return 1
    fi

    # Should only create errors.log (from init_logging)
    if [ ! -f .pipeline/errors.log ]; then
        echo "FAIL: Dry-run mode did not create error log"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: dry-run flag prevents file creation"
}

test_verbose_flag_enables_logging() {
    setup_test_env

    # Create .pipeline directory first so logging works
    mkdir -p .pipeline

    # Run with --verbose flag
    output=$(run_pipeline --verbose status 2>&1)

    # Should show "Verbose mode enabled" message
    if ! echo "$output" | grep -q "Verbose mode enabled"; then
        echo "FAIL: Verbose mode did not enable"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: verbose flag enables logging"
}

test_debug_flag_shows_debug_messages() {
    setup_test_env

    # Create .pipeline directory first
    mkdir -p .pipeline

    # Run with --debug flag
    output=$(run_pipeline --debug status 2>&1)

    # Should show "Debug mode enabled" message
    if ! echo "$output" | grep -q "Debug mode enabled"; then
        echo "FAIL: Debug mode did not enable"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: debug flag shows debug messages"
}

test_error_log_file_created() {
    setup_test_env

    run_pipeline requirements "Test" >/dev/null 2>&1

    # Should create .pipeline/errors.log
    assert_file_exists ".pipeline/errors.log" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: error log file is created"
}

test_help_shows_error_codes() {
    setup_test_env

    output=$(run_pipeline --help 2>&1)

    # Help should document error codes
    if ! echo "$output" | grep -q "Error Codes:"; then
        echo "FAIL: Help does not show error codes section"
        teardown_test_env
        return 1
    fi

    # Should list specific error codes
    if ! echo "$output" | grep -q "0   Success"; then
        echo "FAIL: Help does not list success code"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: help shows error codes"
}

test_help_shows_new_flags() {
    setup_test_env

    output=$(run_pipeline --help 2>&1)

    # Help should document new flags
    if ! echo "$output" | grep -q "verbose"; then
        echo "FAIL: Help does not mention verbose flag"
        teardown_test_env
        return 1
    fi

    if ! echo "$output" | grep -q "debug"; then
        echo "FAIL: Help does not mention debug flag"
        teardown_test_env
        return 1
    fi

    if ! echo "$output" | grep -q "dry-run"; then
        echo "FAIL: Help does not mention dry-run flag"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: help shows new flags"
}

test_dry_run_works_across_stages() {
    setup_test_env

    # Test dry-run on requirements
    output=$(run_pipeline --dry-run requirements "Test" 2>&1)
    if ! echo "$output" | grep -q "DRY-RUN"; then
        echo "FAIL: requirements stage dry-run did not show [DRY-RUN] marker"
        teardown_test_env
        return 1
    fi

    # Test dry-run on gherkin
    output=$(run_pipeline --dry-run gherkin 2>&1)
    if ! echo "$output" | grep -q "DRY-RUN"; then
        echo "FAIL: gherkin stage dry-run did not show [DRY-RUN] marker"
        teardown_test_env
        return 1
    fi

    # Test dry-run on cleanup
    output=$(run_pipeline --dry-run cleanup 2>&1)
    if ! echo "$output" | grep -q "DRY-RUN"; then
        echo "FAIL: cleanup stage dry-run did not show [DRY-RUN] marker"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: dry-run works across multiple stages"
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0

    echo "========================================="
    echo "Running Error Handling Framework Tests"
    echo "========================================="
    echo ""

    if test_dry_run_flag_prevents_file_creation; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_verbose_flag_enables_logging; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_debug_flag_shows_debug_messages; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_error_log_file_created; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_help_shows_error_codes; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_help_shows_new_flags; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_dry_run_works_across_stages; then
        ((passed++))
    else
        ((failed++))
    fi

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
