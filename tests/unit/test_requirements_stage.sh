#!/bin/bash
# Unit tests for requirements stage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

test_requirements_creates_pipeline_directory() {
    setup_test_env

    run_pipeline requirements "Test Initiative" >/dev/null

    # Requirements stage should create .pipeline directory
    assert_dir_exists ".pipeline" || return 1

    teardown_test_env
    echo "PASS: requirements creates pipeline directory structure"
}

test_requirements_creates_requirements_file() {
    setup_test_env

    run_pipeline requirements "Authentication System" >/dev/null

    assert_file_exists ".pipeline/requirements.md" || return 1
    assert_file_contains ".pipeline/requirements.md" "Authentication System" || return 1
    assert_file_contains ".pipeline/requirements.md" "Functional Requirements" || return 1
    assert_file_contains ".pipeline/requirements.md" "Non-Functional Requirements" || return 1

    teardown_test_env
    echo "PASS: requirements creates requirements.md file"
}

test_requirements_creates_state_file() {
    setup_test_env

    run_pipeline requirements "Test" >/dev/null

    assert_file_exists ".pipeline/state.json" || return 1
    assert_file_contains ".pipeline/state.json" "requirements" || return 1
    assert_file_contains ".pipeline/state.json" "PROJ" || return 1

    teardown_test_env
    echo "PASS: requirements creates state.json"
}

test_requirements_with_existing_gitignore() {
    setup_test_env

    # Create a .gitignore file first
    echo "node_modules/" > .gitignore

    run_pipeline requirements "Test" >/dev/null

    # If .gitignore exists, pipeline should add .pipeline to it
    assert_file_contains ".gitignore" ".pipeline" || return 1

    teardown_test_env
    echo "PASS: requirements adds .pipeline to existing .gitignore"
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0

    echo "========================================="
    echo "Running Requirements Stage Unit Tests"
    echo "========================================="
    echo ""

    if test_requirements_creates_pipeline_directory; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_requirements_creates_requirements_file; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_requirements_creates_state_file; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_requirements_with_existing_gitignore; then
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
