#!/bin/bash
# Unit tests for gherkin stage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

test_gherkin_creates_features_directory() {
    setup_test_env

    # Initialize with requirements first
    run_pipeline requirements "Test" >/dev/null

    run_pipeline gherkin >/dev/null

    assert_dir_exists ".pipeline/features" || return 1

    teardown_test_env
    echo "PASS: gherkin creates features directory"
}

test_gherkin_creates_feature_files() {
    setup_test_env

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null

    assert_file_exists ".pipeline/features/authentication.feature" || return 1
    assert_file_exists ".pipeline/features/authorization.feature" || return 1
    assert_file_exists ".pipeline/features/data.feature" || return 1

    teardown_test_env
    echo "PASS: gherkin creates feature files"
}

test_gherkin_feature_has_correct_format() {
    setup_test_env

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null

    local feature=".pipeline/features/authentication.feature"

    assert_file_contains "$feature" "Feature: authentication" || return 1
    assert_file_contains "$feature" "Rule:" || return 1
    assert_file_contains "$feature" "Example:" || return 1
    assert_file_contains "$feature" "Given" || return 1
    assert_file_contains "$feature" "When" || return 1
    assert_file_contains "$feature" "Then" || return 1

    teardown_test_env
    echo "PASS: gherkin feature has correct BDD format"
}

test_gherkin_updates_state() {
    setup_test_env

    # Requires jq for this test
    if ! command -v jq &>/dev/null; then
        echo "SKIP: gherkin updates state (jq not installed)"
        return 0
    fi

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null

    local stage=$(jq -r '.stage' .pipeline/state.json)
    if [ "$stage" != "gherkin" ]; then
        echo "FAIL: state.json stage is '$stage', expected 'gherkin'"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: gherkin updates state to 'gherkin'"
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0

    echo "========================================="
    echo "Running Gherkin Stage Unit Tests"
    echo "========================================="
    echo ""

    if test_gherkin_creates_features_directory; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_gherkin_creates_feature_files; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_gherkin_feature_has_correct_format; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_gherkin_updates_state; then
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
