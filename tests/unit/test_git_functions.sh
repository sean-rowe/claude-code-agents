#!/bin/bash
# Unit tests for git-related functions in pipeline.sh
# Tests: get_default_branch()

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

PIPELINE="$PROJECT_ROOT/pipeline.sh"

echo "========================================="
echo "Running Git Functions Unit Tests"
echo "========================================="
echo ""

# Setup test environment and source pipeline functions
setup_git_test_env() {
    setup_test_env

    # Source the pipeline to get access to functions
    # We need to set required variables first to avoid errors
    export VERBOSE=0
    export DEBUG=0
    export DRY_RUN=0
    export MAX_RETRIES=3
    export RETRY_DELAY=1
    export OPERATION_TIMEOUT=30

    # Source just the functions we need
    # Extract and create a minimal version with just the function
    cat > test_git_funcs.sh <<'EOF'
#!/bin/bash

# Logging stubs
log_error() { echo "[ERROR] $1" >&2; }
log_warn() { echo "[WARN] $1" >&2; }
log_debug() { :; }
log_info() { :; }

EOF

    # Extract the get_default_branch function from pipeline.sh
    sed -n '/^get_default_branch() {$/,/^}$/p' "$PIPELINE" >> test_git_funcs.sh

    source test_git_funcs.sh
}

#==============================================================================
# TESTS FOR get_default_branch() - DEFAULT BRANCH DETECTION
#==============================================================================

# Test 1: get_default_branch with GIT_MAIN_BRANCH override
test_get_default_branch_with_env_override() {
    setup_git_test_env

    # Set GIT_MAIN_BRANCH environment variable
    export GIT_MAIN_BRANCH="develop"

    # Call function directly
    result=$(get_default_branch 2>/dev/null)

    # Verify it returns the override
    if [ "$result" = "develop" ]; then
        echo "PASS: get_default_branch respects GIT_MAIN_BRANCH override"
        teardown_test_env
        unset GIT_MAIN_BRANCH
        return 0
    else
        echo "FAIL: Expected 'develop', got '$result'"
        teardown_test_env
        unset GIT_MAIN_BRANCH
        return 1
    fi
}

# Test 2: get_default_branch with main branch
test_get_default_branch_with_main() {
    setup_git_test_env

    # Initialize git repo with main branch
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git checkout -b main 2>/dev/null || true
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Call function directly
    result=$(get_default_branch 2>/dev/null)

    # Verify it detects main
    if [ "$result" = "main" ]; then
        echo "PASS: get_default_branch detects 'main' branch"
        teardown_test_env
        return 0
    else
        echo "FAIL: Expected 'main', got '$result'"
        teardown_test_env
        return 1
    fi
}

# Test 3: get_default_branch with master branch
test_get_default_branch_with_master() {
    setup_git_test_env

    # Initialize git repo with ONLY master branch (no main)
    git init -q --initial-branch=master 2>/dev/null || {
        git init -q
        git symbolic-ref HEAD refs/heads/master
    }
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Call function directly
    result=$(get_default_branch 2>/dev/null)

    # Verify it detects master
    if [ "$result" = "master" ]; then
        echo "PASS: get_default_branch detects 'master' branch"
        teardown_test_env
        return 0
    else
        echo "FAIL: Expected 'master', got '$result'"
        teardown_test_env
        return 1
    fi
}

# Test 4: get_default_branch with develop branch
test_get_default_branch_with_develop() {
    setup_git_test_env

    # Initialize git repo with ONLY develop branch
    git init -q --initial-branch=develop 2>/dev/null || {
        git init -q
        git symbolic-ref HEAD refs/heads/develop
    }
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Call function directly
    result=$(get_default_branch 2>/dev/null)

    # Verify it detects develop
    if [ "$result" = "develop" ]; then
        echo "PASS: get_default_branch detects 'develop' branch"
        teardown_test_env
        return 0
    else
        echo "FAIL: Expected 'develop', got '$result'"
        teardown_test_env
        return 1
    fi
}

# Test 5: get_default_branch in non-git directory
test_get_default_branch_in_non_git_dir() {
    setup_git_test_env

    # Don't initialize git - just test in regular directory

    # Call function directly
    result=$(get_default_branch 2>/dev/null)

    # Verify it falls back to 'main'
    if [ "$result" = "main" ]; then
        echo "PASS: get_default_branch defaults to 'main' in non-git directory"
        teardown_test_env
        return 0
    else
        echo "FAIL: Expected 'main' fallback, got '$result'"
        teardown_test_env
        return 1
    fi
}

# Test 6: get_default_branch with remote HEAD set
test_get_default_branch_with_remote_head() {
    setup_git_test_env

    # Initialize git repo
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git checkout -b main 2>/dev/null || true
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Create a bare repo to simulate remote
    mkdir -p remote.git
    cd remote.git
    git init -q --bare
    cd ..

    # Add remote and push
    git remote add origin remote.git
    git push -q origin main 2>/dev/null || true

    # Set remote HEAD
    git remote set-head origin main 2>/dev/null || true

    # Call function directly
    result=$(get_default_branch 2>/dev/null)

    # Verify it detects main from remote HEAD
    if [ "$result" = "main" ]; then
        echo "PASS: get_default_branch detects branch from remote HEAD"
        teardown_test_env
        return 0
    else
        echo "FAIL: Expected 'main' from remote HEAD, got '$result'"
        teardown_test_env
        return 1
    fi
}

# Test 7: get_default_branch fallback to current branch
test_get_default_branch_fallback_to_current() {
    setup_git_test_env

    # Initialize git repo with non-standard branch name ONLY
    git init -q --initial-branch=feature-xyz 2>/dev/null || {
        git init -q
        git symbolic-ref HEAD refs/heads/feature-xyz
    }
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Call function directly
    result=$(get_default_branch 2>/dev/null)

    # Verify it falls back to current branch
    if [ "$result" = "feature-xyz" ]; then
        echo "PASS: get_default_branch falls back to current branch"
        teardown_test_env
        return 0
    else
        echo "FAIL: Expected 'feature-xyz', got '$result'"
        teardown_test_env
        return 1
    fi
}

# Test 8: get_default_branch prefers main over other branches
test_get_default_branch_prefers_main() {
    setup_git_test_env

    # Initialize git repo with multiple branches
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Create develop branch first
    git checkout -b develop 2>/dev/null || true
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Create main branch
    git checkout -b main 2>/dev/null || true

    # Call function directly
    result=$(get_default_branch 2>/dev/null)

    # Verify it prefers main over develop
    if [ "$result" = "main" ]; then
        echo "PASS: get_default_branch prefers 'main' when multiple branches exist"
        teardown_test_env
        return 0
    else
        echo "FAIL: Expected 'main' to be preferred, got '$result'"
        teardown_test_env
        return 1
    fi
}

#==============================================================================
# RUN ALL TESTS
#==============================================================================

echo "Running get_default_branch() tests..."
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

run_test test_get_default_branch_with_env_override
run_test test_get_default_branch_with_main
run_test test_get_default_branch_with_master
run_test test_get_default_branch_with_develop
run_test test_get_default_branch_in_non_git_dir
run_test test_get_default_branch_with_remote_head
run_test test_get_default_branch_fallback_to_current
run_test test_get_default_branch_prefers_main

echo "========================================="
echo "Git Functions Test Results"
echo "========================================="
echo "Total tests: $test_count"
echo "Passed: $pass_count"
echo "Failed: $fail_count"
echo ""

if [ $fail_count -eq 0 ]; then
    echo "✓ All git function tests passed!"
    exit 0
else
    echo "✗ Some git function tests failed"
    exit 1
fi
