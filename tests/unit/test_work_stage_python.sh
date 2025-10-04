#!/bin/bash
# Unit tests for work stage - Python code generation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

test_work_generates_python_test_file() {
    setup_test_env
    setup_python_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_exists "tests/test_proj_2.py" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: work generates Python test file"
}

test_work_generates_python_implementation() {
    setup_test_env
    setup_python_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_exists "src/proj_2.py" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: work generates Python implementation"
}

test_python_implementation_has_validate_function() {
    setup_test_env
    setup_python_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_contains "src/proj_2.py" "def validate" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: Python implementation has validate function"
}

test_python_implementation_has_implement_function() {
    setup_test_env
    setup_python_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_contains "src/proj_2.py" "def implement" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: Python implementation has implement function"
}

test_python_has_type_hints() {
    setup_test_env
    setup_python_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    # Check if file exists
    if [ ! -f "src/proj_2.py" ]; then
        echo "FAIL: src/proj_2.py does not exist"
        teardown_test_env
        return 1
    fi

    # Check for typing import
    assert_file_contains "src/proj_2.py" "from typing import" || {
        teardown_test_env
        return 1
    }

    # Look for actual type hint syntax (-> bool, -> Dict, etc) not in docstrings
    if ! grep -qE '^\s*def\s+\w+\([^)]*\)\s*->\s*(bool|Dict|Any)' "src/proj_2.py" 2>/dev/null; then
        echo "FAIL: File src/proj_2.py does not contain proper type hints"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: Python has type hints"
}

test_python_has_docstrings() {
    setup_test_env
    setup_python_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    assert_file_contains "src/proj_2.py" '"""' || {
        teardown_test_env
        return 1
    }

    assert_file_contains "src/proj_2.py" "Args:" || {
        teardown_test_env
        return 1
    }

    assert_file_contains "src/proj_2.py" "Returns:" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: Python has docstrings"
}

test_python_has_real_validation_logic() {
    setup_test_env
    setup_python_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    # Verify NOT a stub - check for bare "return True" or "return False"
    if grep -qE '^\s*return (True|False)\s*$' "src/proj_2.py"; then
        echo "FAIL: Found stub code (bare return True/False)"
        teardown_test_env
        return 1
    fi

    # Check for actual isinstance type checking
    if ! grep -q "isinstance(" "src/proj_2.py"; then
        echo "FAIL: Missing isinstance() type checking logic"
        teardown_test_env
        return 1
    fi

    # Check for None checking
    if ! grep -qE 'is (None|not None)' "src/proj_2.py"; then
        echo "FAIL: Missing None checking logic"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: Python has real validation logic (not stub)"
}

test_python_syntax_is_valid() {
    setup_test_env
    setup_python_project

    run_pipeline requirements "Test" >/dev/null
    run_pipeline gherkin >/dev/null
    run_pipeline stories >/dev/null
    run_pipeline work "PROJ-2" >/dev/null 2>&1

    if command -v python3 &>/dev/null; then
        if ! python3 -m py_compile src/proj_2.py 2>/dev/null; then
            echo "FAIL: Python syntax is invalid"
            teardown_test_env
            return 1
        fi
    else
        echo "SKIP: python3 not installed, cannot validate syntax"
        teardown_test_env
        return 0
    fi

    teardown_test_env
    echo "PASS: Python syntax is valid"
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0

    echo "========================================="
    echo "Running Work Stage Python Tests"
    echo "========================================="
    echo ""

    if test_work_generates_python_test_file; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_work_generates_python_implementation; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_python_implementation_has_validate_function; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_python_implementation_has_implement_function; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_python_has_type_hints; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_python_has_docstrings; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_python_has_real_validation_logic; then
        ((passed++))
    else
        ((failed++))
    fi

    if test_python_syntax_is_valid; then
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
