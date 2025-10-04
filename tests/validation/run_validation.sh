#!/bin/bash
# Code Generation Validation Suite
# Validates that pipeline.sh generates working, executable code for all languages

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VALIDATION_DIR="$SCRIPT_DIR/projects"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_PASSED=0
TOTAL_FAILED=0

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Code Generation Validation Suite (Task 1.2)            ║${NC}"
echo -e "${BLUE}║  Validates generated code actually works                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Create validation directory
mkdir -p "$VALIDATION_DIR"

# Function to run a validation test
run_validation() {
    local language=$1
    local test_script=$2

    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Validating: $language${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    if [ -f "$SCRIPT_DIR/$test_script" ]; then
        if bash "$SCRIPT_DIR/$test_script"; then
            echo -e "${GREEN}✓ $language validation PASSED${NC}"
            ((TOTAL_PASSED++))
        else
            echo -e "${RED}✗ $language validation FAILED${NC}"
            ((TOTAL_FAILED++))
        fi
    else
        echo -e "${RED}✗ $language validation MISSING - test script not found: $test_script${NC}"
        ((TOTAL_FAILED++))
    fi

    echo ""
}

# Run validations for each language
run_validation "JavaScript" "validate_javascript.sh"
run_validation "Python" "validate_python.sh"
run_validation "Go" "validate_go.sh"
run_validation "Bash" "validate_bash.sh"

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}VALIDATION SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ ALL VALIDATIONS PASSED${NC}"
    echo -e "${GREEN}  Languages validated: $TOTAL_PASSED${NC}"
    echo ""
    echo -e "${GREEN}Task 1.2 Status: COMPLETE ✅${NC}"
else
    echo -e "${RED}✗ SOME VALIDATIONS FAILED${NC}"
    echo -e "${GREEN}  Passed: $TOTAL_PASSED${NC}"
    echo -e "${RED}  Failed: $TOTAL_FAILED${NC}"
    echo ""
    echo -e "${RED}Task 1.2 Status: INCOMPLETE ❌${NC}"
fi

echo ""

# Cleanup
if [ $TOTAL_FAILED -eq 0 ]; then
    echo "Cleaning up validation projects..."
    rm -rf "$VALIDATION_DIR"
    echo "✓ Cleanup complete"
    echo ""
fi

exit $TOTAL_FAILED
