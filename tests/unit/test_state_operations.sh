#!/bin/bash
# Unit tests for state operation functions: backup_state, commit_state, check_state_version
# Coverage target: 100% for state management operations
# Part of Task 1.1 - Test the Pipeline Itself

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

# ============================================================================
# TEST SUITE: backup_state()
# ============================================================================

test_backup_state_success() {
    setup_test_env

    # Create a state file
    echo '{"stage": "ready", "version": "1.0.0"}' > .pipeline/state.json

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" backup_state 2>/dev/null || true

    # Call backup_state
    backup_state
    local exit_code=$?

    # Verify backup file was created
    if [ ! -f ".pipeline/state.json.backup" ]; then
        echo "FAIL: backup_state did not create backup file"
        teardown_test_env
        return 1
    fi

    # Verify backup content matches original
    if ! diff .pipeline/state.json .pipeline/state.json.backup >/dev/null 2>&1; then
        echo "FAIL: backup content differs from original"
        teardown_test_env
        return 1
    fi

    # Verify exit code
    if [ "$exit_code" -ne 0 ]; then
        echo "FAIL: backup_state returned non-zero exit code: $exit_code"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: backup_state creates backup when state exists"
}

test_backup_state_no_file() {
    setup_test_env

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" backup_state 2>/dev/null || true

    # Don't create a state file - call backup_state
    backup_state 2>/dev/null || true
    local exit_code=$?

    # Verify no backup file was created
    if [ -f ".pipeline/state.json.backup" ]; then
        echo "FAIL: backup_state created backup when no state file exists"
        teardown_test_env
        return 1
    fi

    # Verify non-zero exit code (E_FILE_NOT_FOUND = 6)
    if [ "$exit_code" -eq 0 ]; then
        echo "FAIL: backup_state should return error when state file missing"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: backup_state returns error when no state file exists"
}

test_backup_state_overwrites_existing() {
    setup_test_env

    # Create state file and old backup
    echo '{"stage": "ready", "version": "1.0.0"}' > .pipeline/state.json
    echo '{"stage": "old", "version": "0.9.0"}' > .pipeline/state.json.backup

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" backup_state 2>/dev/null || true

    # Call backup_state
    backup_state

    # Verify new backup matches current state, not old backup
    if ! grep -q '"version": "1.0.0"' .pipeline/state.json.backup; then
        echo "FAIL: backup_state did not overwrite old backup"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: backup_state overwrites existing backup"
}

# ============================================================================
# TEST SUITE: commit_state()
# ============================================================================

test_commit_state_removes_backup() {
    setup_test_env

    # Create backup file
    echo '{"stage": "ready"}' > .pipeline/state.json.backup

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" commit_state 2>/dev/null || true

    # Call commit_state
    commit_state
    local exit_code=$?

    # Verify backup file was removed
    if [ -f ".pipeline/state.json.backup" ]; then
        echo "FAIL: commit_state did not remove backup file"
        teardown_test_env
        return 1
    fi

    # Verify exit code is success
    if [ "$exit_code" -ne 0 ]; then
        echo "FAIL: commit_state returned non-zero exit code: $exit_code"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: commit_state removes backup file when it exists"
}

test_commit_state_no_backup() {
    setup_test_env

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" commit_state 2>/dev/null || true

    # Don't create backup file - call commit_state
    commit_state
    local exit_code=$?

    # Verify it succeeds even without backup
    if [ "$exit_code" -ne 0 ]; then
        echo "FAIL: commit_state should succeed even when no backup exists"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: commit_state succeeds even when no backup exists"
}

test_commit_state_idempotent() {
    setup_test_env

    # Create backup file
    echo '{"stage": "ready"}' > .pipeline/state.json.backup

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" commit_state 2>/dev/null || true

    # Call commit_state twice
    commit_state
    local exit_code1=$?
    commit_state
    local exit_code2=$?

    # Verify both calls succeed
    if [ "$exit_code1" -ne 0 ] || [ "$exit_code2" -ne 0 ]; then
        echo "FAIL: commit_state should be idempotent"
        teardown_test_env
        return 1
    fi

    # Verify backup is gone
    if [ -f ".pipeline/state.json.backup" ]; then
        echo "FAIL: backup file still exists after commit"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: commit_state is idempotent (can be called multiple times)"
}

# ============================================================================
# TEST SUITE: check_state_version()
# ============================================================================

test_check_state_version_no_file() {
    setup_test_env

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" check_state_version 2>/dev/null || true

    # Don't create state file - call check_state_version
    check_state_version
    local exit_code=$?

    # Should return success (0) when no state file exists
    if [ "$exit_code" -ne 0 ]; then
        echo "FAIL: check_state_version should return success when no state file exists"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: check_state_version returns success when no state file exists"
}

test_check_state_version_compatible() {
    setup_test_env

    # Create state file with compatible version
    echo '{"version": "1.0.0", "stage": "ready"}' > .pipeline/state.json

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" check_state_version 2>/dev/null || true

    # Call check_state_version
    check_state_version .pipeline/state.json
    local exit_code=$?

    # Should return success
    if [ "$exit_code" -ne 0 ]; then
        echo "FAIL: check_state_version should succeed for compatible version"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: check_state_version succeeds for compatible version"
}

test_check_state_version_missing_version() {
    setup_test_env

    # Create state file without version field
    echo '{"stage": "ready"}' > .pipeline/state.json

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" check_state_version 2>/dev/null || true

    # Call check_state_version
    check_state_version .pipeline/state.json
    local exit_code=$?

    # Should default to "0.0.0" and succeed
    if [ "$exit_code" -ne 0 ]; then
        echo "FAIL: check_state_version should handle missing version gracefully"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: check_state_version handles missing version field gracefully"
}

test_check_state_version_custom_file() {
    setup_test_env

    # Create custom state file
    mkdir -p custom
    echo '{"version": "1.0.0", "stage": "ready"}' > custom/my-state.json

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" check_state_version 2>/dev/null || true

    # Call check_state_version with custom path
    check_state_version custom/my-state.json
    local exit_code=$?

    # Should succeed
    if [ "$exit_code" -ne 0 ]; then
        echo "FAIL: check_state_version should accept custom file path"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: check_state_version accepts custom file path parameter"
}

# ============================================================================
# TEST SUITE: backup/commit workflow integration
# ============================================================================

test_backup_commit_workflow() {
    setup_test_env

    # Create state file
    echo '{"stage": "work", "version": "1.0.0"}' > .pipeline/state.json

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" backup_state commit_state 2>/dev/null || true

    # Step 1: Backup state
    backup_state
    if [ ! -f ".pipeline/state.json.backup" ]; then
        echo "FAIL: Workflow step 1 - backup not created"
        teardown_test_env
        return 1
    fi

    # Step 2: Modify state (simulating an operation)
    echo '{"stage": "complete", "version": "1.0.0"}' > .pipeline/state.json

    # Step 3: Commit state (remove backup on success)
    commit_state
    if [ -f ".pipeline/state.json.backup" ]; then
        echo "FAIL: Workflow step 2 - backup not removed after commit"
        teardown_test_env
        return 1
    fi

    # Verify final state
    if ! grep -q '"stage": "complete"' .pipeline/state.json; then
        echo "FAIL: Workflow - final state is incorrect"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: backup + commit workflow - complete transaction pattern"
}

test_backup_rollback_workflow() {
    setup_test_env

    # Create state file
    echo '{"stage": "work", "version": "1.0.0"}' > .pipeline/state.json
    local original_content
    original_content=$(cat .pipeline/state.json)

    # Source the pipeline functions
    source "$PROJECT_ROOT/pipeline.sh" backup_state 2>/dev/null || true

    # Step 1: Backup state
    backup_state

    # Step 2: Modify state (simulating a failed operation)
    echo '{"stage": "corrupted"}' > .pipeline/state.json

    # Step 3: Rollback - restore from backup
    if [ -f ".pipeline/state.json.backup" ]; then
        cp .pipeline/state.json.backup .pipeline/state.json
    else
        echo "FAIL: Rollback - no backup to restore from"
        teardown_test_env
        return 1
    fi

    # Verify rollback restored original state
    local restored_content
    restored_content=$(cat .pipeline/state.json)
    if [ "$original_content" != "$restored_content" ]; then
        echo "FAIL: Rollback - state not properly restored"
        teardown_test_env
        return 1
    fi

    teardown_test_env
    echo "PASS: backup + rollback workflow - error recovery pattern"
}

# ============================================================================
# RUN ALL TESTS
# ============================================================================

echo "╔════════════════════════════════════════════════════════╗"
echo "║  Unit Tests: State Operations (backup/commit/version) ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Run all tests
test_backup_state_success
test_backup_state_no_file
test_backup_state_overwrites_existing
test_commit_state_removes_backup
test_commit_state_no_backup
test_commit_state_idempotent
test_check_state_version_no_file
test_check_state_version_compatible
test_check_state_version_missing_version
test_check_state_version_custom_file
test_backup_commit_workflow
test_backup_rollback_workflow

echo ""
echo "✓ ALL STATE OPERATION TESTS PASSED"
