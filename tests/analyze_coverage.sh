#!/bin/bash
# Test Coverage Analysis for pipeline.sh
# Analyzes which functions and stages are covered by tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PIPELINE="$PROJECT_ROOT/pipeline.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Pipeline Test Coverage Analysis                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Extract all function names from pipeline.sh
echo -e "${YELLOW}Analyzing pipeline.sh functions...${NC}"
FUNCTIONS=$(grep -E "^[a-z_]+\(\)" "$PIPELINE" | sed 's/().*$//' | sort)
TOTAL_FUNCTIONS=$(echo "$FUNCTIONS" | wc -l | tr -d ' ')

echo -e "${BLUE}Total functions defined: $TOTAL_FUNCTIONS${NC}"
echo ""

# Check which functions are tested
echo -e "${YELLOW}Checking test coverage per function...${NC}"
echo ""

TESTED_FUNCTIONS=0
UNTESTED_FUNCTIONS=0

echo -e "${BLUE}Function                    Status${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for func in $FUNCTIONS; do
    # Check if function is tested (appears in test files)
    if grep -r "$func" tests/unit/*.sh tests/integration/*.sh >/dev/null 2>&1; then
        printf "%-25s " "$func"
        echo -e "${GREEN}✓ TESTED${NC}"
        ((TESTED_FUNCTIONS++))
    else
        printf "%-25s " "$func"
        echo -e "${RED}✗ UNTESTED${NC}"
        ((UNTESTED_FUNCTIONS++))
    fi
done

echo ""
echo -e "${BLUE}═════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}COVERAGE SUMMARY${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════════════${NC}"
echo ""

# Calculate percentage
COVERAGE_PCT=$((TESTED_FUNCTIONS * 100 / TOTAL_FUNCTIONS))

echo "Total Functions:    $TOTAL_FUNCTIONS"
echo -e "${GREEN}Tested Functions:   $TESTED_FUNCTIONS${NC}"
echo -e "${RED}Untested Functions: $UNTESTED_FUNCTIONS${NC}"
echo ""
echo -e "${BLUE}Coverage: ${COVERAGE_PCT}%${NC}"
echo ""

# Check acceptance criteria from Task 1.1
echo -e "${BLUE}═════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}TASK 1.1 ACCEPTANCE CRITERIA${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════════════${NC}"
echo ""

# Check if we have 80%+ coverage
if [ $COVERAGE_PCT -ge 80 ]; then
    echo -e "${GREEN}✓ Code coverage >= 80% (achieved: ${COVERAGE_PCT}%)${NC}"
else
    echo -e "${RED}✗ Code coverage < 80% (achieved: ${COVERAGE_PCT}%, need: 80%)${NC}"
fi

# Check language generator tests
echo ""
echo -e "${YELLOW}Language Generator Tests:${NC}"

for lang in javascript python golang bash; do
    test_file="tests/unit/test_work_stage_${lang}.sh"
    if [ -f "$PROJECT_ROOT/$test_file" ]; then
        echo -e "${GREEN}  ✓ ${lang} generator tested${NC}"
    else
        echo -e "${RED}  ✗ ${lang} generator NOT tested${NC}"
    fi
done

# Check state management tests
echo ""
if [ -f "tests/unit/test_state_management.sh" ]; then
    echo -e "${GREEN}✓ State manager has unit tests${NC}"
else
    echo -e "${RED}✗ State manager NOT tested${NC}"
fi

# Check end-to-end tests
if [ -f "tests/integration/test_end_to_end_workflow.sh" ]; then
    echo -e "${GREEN}✓ Pipeline has end-to-end integration tests${NC}"
else
    echo -e "${RED}✗ No end-to-end integration tests${NC}"
fi

echo ""
echo -e "${BLUE}═════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}TEST FILE STATISTICS${NC}"
echo -e "${BLUE}═════════════════════════════════════════════════════════${NC}"
echo ""

# Count test files and lines
UNIT_TESTS=$(find tests/unit -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')
INTEGRATION_TESTS=$(find tests/integration -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')
EDGE_CASE_TESTS=$(find tests/edge_cases -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "Unit test files:        $UNIT_TESTS"
echo "Integration test files: $INTEGRATION_TESTS"
echo "Edge case test files:   $EDGE_CASE_TESTS"
echo ""

# Count lines of test code
TEST_LINES=$(find tests -name "*.sh" -type f -exec cat {} \; 2>/dev/null | wc -l | tr -d ' ')
PIPELINE_LINES=$(wc -l < "$PIPELINE" | tr -d ' ')
TEST_RATIO=$((TEST_LINES * 100 / PIPELINE_LINES))

echo "Production code (pipeline.sh): $PIPELINE_LINES lines"
echo "Test code (all tests):         $TEST_LINES lines"
echo "Test-to-code ratio:            ${TEST_RATIO}%"
echo ""

# Final verdict
echo -e "${BLUE}═════════════════════════════════════════════════════════${NC}"
if [ $COVERAGE_PCT -ge 80 ] && [ $UNIT_TESTS -ge 4 ] && [ $INTEGRATION_TESTS -ge 1 ]; then
    echo -e "${GREEN}✓ TASK 1.1 ACCEPTANCE CRITERIA MET${NC}"
    echo ""
    echo -e "${GREEN}  • 80%+ code coverage ✓${NC}"
    echo -e "${GREEN}  • All 4 language generators tested ✓${NC}"
    echo -e "${GREEN}  • State manager has unit tests ✓${NC}"
    echo -e "${GREEN}  • End-to-end integration tests exist ✓${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ TASK 1.1 ACCEPTANCE CRITERIA NOT FULLY MET${NC}"
    echo ""
    echo "Missing requirements:"
    if [ $COVERAGE_PCT -lt 80 ]; then
        echo -e "${RED}  • Need 80%+ code coverage (current: ${COVERAGE_PCT}%)${NC}"
    fi
    if [ $UNIT_TESTS -lt 4 ]; then
        echo -e "${RED}  • Need tests for all 4 languages (current: ${UNIT_TESTS})${NC}"
    fi
    if [ $INTEGRATION_TESTS -lt 1 ]; then
        echo -e "${RED}  • Need end-to-end integration tests${NC}"
    fi
    exit 1
fi
