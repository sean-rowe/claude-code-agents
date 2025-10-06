#!/bin/bash
# Integration tests for branch detection in work stage
# Tests the integration between get_default_branch() and the work stage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

PIPELINE="$PROJECT_ROOT/pipeline.sh"

echo "========================================="
echo "Running Branch Detection Integration Tests"
echo "========================================="
echo ""

#==============================================================================
# INTEGRATION TESTS FOR WORK STAGE BRANCH DETECTION
#==============================================================================

# Test 1: Work stage creates feature branch from detected main
test_work_stage_uses_main_branch() {
    setup_test_env

    # Initialize git repo with main branch
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git checkout -b main 2>/dev/null || true
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Create package.json for JavaScript detection
    echo '{"name":"test"}' > package.json

    # Initialize pipeline state
    mkdir -p .pipeline
    cat > .pipeline/state.json <<EOF
{
  "stage": "stories",
  "projectKey": "TEST",
  "stories": {
    "TEST-1": {
      "title": "Test story",
      "status": "todo"
    }
  },
  "version": "1.0.0"
}
EOF

    # Run work stage
    bash "$PIPELINE" work TEST-1 2>/dev/null || true

    # Verify feature branch was created
    if git show-ref --verify --quiet refs/heads/feature/TEST-1; then
        # Verify it was based on main
        base_commit=$(git rev-parse main)
        feature_commit=$(git rev-parse feature/TEST-1^)  # Parent of first commit on feature

        if [ "$base_commit" = "$feature_commit" ]; then
            echo "PASS: Work stage creates feature branch from detected main branch"
            teardown_test_env
            return 0
        else
            echo "FAIL: Feature branch not based on main"
            teardown_test_env
            return 1
        fi
    else
        echo "FAIL: Feature branch not created"
        teardown_test_env
        return 1
    fi
}

# Test 2: Work stage respects GIT_MAIN_BRANCH override
test_work_stage_respects_git_main_branch_override() {
    setup_test_env

    # Initialize git repo with develop branch
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git checkout -b develop 2>/dev/null || true
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Set override
    export GIT_MAIN_BRANCH=develop

    # Create package.json
    echo '{"name":"test"}' > package.json

    # Initialize pipeline state
    mkdir -p .pipeline
    cat > .pipeline/state.json <<EOF
{
  "stage": "stories",
  "projectKey": "TEST",
  "stories": {
    "TEST-2": {
      "title": "Test story",
      "status": "todo"
    }
  },
  "version": "1.0.0"
}
EOF

    # Run work stage
    bash "$PIPELINE" work TEST-2 2>/dev/null || true

    # Verify feature branch was created
    if git show-ref --verify --quiet refs/heads/feature/TEST-2; then
        echo "PASS: Work stage respects GIT_MAIN_BRANCH override"
        teardown_test_env
        unset GIT_MAIN_BRANCH
        return 0
    else
        echo "FAIL: Feature branch not created with override"
        teardown_test_env
        unset GIT_MAIN_BRANCH
        return 1
    fi
}

# Test 3: Work stage handles checkout failure gracefully
test_work_stage_fallback_on_checkout_failure() {
    setup_test_env

    # Initialize git repo on a feature branch
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git checkout -b some-feature 2>/dev/null || true
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Create package.json
    echo '{"name":"test"}' > package.json

    # Initialize pipeline state
    mkdir -p .pipeline
    cat > .pipeline/state.json <<EOF
{
  "stage": "stories",
  "projectKey": "TEST",
  "stories": {
    "TEST-3": {
      "title": "Test story",
      "status": "todo"
    }
  },
  "version": "1.0.0"
}
EOF

    # Run work stage (should use current branch as fallback)
    bash "$PIPELINE" work TEST-3 2>/dev/null || true

    # Verify feature branch was created despite no main/master/develop
    if git show-ref --verify --quiet refs/heads/feature/TEST-3; then
        echo "PASS: Work stage creates feature branch with fallback"
        teardown_test_env
        return 0
    else
        echo "FAIL: Feature branch not created with fallback"
        teardown_test_env
        return 1
    fi
}

# Test 4: Work stage with .pipelinerc config
test_work_stage_with_config_file() {
    setup_test_env

    # Initialize git repo
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git checkout -b develop 2>/dev/null || true
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Create .pipelinerc with override
    cat > .pipelinerc <<'EOF'
GIT_MAIN_BRANCH=develop
VERBOSE=1
EOF

    # Create package.json
    echo '{"name":"test"}' > package.json

    # Initialize pipeline state
    mkdir -p .pipeline
    cat > .pipeline/state.json <<EOF
{
  "stage": "stories",
  "projectKey": "TEST",
  "stories": {
    "TEST-4": {
      "title": "Test story",
      "status": "todo"
    }
  },
  "version": "1.0.0"
}
EOF

    # Run work stage
    bash "$PIPELINE" work TEST-4 2>/dev/null || true

    # Verify feature branch created from develop
    if git show-ref --verify --quiet refs/heads/feature/TEST-4; then
        echo "PASS: Work stage uses config from .pipelinerc"
        teardown_test_env
        return 0
    else
        echo "FAIL: Config file not respected"
        teardown_test_env
        return 1
    fi
}

# Test 5: Work stage preserves branch in state
test_work_stage_saves_branch_to_state() {
    setup_test_env

    # Initialize git repo
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git checkout -b main 2>/dev/null || true
    echo "test" > test.txt
    git add test.txt
    git commit -q -m "Initial commit"

    # Create package.json
    echo '{"name":"test"}' > package.json

    # Initialize pipeline state
    mkdir -p .pipeline
    cat > .pipeline/state.json <<EOF
{
  "stage": "stories",
  "projectKey": "TEST",
  "stories": {
    "TEST-5": {
      "title": "Test story",
      "status": "todo"
    }
  },
  "version": "1.0.0"
}
EOF

    # Run work stage
    bash "$PIPELINE" work TEST-5 2>/dev/null || true

    # Verify branch saved in state
    if command -v jq &>/dev/null; then
        branch=$(jq -r '.branch' .pipeline/state.json 2>/dev/null)
        if [ "$branch" = "feature/TEST-5" ]; then
            echo "PASS: Work stage saves branch name to state"
            teardown_test_env
            return 0
        else
            echo "FAIL: Branch not saved to state (got: $branch)"
            teardown_test_env
            return 1
        fi
    else
        echo "SKIP: jq not available"
        teardown_test_env
        return 0
    fi
}

#==============================================================================
# RUN ALL TESTS
#==============================================================================

echo "Running branch detection integration tests..."
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

run_test test_work_stage_uses_main_branch
run_test test_work_stage_respects_git_main_branch_override
run_test test_work_stage_fallback_on_checkout_failure
run_test test_work_stage_with_config_file
run_test test_work_stage_saves_branch_to_state

echo "========================================="
echo "Branch Detection Integration Test Results"
echo "========================================="
echo "Total tests: $test_count"
echo "Passed: $pass_count"
echo "Failed: $fail_count"
echo ""

if [ $fail_count -eq 0 ]; then
    echo "✓ All branch detection integration tests passed!"
    exit 0
else
    echo "✗ Some branch detection integration tests failed"
    exit 1
fi
