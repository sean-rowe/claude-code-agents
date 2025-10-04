#!/bin/bash
# Edge Case Test Suite Runner
# Executes all edge case tests for Task 1.3

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_PASSED=0
TOTAL_FAILED=0

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Edge Case Test Suite (Task 1.3)                  ║${NC}"
echo -e "${BLUE}║  Tests pipeline robustness and error handling     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

run_test_suite() {
    local test_name=$1
    local test_script=$2

    echo -e "${YELLOW}══════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Running: $test_name${NC}"
    echo -e "${YELLOW}══════════════════════════════════════════════════${NC}"
    echo ""

    if [ ! -f "$SCRIPT_DIR/$test_script" ]; then
        echo -e "${RED}✗ Test script not found: $test_script${NC}"
        ((TOTAL_FAILED++))
        return 1
    fi

    if bash "$SCRIPT_DIR/$test_script"; then
        echo -e "${GREEN}✓ $test_name: PASSED${NC}"
        ((TOTAL_PASSED++))
    else
        echo -e "${RED}✗ $test_name: FAILED${NC}"
        ((TOTAL_FAILED++))
    fi

    echo ""
}

# Run all edge case test suites
run_test_suite "Story ID Edge Cases" "test_edge_case_story_ids.sh"
run_test_suite "Missing Dependencies" "test_missing_dependencies.sh"
run_test_suite "Corrupted State Files" "test_corrupted_state.sh"

# Summary
echo ""
echo -e "${BLUE}══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}EDGE CASE TEST SUMMARY${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════${NC}"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ ALL EDGE CASE TEST SUITES PASSED${NC}"
    echo -e "${GREEN}  Test Suites Passed: $TOTAL_PASSED${NC}"
    echo ""
    echo -e "${GREEN}Task 1.3 Status: COMPLETE ✅${NC}"
else
    echo -e "${RED}✗ SOME EDGE CASE TESTS FAILED${NC}"
    echo -e "${GREEN}  Passed: $TOTAL_PASSED${NC}"
    echo -e "${RED}  Failed: $TOTAL_FAILED${NC}"
    echo ""
    echo -e "${RED}Task 1.3 Status: INCOMPLETE ❌${NC}"
fi

echo ""

exit $TOTAL_FAILED
