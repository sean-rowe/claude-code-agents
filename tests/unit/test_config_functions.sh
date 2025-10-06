#!/bin/bash
# Unit tests for configuration loading functions in pipeline.sh
# Tests: load_config()

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

PIPELINE="$PROJECT_ROOT/pipeline.sh"

echo "========================================="
echo "Running Config Functions Unit Tests"
echo "========================================="
echo ""

# Extract load_config function
setup_config_test_env() {
    setup_test_env

    # Create test script with config functions
    cat > test_config_functions.sh <<'EOF'
#!/bin/bash
set -euo pipefail

# Logging stubs
log_error() { echo "[ERROR] $1" >&2; }
log_warn() { echo "[WARN] $1" >&2; }
log_debug() { echo "[DEBUG] $1" >&2; }
log_info() { echo "[INFO] $1" >&2; }

EOF

    # Extract load_config function
    sed -n '/^load_config()/,/^}/p' "$PIPELINE" >> test_config_functions.sh

    # Add dispatcher
    cat >> test_config_functions.sh <<'EOF'

# Allow calling functions from command line
"$@"
EOF
    chmod +x test_config_functions.sh
}

#==============================================================================
# TESTS FOR load_config() - CONFIGURATION FILE LOADING
#==============================================================================

# Test 1: load_config with valid config file
test_load_config_with_valid_file() {
    setup_config_test_env

    # Create a valid .pipelinerc file
    cat > .pipelinerc <<'EOF'
# Test configuration
VERBOSE=1
MAX_RETRIES=5
JIRA_PROJECT=TEST
EOF

    # Source the test script which will load the function
    source test_config_functions.sh

    # Call load_config
    load_config .pipelinerc

    # Verify variables were set
    if [ "$VERBOSE" = "1" ] && [ "$MAX_RETRIES" = "5" ] && [ "$JIRA_PROJECT" = "TEST" ]; then
        echo "PASS: load_config loads variables from valid config file"
        teardown_test_env
        return 0
    else
        echo "FAIL: Config variables not loaded correctly"
        echo "  VERBOSE=$VERBOSE (expected 1)"
        echo "  MAX_RETRIES=$MAX_RETRIES (expected 5)"
        echo "  JIRA_PROJECT=$JIRA_PROJECT (expected TEST)"
        teardown_test_env
        return 1
    fi
}

# Test 2: load_config with missing config file
test_load_config_with_missing_file() {
    setup_config_test_env

    # Don't create config file

    # Source the test script
    source test_config_functions.sh

    # Call load_config (should not fail)
    if load_config .pipelinerc 2>/dev/null; then
        echo "PASS: load_config handles missing config file gracefully"
        teardown_test_env
        return 0
    else
        echo "FAIL: load_config failed on missing file (should return 0)"
        teardown_test_env
        return 1
    fi
}

# Test 3: load_config with syntax error in config
test_load_config_with_syntax_error() {
    setup_config_test_env

    # Create a config file with syntax error
    cat > .pipelinerc <<'EOF'
VERBOSE=1
INVALID SYNTAX HERE
MAX_RETRIES=5
EOF

    # Source the test script
    source test_config_functions.sh

    # Call load_config (should fail due to syntax error)
    if load_config .pipelinerc 2>/dev/null; then
        echo "FAIL: load_config should fail on syntax error"
        teardown_test_env
        return 1
    else
        echo "PASS: load_config fails on syntax error (expected behavior)"
        teardown_test_env
        return 0
    fi
}

# Test 4: load_config with comments and empty lines
test_load_config_with_comments() {
    setup_config_test_env

    # Create config with comments
    cat > .pipelinerc <<'EOF'
# This is a comment
VERBOSE=1

# Another comment
MAX_RETRIES=3

EOF

    # Source the test script
    source test_config_functions.sh

    # Call load_config
    load_config .pipelinerc

    # Verify variables were set
    if [ "$VERBOSE" = "1" ] && [ "$MAX_RETRIES" = "3" ]; then
        echo "PASS: load_config handles comments and empty lines"
        teardown_test_env
        return 0
    else
        echo "FAIL: Config with comments not parsed correctly"
        teardown_test_env
        return 1
    fi
}

# Test 5: load_config environment variable override
test_load_config_env_override() {
    setup_config_test_env

    # Set environment variable first
    export VERBOSE=0

    # Create config file that tries to override
    cat > .pipelinerc <<'EOF'
VERBOSE=1
EOF

    # Source the test script
    source test_config_functions.sh

    # Call load_config
    load_config .pipelinerc

    # Config file should override (sourcing sets new value)
    if [ "$VERBOSE" = "1" ]; then
        echo "PASS: load_config sets variables (config sourcing works)"
        teardown_test_env
        unset VERBOSE
        return 0
    else
        echo "FAIL: Expected VERBOSE=1 from config file, got $VERBOSE"
        teardown_test_env
        unset VERBOSE
        return 1
    fi
}

# Test 6: load_config with default parameter
test_load_config_with_default_param() {
    setup_config_test_env

    # Create custom config file
    cat > custom.config <<'EOF'
CUSTOM_VAR=42
EOF

    # Source the test script
    source test_config_functions.sh

    # Call load_config with custom filename
    load_config custom.config

    # Verify custom variable was set
    if [ "$CUSTOM_VAR" = "42" ]; then
        echo "PASS: load_config accepts custom config filename"
        teardown_test_env
        return 0
    else
        echo "FAIL: Custom config not loaded"
        teardown_test_env
        return 1
    fi
}

# Test 7: load_config with absolute path
test_load_config_with_absolute_path() {
    setup_config_test_env

    # Create config in temp location
    config_path="$TEST_DIR/absolute.config"
    cat > "$config_path" <<'EOF'
ABSOLUTE_TEST=yes
EOF

    # Source the test script
    source test_config_functions.sh

    # Call load_config with absolute path
    load_config "$config_path"

    # Verify variable was set
    if [ "$ABSOLUTE_TEST" = "yes" ]; then
        echo "PASS: load_config works with absolute paths"
        teardown_test_env
        return 0
    else
        echo "FAIL: Config with absolute path not loaded"
        teardown_test_env
        return 1
    fi
}

# Test 8: load_config with export statements
test_load_config_with_exports() {
    setup_config_test_env

    # Create config with export statements
    cat > .pipelinerc <<'EOF'
export EXPORTED_VAR=1
NORMAL_VAR=2
EOF

    # Source the test script
    source test_config_functions.sh

    # Call load_config
    load_config .pipelinerc

    # Verify both types of variables work
    if [ "$EXPORTED_VAR" = "1" ] && [ "$NORMAL_VAR" = "2" ]; then
        echo "PASS: load_config handles export statements"
        teardown_test_env
        return 0
    else
        echo "FAIL: Export statements not handled correctly"
        teardown_test_env
        return 1
    fi
}

# Test 9: load_config doesn't leak between calls
test_load_config_isolation() {
    setup_config_test_env

    # First config
    cat > config1.rc <<'EOF'
VAR_A=1
VAR_B=2
EOF

    # Second config (doesn't set VAR_B)
    cat > config2.rc <<'EOF'
VAR_A=3
EOF

    # Source the test script
    source test_config_functions.sh

    # Load first config
    load_config config1.rc
    first_a=$VAR_A
    first_b=$VAR_B

    # Load second config
    load_config config2.rc
    second_a=$VAR_A
    second_b=$VAR_B

    # Verify VAR_A changed but VAR_B persisted
    if [ "$first_a" = "1" ] && [ "$first_b" = "2" ] && [ "$second_a" = "3" ] && [ "$second_b" = "2" ]; then
        echo "PASS: load_config variables persist across calls (expected bash behavior)"
        teardown_test_env
        return 0
    else
        echo "FAIL: Variable persistence not as expected"
        teardown_test_env
        return 1
    fi
}

#==============================================================================
# RUN ALL TESTS
#==============================================================================

echo "Running load_config() tests..."
echo ""

test_count=0
pass_count=0
fail_count=0

run_test() {
    local test_name=$1
    test_count=$((test_count + 1))

    echo "Test $test_count: $test_name"
    if $test_name; then
        pass_count=$((pass_count + 1))
    else
        fail_count=$((fail_count + 1))
    fi
    echo ""
}

run_test test_load_config_with_valid_file
run_test test_load_config_with_missing_file
run_test test_load_config_with_syntax_error
run_test test_load_config_with_comments
run_test test_load_config_env_override
run_test test_load_config_with_default_param
run_test test_load_config_with_absolute_path
run_test test_load_config_with_exports
run_test test_load_config_isolation

echo "========================================="
echo "Config Functions Test Results"
echo "========================================="
echo "Total tests: $test_count"
echo "Passed: $pass_count"
echo "Failed: $fail_count"
echo ""

if [ $fail_count -eq 0 ]; then
    echo "✓ All config function tests passed!"
    exit 0
else
    echo "✗ Some config function tests failed"
    exit 1
fi
