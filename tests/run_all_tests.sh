#!/bin/bash
# Master test runner for pipeline.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Claude Code Agents - Test Suite                   ║${NC}"
echo -e "${BLUE}║       Pipeline.sh Comprehensive Testing                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if pipeline.sh exists
if [ ! -f "$PROJECT_ROOT/pipeline.sh" ]; then
    echo -e "${RED}ERROR: pipeline.sh not found at $PROJECT_ROOT${NC}"
    exit 1
fi

echo -e "${GREEN}Testing pipeline.sh at: $PROJECT_ROOT/pipeline.sh${NC}"
echo ""

# Run unit tests
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}UNIT TESTS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

for test_file in "$SCRIPT_DIR/unit"/*.sh; do
    if [ -f "$test_file" ]; then
        chmod +x "$test_file"

        echo -e "${YELLOW}Running: $(basename "$test_file")${NC}"
        echo ""

        if bash "$test_file"; then
            # Count passed tests from output
            passed=$(bash "$test_file" 2>&1 | grep -c "^PASS:" || true)
            TOTAL_PASSED=$((TOTAL_PASSED + passed))
        else
            # Test suite failed
            failed=$(bash "$test_file" 2>&1 | grep -c "^FAIL:" || true)
            TOTAL_FAILED=$((TOTAL_FAILED + failed))
        fi

        echo ""
    fi
done

# Run integration tests if they exist
if [ -d "$SCRIPT_DIR/integration" ] && [ -n "$(ls -A "$SCRIPT_DIR/integration" 2>/dev/null)" ]; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}INTEGRATION TESTS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    for test_file in "$SCRIPT_DIR/integration"/*.sh; do
        if [ -f "$test_file" ]; then
            chmod +x "$test_file"

            echo -e "${YELLOW}Running: $(basename "$test_file")${NC}"
            echo ""

            if bash "$test_file"; then
                passed=$(bash "$test_file" 2>&1 | grep -c "^PASS:" || true)
                TOTAL_PASSED=$((TOTAL_PASSED + passed))
            else
                failed=$(bash "$test_file" 2>&1 | grep -c "^FAIL:" || true)
                TOTAL_FAILED=$((TOTAL_FAILED + failed))
            fi

            echo ""
        fi
    done
fi

# Final summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}TEST SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    echo -e "${GREEN}  Total Passed: $TOTAL_PASSED${NC}"
else
    echo -e "${RED}✗ SOME TESTS FAILED${NC}"
    echo -e "${GREEN}  Passed: $TOTAL_PASSED${NC}"
    echo -e "${RED}  Failed: $TOTAL_FAILED${NC}"
fi

if [ $TOTAL_SKIPPED -gt 0 ]; then
    echo -e "${YELLOW}  Skipped: $TOTAL_SKIPPED${NC}"
fi

echo ""

# Exit with failure if any tests failed
if [ $TOTAL_FAILED -gt 0 ]; then
    exit 1
fi

exit 0
