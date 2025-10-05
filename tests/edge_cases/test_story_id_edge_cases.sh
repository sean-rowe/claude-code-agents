#!/bin/bash
# Edge case tests for story ID validation
# Tests special characters, length limits, injection attempts
# Part of Task 1.3 - Mutation Testing & Edge Cases

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

# ============================================================================
# TEST: Special Characters in Story IDs
# ============================================================================

test_story_id_with_semicolon() {
    setup_test_env

    # Attempt to use semicolon (command injection attempt)
    local malicious_id="STORY-1;rm -rf /"

    # Should be rejected by validation
    if bash "$PROJECT_ROOT/pipeline.sh" work "$malicious_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "PASS: Semicolon in story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Semicolon in story ID should be rejected"
        return 1
    fi
}

test_story_id_with_pipe() {
    setup_test_env

    # Attempt to use pipe (command chaining)
    local malicious_id="STORY-1|cat /etc/passwd"

    if bash "$PROJECT_ROOT/pipeline.sh" work "$malicious_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "PASS: Pipe in story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Pipe in story ID should be rejected"
        return 1
    fi
}

test_story_id_with_backticks() {
    setup_test_env

    # Attempt command substitution
    local malicious_id="STORY-\`whoami\`"

    if bash "$PROJECT_ROOT/pipeline.sh" work "$malicious_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "PASS: Backticks in story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Backticks in story ID should be rejected"
        return 1
    fi
}

test_story_id_with_dollar_sign() {
    setup_test_env

    # Attempt variable expansion
    local malicious_id="STORY-\$USER"

    if bash "$PROJECT_ROOT/pipeline.sh" work "$malicious_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "PASS: Dollar sign in story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Dollar sign in story ID should be rejected"
        return 1
    fi
}

test_story_id_with_path_traversal() {
    setup_test_env

    # Attempt path traversal
    local malicious_id="../../../etc/passwd"

    if bash "$PROJECT_ROOT/pipeline.sh" work "$malicious_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "PASS: Path traversal in story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Path traversal in story ID should be rejected"
        return 1
    fi
}

test_story_id_with_spaces() {
    setup_test_env

    # Spaces should be rejected
    local invalid_id="STORY 123"

    if bash "$PROJECT_ROOT/pipeline.sh" work "$invalid_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "PASS: Spaces in story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Spaces in story ID should be rejected"
        return 1
    fi
}

# ============================================================================
# TEST: Length Limits
# ============================================================================

test_story_id_very_long() {
    setup_test_env

    # Create a 100-character story ID (exceeds 64 char limit)
    local very_long_id=$(printf 'A%.0s' {1..100})

    if bash "$PROJECT_ROOT/pipeline.sh" work "$very_long_id" 2>&1 | grep -q "Invalid.*story\|too long"; then
        teardown_test_env
        echo "PASS: Very long story ID rejected (100 chars)"
        return 0
    else
        teardown_test_env
        echo "FAIL: Very long story ID should be rejected"
        return 1
    fi
}

test_story_id_empty() {
    setup_test_env

    # Empty string should be rejected
    if bash "$PROJECT_ROOT/pipeline.sh" work "" 2>&1 | grep -q "Invalid.*story\|required"; then
        teardown_test_env
        echo "PASS: Empty story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Empty story ID should be rejected"
        return 1
    fi
}

test_story_id_only_whitespace() {
    setup_test_env

    # Only whitespace should be rejected
    if bash "$PROJECT_ROOT/pipeline.sh" work "   " 2>&1 | grep -q "Invalid.*story\|required"; then
        teardown_test_env
        echo "PASS: Whitespace-only story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Whitespace-only story ID should be rejected"
        return 1
    fi
}

# ============================================================================
# TEST: Valid Edge Cases (should pass)
# ============================================================================

test_story_id_with_hyphens() {
    setup_test_env

    # Hyphens should be allowed
    local valid_id="STORY-123-456"

    # This should NOT be rejected (hyphens are valid)
    if bash "$PROJECT_ROOT/pipeline.sh" work "$valid_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "FAIL: Hyphens in story ID should be allowed"
        return 1
    else
        # Valid IDs will fail for other reasons (no JIRA setup), but not validation
        teardown_test_env
        echo "PASS: Hyphens in story ID allowed"
        return 0
    fi
}

test_story_id_with_underscores() {
    setup_test_env

    # Underscores should be allowed
    local valid_id="STORY_123"

    if bash "$PROJECT_ROOT/pipeline.sh" work "$valid_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "FAIL: Underscores in story ID should be allowed"
        return 1
    else
        teardown_test_env
        echo "PASS: Underscores in story ID allowed"
        return 0
    fi
}

test_story_id_mixed_case() {
    setup_test_env

    # Mixed case should be allowed
    local valid_id="StOrY-123"

    if bash "$PROJECT_ROOT/pipeline.sh" work "$valid_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "FAIL: Mixed case in story ID should be allowed"
        return 1
    else
        teardown_test_env
        echo "PASS: Mixed case in story ID allowed"
        return 0
    fi
}

test_story_id_numbers_only() {
    setup_test_env

    # Numbers only should be allowed
    local valid_id="12345"

    if bash "$PROJECT_ROOT/pipeline.sh" work "$valid_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "FAIL: Numbers-only story ID should be allowed"
        return 1
    else
        teardown_test_env
        echo "PASS: Numbers-only story ID allowed"
        return 0
    fi
}

test_story_id_max_length() {
    setup_test_env

    # Exactly 64 characters (at the limit)
    local max_length_id=$(printf 'A%.0s' {1..64})

    if bash "$PROJECT_ROOT/pipeline.sh" work "$max_length_id" 2>&1 | grep -q "Invalid.*story\|too long"; then
        teardown_test_env
        echo "FAIL: 64-character story ID should be allowed (at limit)"
        return 1
    else
        teardown_test_env
        echo "PASS: 64-character story ID allowed (at limit)"
        return 0
    fi
}

# ============================================================================
# TEST: Unicode and Special Encodings
# ============================================================================

test_story_id_with_unicode() {
    setup_test_env

    # Unicode characters should be rejected (only ASCII alphanumeric allowed)
    local unicode_id="STORY-123-café"

    if bash "$PROJECT_ROOT/pipeline.sh" work "$unicode_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "PASS: Unicode in story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Unicode in story ID should be rejected"
        return 1
    fi
}

test_story_id_with_newline() {
    setup_test_env

    # Newline character (injection attempt)
    local malicious_id=$'STORY-123\nrm -rf /'

    if bash "$PROJECT_ROOT/pipeline.sh" work "$malicious_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "PASS: Newline in story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Newline in story ID should be rejected"
        return 1
    fi
}

test_story_id_with_null_byte() {
    setup_test_env

    # Null byte (can cause issues in C-based tools)
    local malicious_id=$'STORY-123\x00rm'

    if bash "$PROJECT_ROOT/pipeline.sh" work "$malicious_id" 2>&1 | grep -q "Invalid.*story"; then
        teardown_test_env
        echo "PASS: Null byte in story ID rejected"
        return 0
    else
        teardown_test_env
        echo "FAIL: Null byte in story ID should be rejected"
        return 1
    fi
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "╔════════════════════════════════════════════════════════╗"
echo "║        Edge Case Tests: Story ID Validation           ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "=== INJECTION ATTEMPTS (should all be rejected) ==="
test_story_id_with_semicolon
test_story_id_with_pipe
test_story_id_with_backticks
test_story_id_with_dollar_sign
test_story_id_with_path_traversal
test_story_id_with_spaces

echo ""
echo "=== LENGTH LIMITS ==="
test_story_id_very_long
test_story_id_empty
test_story_id_only_whitespace

echo ""
echo "=== VALID EDGE CASES (should be accepted) ==="
test_story_id_with_hyphens
test_story_id_with_underscores
test_story_id_mixed_case
test_story_id_numbers_only
test_story_id_max_length

echo ""
echo "=== SPECIAL ENCODINGS (should be rejected) ==="
test_story_id_with_unicode
test_story_id_with_newline
test_story_id_with_null_byte

echo ""
echo "✓ ALL STORY ID EDGE CASE TESTS COMPLETED"
