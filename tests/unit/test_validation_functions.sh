#!/bin/bash
# Unit tests for validation functions in pipeline.sh
# Tests: validate_story_id, sanitize_input, validate_safe_path, validate_json, validate_json_schema
# These are SECURITY-CRITICAL functions that prevent injection attacks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

PIPELINE="$PROJECT_ROOT/pipeline.sh"

echo "========================================="
echo "Running Validation Functions Unit Tests"
echo "========================================="
echo ""

# Extract validation functions from pipeline.sh
setup_validation_test_env() {
    setup_test_env

    # Source pipeline.sh functions
    # Extract only what we need
    cat > test_validation.sh <<'EOF'
#!/bin/bash
set -euo pipefail

# Error codes
readonly E_SUCCESS=0
readonly E_INVALID_ARGS=2

# Minimal logging for tests
log_error() { echo "[ERROR] $1" >&2; }
log_debug() { :; }

# Import validation functions from pipeline.sh
EOF

    # Extract validate_story_id function
    sed -n '/^validate_story_id()/,/^}/p' "$PIPELINE" >> test_validation.sh

    # Extract sanitize_input function
    sed -n '/^sanitize_input()/,/^}/p' "$PIPELINE" >> test_validation.sh

    # Extract validate_safe_path function
    sed -n '/^validate_safe_path()/,/^}/p' "$PIPELINE" >> test_validation.sh

    # Extract validate_json function
    sed -n '/^validate_json()/,/^}/p' "$PIPELINE" >> test_validation.sh

    # Extract validate_json_schema function
    sed -n '/^validate_json_schema()/,/^}/p' "$PIPELINE" >> test_validation.sh

    # Add main function dispatcher
    cat >> test_validation.sh <<'EOF'

# Allow calling functions from command line
"$@"
EOF
    chmod +x test_validation.sh
}

#==============================================================================
# TESTS FOR validate_story_id() - SECURITY CRITICAL
#==============================================================================

# Test 1: Valid story ID passes validation
test_validate_story_id_valid() {
    setup_validation_test_env

    # Valid story IDs
    if bash test_validation.sh validate_story_id "PROJ-123" 2>/dev/null; then
        :
    else
        echo "FAIL: Valid story ID PROJ-123 rejected"
        teardown_test_env
        return 1
    fi

    if bash test_validation.sh validate_story_id "ABC-999" 2>/dev/null; then
        :
    else
        echo "FAIL: Valid story ID ABC-999 rejected"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_story_id accepts valid story IDs"
    return 0
}

# Test 2: Empty story ID is rejected
test_validate_story_id_empty() {
    setup_validation_test_env

    if bash test_validation.sh validate_story_id "" 2>/dev/null; then
        echo "FAIL: Empty story ID was accepted"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_story_id rejects empty story ID"
    return 0
}

# Test 3: Story ID too long is rejected (DoS prevention)
test_validate_story_id_too_long() {
    setup_validation_test_env

    # Create 100 character story ID (max is 64)
    long_id=$(printf 'A%.0s' {1..100})

    if bash test_validation.sh validate_story_id "$long_id" 2>/dev/null; then
        echo "FAIL: Very long story ID was accepted (DoS risk)"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_story_id rejects story IDs >64 characters"
    return 0
}

# Test 4: Story ID with invalid format is rejected
test_validate_story_id_invalid_format() {
    setup_validation_test_env

    # Missing hyphen
    if bash test_validation.sh validate_story_id "PROJ123" 2>/dev/null; then
        echo "FAIL: Story ID without hyphen was accepted"
        teardown_test_env
        return 1
    fi

    # Missing number
    if bash test_validation.sh validate_story_id "PROJ-" 2>/dev/null; then
        echo "FAIL: Story ID without number was accepted"
        teardown_test_env
        return 1
    fi

    # Doesn't end with numbers
    if bash test_validation.sh validate_story_id "PROJ-ABC" 2>/dev/null; then
        echo "FAIL: Story ID not ending with numbers was accepted"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_story_id rejects invalid formats"
    return 0
}

# Test 5: Path traversal attack is blocked (SECURITY CRITICAL)
test_validate_story_id_path_traversal() {
    setup_validation_test_env

    # Attempt path traversal with ..
    if bash test_validation.sh validate_story_id "PROJ-123/../etc/passwd" 2>/dev/null; then
        echo "FAIL: Path traversal attack with .. was accepted"
        teardown_test_env
        return 1
    fi

    # Attempt absolute path
    if bash test_validation.sh validate_story_id "/etc/passwd" 2>/dev/null; then
        echo "FAIL: Absolute path was accepted"
        teardown_test_env
        return 1
    fi

    # Attempt with forward slash
    if bash test_validation.sh validate_story_id "PROJ/123" 2>/dev/null; then
        echo "FAIL: Story ID with / was accepted"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_story_id blocks path traversal attacks"
    return 0
}

# Test 6: Command injection attempt is blocked (SECURITY CRITICAL)
test_validate_story_id_command_injection() {
    setup_validation_test_env

    # Attempt command injection with semicolon
    if bash test_validation.sh validate_story_id "PROJ-123; rm -rf /" 2>/dev/null; then
        echo "FAIL: Command injection with ; was accepted"
        teardown_test_env
        return 1
    fi

    # Attempt with backticks
    if bash test_validation.sh validate_story_id "PROJ-\`whoami\`" 2>/dev/null; then
        echo "FAIL: Command injection with backticks was accepted"
        teardown_test_env
        return 1
    fi

    # Attempt with $()
    if bash test_validation.sh validate_story_id "PROJ-\$(whoami)" 2>/dev/null; then
        echo "FAIL: Command injection with \$() was accepted"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_story_id blocks command injection"
    return 0
}

# Test 7: Special characters are rejected
test_validate_story_id_special_chars() {
    setup_validation_test_env

    # Test various special characters
    for char in '&' '|' '<' '>' '*' '?' '!' '@' '#' '$' '%' '^' '(' ')'; do
        if bash test_validation.sh validate_story_id "PROJ${char}123" 2>/dev/null; then
            echo "FAIL: Story ID with special character '$char' was accepted"
            teardown_test_env
            return 1
        fi
    done

    teardown_test_env
    echo "PASS: validate_story_id rejects special characters"
    return 0
}

#==============================================================================
# TESTS FOR validate_safe_path() - SECURITY CRITICAL
#==============================================================================

# Test 8: Valid relative path is accepted
test_validate_safe_path_valid() {
    setup_validation_test_env

    # Create actual directory structure
    mkdir -p src/components
    touch src/components/module.js

    if bash test_validation.sh validate_safe_path "src/components/module.js" 2>/dev/null; then
        :
    else
        echo "FAIL: Valid relative path was rejected"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_safe_path accepts valid relative paths"
    return 0
}

# Test 9: Path traversal with .. is blocked
test_validate_safe_path_traversal() {
    setup_validation_test_env

    if bash test_validation.sh validate_safe_path "../etc/passwd" 2>/dev/null; then
        echo "FAIL: Path traversal with .. was accepted"
        teardown_test_env
        return 1
    fi

    if bash test_validation.sh validate_safe_path "src/../../etc/passwd" 2>/dev/null; then
        echo "FAIL: Path traversal in middle was accepted"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_safe_path blocks path traversal"
    return 0
}

# Test 10: Absolute paths are blocked
test_validate_safe_path_absolute() {
    setup_validation_test_env

    if bash test_validation.sh validate_safe_path "/etc/passwd" 2>/dev/null; then
        echo "FAIL: Absolute path /etc/passwd was accepted"
        teardown_test_env
        return 1
    fi

    if bash test_validation.sh validate_safe_path "/tmp/evil.sh" 2>/dev/null; then
        echo "FAIL: Absolute path /tmp/evil.sh was accepted"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_safe_path blocks absolute paths"
    return 0
}

#==============================================================================
# TESTS FOR validate_json() - DATA INTEGRITY
#==============================================================================

# Test 11: Valid JSON is accepted
test_validate_json_valid() {
    setup_validation_test_env

    # Create valid JSON file
    echo '{"key": "value", "number": 123}' > test.json

    if bash test_validation.sh validate_json "test.json" 2>/dev/null; then
        :
    else
        echo "FAIL: Valid JSON was rejected"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_json accepts valid JSON"
    return 0
}

# Test 12: Invalid JSON is rejected
test_validate_json_invalid() {
    setup_validation_test_env

    # Create invalid JSON file (missing closing brace)
    echo '{"key": "value"' > test.json

    if bash test_validation.sh validate_json "test.json" 2>/dev/null; then
        echo "FAIL: Invalid JSON was accepted"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_json rejects invalid JSON"
    return 0
}

# Test 13: Missing file is rejected
test_validate_json_missing_file() {
    setup_validation_test_env

    if bash test_validation.sh validate_json "nonexistent.json" 2>/dev/null; then
        echo "FAIL: Missing file was accepted"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: validate_json rejects missing files"
    return 0
}

#==============================================================================
# TESTS FOR sanitize_input() - INJECTION PREVENTION
#==============================================================================

# Test 14: sanitize_input removes dangerous characters
test_sanitize_input() {
    setup_validation_test_env

    # Test with dangerous characters
    output=$(bash test_validation.sh sanitize_input "test\$()value" 2>/dev/null || echo "")

    # Should not contain $()
    if echo "$output" | grep -q '\$()'; then
        echo "FAIL: sanitize_input did not remove \$()"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: sanitize_input removes dangerous characters"
    return 0
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0

    # validate_story_id tests
    if test_validate_story_id_valid; then ((passed++)); else ((failed++)); fi
    if test_validate_story_id_empty; then ((passed++)); else ((failed++)); fi
    if test_validate_story_id_too_long; then ((passed++)); else ((failed++)); fi
    if test_validate_story_id_invalid_format; then ((passed++)); else ((failed++)); fi
    if test_validate_story_id_path_traversal; then ((passed++)); else ((failed++)); fi
    if test_validate_story_id_command_injection; then ((passed++)); else ((failed++)); fi
    if test_validate_story_id_special_chars; then ((passed++)); else ((failed++)); fi

    # validate_safe_path tests
    if test_validate_safe_path_valid; then ((passed++)); else ((failed++)); fi
    if test_validate_safe_path_traversal; then ((passed++)); else ((failed++)); fi
    if test_validate_safe_path_absolute; then ((passed++)); else ((failed++)); fi

    # validate_json tests
    if test_validate_json_valid; then ((passed++)); else ((failed++)); fi
    if test_validate_json_invalid; then ((passed++)); else ((failed++)); fi
    if test_validate_json_missing_file; then ((passed++)); else ((failed++)); fi

    # sanitize_input tests
    if test_sanitize_input; then ((passed++)); else ((failed++)); fi

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
