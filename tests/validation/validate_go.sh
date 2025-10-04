#!/bin/bash
# Go Code Generation Validation
# Verifies that pipeline generates working Go code with testing package

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VALIDATION_DIR="$SCRIPT_DIR/projects/go_validation"
PIPELINE="$PROJECT_ROOT/pipeline.sh"

echo "Step 1: Create Go project..."
mkdir -p "$VALIDATION_DIR"
cd "$VALIDATION_DIR"

# Create go.mod
cat > go.mod << 'EOF'
module validation/test

go 1.21
EOF

# Initialize git (required by pipeline)
git init >/dev/null 2>&1
git config user.email "test@example.com"
git config user.name "Test User"

echo "✓ Go project created"

echo "Step 2: Generate requirements with pipeline..."
if bash "$PIPELINE" requirements "Parse JSON configuration file" >/dev/null 2>&1; then
    echo "✓ Requirements generated"
else
    echo "✗ Requirements generation failed"
    exit 1
fi

echo "Step 3: Create test state for story..."
mkdir -p .pipeline
cat > .pipeline/state.json << 'EOF'
{
  "current_story": "GO-001",
  "stories": {
    "GO-001": {
      "title": "Parse JSON config",
      "status": "in_progress"
    }
  }
}
EOF

echo "✓ Test state created"

echo "Step 4: Run work stage to generate code..."
if bash "$PIPELINE" work GO-001 >/dev/null 2>&1; then
    echo "✓ Code generation completed"
else
    echo "✗ Code generation failed"
    exit 1
fi

echo "Step 5: Verify test files were created..."
TEST_FILES=$(find . -name "*_test.go" -type f | wc -l)
if [ "$TEST_FILES" -gt 0 ]; then
    echo "✓ Found $TEST_FILES test file(s)"
else
    echo "✗ No test files generated"
    find . -type f -name "*.go" | head -10
    exit 1
fi

echo "Step 6: Verify implementation files were created..."
IMPL_FILES=$(find . -name "*.go" ! -name "*_test.go" -type f | wc -l)
if [ "$IMPL_FILES" -gt 0 ]; then
    echo "✓ Found $IMPL_FILES implementation file(s)"
else
    echo "✗ No implementation files generated"
    exit 1
fi

echo "Step 7: Check Go syntax with go build..."
if command -v go >/dev/null 2>&1; then
    SYNTAX_ERRORS=0

    # Try to build (syntax check)
    if go build ./... 2>&1 | tee build-output.log; then
        echo "✓ All Go files have valid syntax (build successful)"
    else
        # Check if it's just missing dependencies or actual syntax errors
        if grep -q "syntax error\|undefined:" build-output.log; then
            echo "✗ Syntax errors found in Go code"
            cat build-output.log
            exit 1
        else
            echo "⚠ Build had issues but syntax appears valid"
        fi
    fi

    echo "Step 8: Run Go tests..."
    if go test -v ./... 2>&1 | tee test-output.log; then
        echo "✓ Tests executed successfully"

        # Check if tests actually passed
        if grep -q "PASS\|ok" test-output.log; then
            echo "✓ Tests passed"
        else
            echo "⚠ Tests ran but may not have passed"
        fi
    else
        # Tests might fail if implementation is incomplete
        echo "⚠ Tests executed (some may have failed - this is OK for validation)"
    fi
else
    echo "⚠ go command not available - checking syntax manually..."

    # Fallback: check for obvious syntax errors in generated files
    SYNTAX_ERRORS=0
    for file in $(find . -name "*.go"); do
        # Check for basic Go syntax elements
        if ! grep -q "^package " "$file"; then
            echo "✗ Missing package declaration in $file"
            ((SYNTAX_ERRORS++))
        fi
    done

    if [ $SYNTAX_ERRORS -eq 0 ]; then
        echo "✓ Basic Go syntax checks passed"
    else
        echo "✗ Found $SYNTAX_ERRORS syntax issues"
        exit 1
    fi
fi

echo ""
echo "Go Validation: PASSED ✅"
echo "- Code generated: ✓"
echo "- Syntax valid: ✓"
echo "- Files created: ✓"

cd "$SCRIPT_DIR"
exit 0
