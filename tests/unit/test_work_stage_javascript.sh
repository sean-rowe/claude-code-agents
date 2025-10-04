#!/bin/bash
# Unit tests for work stage - JavaScript code generation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

test_work_generates_javascript_test_file() {
    setup_test_env
    setup_nodejs_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_exists "src/proj_2.test.js" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: work generates JavaScript test file"
}

test_work_generates_javascript_implementation() {
    setup_test_env
    setup_nodejs_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_exists "src/proj_2.js" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: work generates JavaScript implementation"
}

test_javascript_implementation_has_validate_function() {
    setup_test_env
    setup_nodejs_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_contains "src/proj_2.js" "function validate" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: JavaScript implementation has validate function"
}

test_javascript_implementation_has_implement_function() {
    setup_test_env
    setup_nodejs_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_contains "src/proj_2.js" "function implement" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: JavaScript implementation has implement function"
}

test_javascript_has_real_validation_logic() {
    setup_test_env
    setup_nodejs_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    # Verify NOT a stub - check for "return true" or "return false" only
    if grep -qE '^\s*return (true|false)\s*;?\s*$' "src/proj_2.js"; then
        echo "FAIL: Found stub code (bare return true/false)"
        teardown_test_env
        return 1
    fi

    # Check for actual type checking logic (must be in code, not comments)
    if ! grep -qE 'typeof\s+\w+\s*===' "src/proj_2.js"; then
        echo "FAIL: Missing typeof type checking logic"
        teardown_test_env
        return 1
    fi

    # Check for null/undefined handling
    if ! grep -qE '(===|!==)\s*(null|undefined)' "src/proj_2.js"; then
        echo "FAIL: Missing null/undefined checking logic"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: JavaScript has real validation logic (not stub)"
}

test_javascript_has_jsdoc_comments() {
    setup_test_env
    setup_nodejs_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_contains "src/proj_2.js" "@param" || {
        teardown_test_env
        return 1
    }

    assert_file_contains "src/proj_2.js" "@returns" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: JavaScript has JSDoc comments"
}

test_javascript_syntax_is_valid() {
    setup_test_env
    setup_nodejs_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    if command -v node &>/dev/null; then
        if ! node --check src/proj_2.js 2>/dev/null; then
            echo "FAIL: JavaScript syntax is invalid"
            teardown_test_env
            return 1
        fi
    else
        echo "SKIP: node not installed, cannot validate syntax"
        teardown_test_env
        return 0
    fi

    teardown_test_env
    echo "PASS: JavaScript syntax is valid"
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0

    echo "========================================="
    echo "Running Work Stage JavaScript Tests"
    echo "========================================="
    echo ""

    if test_work_generates_javascript_test_file; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_work_generates_javascript_implementation; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_javascript_implementation_has_validate_function; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_javascript_implementation_has_implement_function; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_javascript_has_real_validation_logic; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_javascript_has_jsdoc_comments; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_javascript_syntax_is_valid; then
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
