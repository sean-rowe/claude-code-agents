#!/bin/bash
# Integration Test: Complete Workflow (requirements → gherkin → stories → work)
# Tests the documented workflow to ensure it works end-to-end

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PIPELINE="$PROJECT_ROOT/pipeline.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Setup test environment
setup_test_env() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    git init >/dev/null 2>&1
    git config user.email "test@example.com"
    git config user.name "Test User"
    log_info "Test environment created: $TEST_DIR"
}

# Cleanup test environment
teardown_test_env() {
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        cd /tmp
        rm -rf "$TEST_DIR"
        log_info "Test environment cleaned up"
    fi
}

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Test 1: Complete workflow from requirements to work
test_complete_workflow() {
    echo ""
    echo "========================================="
    echo "Test: Complete Workflow (requirements → gherkin → stories → work)"
    echo "========================================="
    setup_test_env

    ((TESTS_RUN++))

    # Step 1: Requirements stage
    log_info "Step 1: Running requirements stage..."
    if ! bash "$PIPELINE" requirements "Build a calculator" >/dev/null 2>&1; then
        log_error "Requirements stage failed"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ Requirements stage completed"

    # Verify requirements file created
    if [ ! -f ".pipeline/requirements.md" ]; then
        log_error "Requirements file not created"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ Requirements file exists"

    # Step 2: Gherkin stage
    log_info "Step 2: Running gherkin stage..."
    if ! bash "$PIPELINE" gherkin >/dev/null 2>&1; then
        log_error "Gherkin stage failed"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ Gherkin stage completed"

    # Verify feature files created
    if [ ! -d ".pipeline/features" ]; then
        log_error "Features directory not created"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ Features directory exists"

    # Step 3: Stories stage
    log_info "Step 3: Running stories stage..."
    if ! bash "$PIPELINE" stories >/dev/null 2>&1; then
        log_error "Stories stage failed"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ Stories stage completed"

    # CRITICAL: Verify state has stories field
    if ! command -v jq &>/dev/null; then
        log_warn "jq not available, skipping state verification"
    else
        STATE_HAS_STORIES=$(jq -e '.stories' .pipeline/state.json >/dev/null 2>&1 && echo "yes" || echo "no")
        if [ "$STATE_HAS_STORIES" = "no" ]; then
            log_error "CRITICAL BUG: State does not have 'stories' field after stories stage"
            log_error "State content:"
            cat .pipeline/state.json
            ((TESTS_FAILED++))
            teardown_test_env
            return 1
        fi
        log_info "✓ State has 'stories' field"
    fi

    # Step 4: Work stage (THIS IS WHERE THE BUG WAS)
    log_info "Step 4: Running work stage for PROJ-2..."
    if ! bash "$PIPELINE" work PROJ-2 2>&1 | tee work_output.log; then
        # Check if it failed due to missing stories field
        if grep -q "Required field missing.*stories" work_output.log; then
            log_error "CRITICAL BUG CONFIRMED: Work stage fails because stories field missing"
            log_error "Error output:"
            cat work_output.log
            ((TESTS_FAILED++))
            teardown_test_env
            return 1
        fi
        # Other failure - might be expected (no git remote, etc.)
        if grep -q "Failed to push to remote repository" work_output.log; then
            log_warn "Work stage completed but git push failed (expected in test environment)"
            log_info "✓ Work stage completed successfully (git push failure is acceptable)"
        else
            log_error "Work stage failed for unknown reason:"
            cat work_output.log
            ((TESTS_FAILED++))
            teardown_test_env
            return 1
        fi
    else
        log_info "✓ Work stage completed successfully"
    fi

    # Verify implementation files were created
    if [ ! -f "proj_2.sh" ]; then
        log_error "Implementation file not created"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ Implementation file created: proj_2.sh"

    if [ ! -f "tests/proj_2_test.sh" ]; then
        log_error "Test file not created"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ Test file created: tests/proj_2_test.sh"

    # Verify generated code is executable
    if [ ! -x "proj_2.sh" ]; then
        log_error "Implementation file not executable"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ Implementation file is executable"

    # Verify generated code has real implementation (not just placeholders)
    if grep -q "TODO\|FIXME\|placeholder" proj_2.sh; then
        log_warn "Generated code contains TODO/FIXME/placeholder markers"
    fi

    if ! grep -q "validate" proj_2.sh; then
        log_error "Generated code missing validation function"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ Generated code contains validation logic"

    # Success!
    echo ""
    log_info "========================================="
    log_info "COMPLETE WORKFLOW TEST PASSED ✓"
    log_info "========================================="
    echo ""
    log_info "Workflow verified:"
    log_info "  1. requirements → .pipeline/requirements.md ✓"
    log_info "  2. gherkin → .pipeline/features/*.feature ✓"
    log_info "  3. stories → state with stories field ✓"
    log_info "  4. work → implementation + tests ✓"
    echo ""

    ((TESTS_PASSED++))
    teardown_test_env
    return 0
}

# Test 2: State structure after each stage
test_state_structure_progression() {
    echo ""
    echo "========================================="
    echo "Test: State Structure Progression"
    echo "========================================="
    setup_test_env

    ((TESTS_RUN++))

    if ! command -v jq &>/dev/null; then
        log_warn "jq not available, skipping state structure test"
        teardown_test_env
        return 0
    fi

    # After requirements
    bash "$PIPELINE" requirements "test" >/dev/null 2>&1
    STAGE=$(jq -r '.stage' .pipeline/state.json)
    if [ "$STAGE" != "ready" ] && [ "$STAGE" != "requirements" ]; then
        log_error "State stage incorrect after requirements: $STAGE"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ State stage after requirements: $STAGE"

    # After gherkin
    bash "$PIPELINE" gherkin >/dev/null 2>&1
    STAGE=$(jq -r '.stage' .pipeline/state.json)
    if [ "$STAGE" != "gherkin" ]; then
        log_error "State stage incorrect after gherkin: $STAGE"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ State stage after gherkin: $STAGE"

    # After stories
    bash "$PIPELINE" stories >/dev/null 2>&1
    STAGE=$(jq -r '.stage' .pipeline/state.json)
    if [ "$STAGE" != "stories" ]; then
        log_error "State stage incorrect after stories: $STAGE"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ State stage after stories: $STAGE"

    # Verify epicId exists
    EPIC_ID=$(jq -r '.epicId' .pipeline/state.json)
    if [ -z "$EPIC_ID" ] || [ "$EPIC_ID" = "null" ]; then
        log_error "epicId missing or null in state after stories"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ epicId exists in state: $EPIC_ID"

    # CRITICAL: Verify stories field exists
    STORIES_TYPE=$(jq -r '.stories | type' .pipeline/state.json)
    if [ "$STORIES_TYPE" != "object" ] && [ "$STORIES_TYPE" != "array" ]; then
        log_error "CRITICAL: stories field missing or wrong type in state after stories: $STORIES_TYPE"
        log_error "Full state:"
        jq '.' .pipeline/state.json
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
    log_info "✓ stories field exists in state with type: $STORIES_TYPE"

    echo ""
    log_info "State structure progression test PASSED ✓"
    ((TESTS_PASSED++))
    teardown_test_env
    return 0
}

# Test 3: Verify bug fix - stories field is required
test_stories_field_required_for_work() {
    echo ""
    echo "========================================="
    echo "Test: Stories Field Required for Work Command"
    echo "========================================="
    setup_test_env

    ((TESTS_RUN++))

    if ! command -v jq &>/dev/null; then
        log_warn "jq not available, skipping this test"
        teardown_test_env
        return 0
    fi

    # Create state without stories field (simulate old bug)
    bash "$PIPELINE" requirements "test" >/dev/null 2>&1
    jq 'del(.stories)' .pipeline/state.json > .pipeline/tmp.json && mv .pipeline/tmp.json .pipeline/state.json

    log_info "Created state WITHOUT stories field"

    # Try to run work command - should fail with clear error
    if bash "$PIPELINE" work TEST-001 2>&1 | grep -q "Required field missing.*stories"; then
        log_info "✓ Work command correctly rejects state without stories field"
        ((TESTS_PASSED++))
        teardown_test_env
        return 0
    else
        log_error "Work command did not validate for stories field"
        ((TESTS_FAILED++))
        teardown_test_env
        return 1
    fi
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════╗"
    echo "║  Complete Workflow Integration Tests              ║"
    echo "║  Verifies: requirements → gherkin → stories → work ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo ""

    # Run all tests
    test_complete_workflow || true
    test_state_structure_progression || true
    test_stories_field_required_for_work || true

    # Summary
    echo ""
    echo "========================================="
    echo "Test Summary"
    echo "========================================="
    echo "Total Tests: $TESTS_RUN"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo ""

    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}✗ SOME TESTS FAILED${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
        exit 0
    fi
}

# Run tests
main
