# Pipeline Test Suite

Comprehensive test suite for `pipeline.sh` covering all stages and language code generation.

## Quick Start

```bash
# Run all tests
bash tests/run_all_tests.sh

# Run specific test file
bash tests/unit/test_requirements_stage.sh
bash tests/unit/test_gherkin_stage.sh
bash tests/unit/test_work_stage_javascript.sh
bash tests/unit/test_work_stage_python.sh
```

## Test Coverage

### Unit Tests

#### Requirements Stage (`test_requirements_stage.sh`)
- ✅ Creates `.pipeline` directory structure
- ✅ Generates `requirements.md` file with correct content
- ✅ Creates `state.json` with initial state
- ✅ Adds `.pipeline/` to `.gitignore` when it exists

#### Gherkin Stage (`test_gherkin_stage.sh`)
- ✅ Creates `.pipeline/features` directory
- ✅ Generates `.feature` files for all scenarios
- ✅ Feature files follow BDD format (Feature/Rule/Example/Given/When/Then)
- ✅ Updates pipeline state to 'gherkin'

#### Work Stage - JavaScript (`test_work_stage_javascript.sh`)
- ✅ Generates JavaScript test file (`*.test.js`)
- ✅ Generates JavaScript implementation file (`*.js`)
- ✅ Implementation has `validate()` function
- ✅ Implementation has `implement()` function
- ✅ Contains real validation logic (not stub `return true`)
- ✅ Has JSDoc comments (`@param`, `@returns`)
- ✅ Syntax is valid (passes `node --check`)

#### Work Stage - Python (`test_work_stage_python.sh`)
- ✅ Generates Python test file (`test_*.py`)
- ✅ Generates Python implementation file (`*.py`)
- ✅ Implementation has `validate()` function
- ✅ Implementation has `implement()` function
- ✅ Has type hints (`from typing import`, `-> bool`)
- ✅ Has docstrings (with Args/Returns)
- ✅ Contains real validation logic (not stub `return True`)
- ✅ Syntax is valid (passes `python3 -m py_compile`)

## Test Results

**Current Status:** ✅ **23/23 tests passing (100%)**

```
UNIT TESTS:
- test_gherkin_stage.sh:        4 passed, 0 failed
- test_requirements_stage.sh:   4 passed, 0 failed
- test_work_stage_javascript.sh: 7 passed, 0 failed
- test_work_stage_python.sh:    8 passed, 0 failed

TOTAL: 23 passed, 0 failed
```

## Test Structure

```
tests/
├── README.md                     # This file
├── run_all_tests.sh              # Master test runner
├── test_helper.bash              # Shared test utilities
│
├── unit/                         # Unit tests for each stage
│   ├── test_requirements_stage.sh
│   ├── test_gherkin_stage.sh
│   ├── test_work_stage_javascript.sh
│   └── test_work_stage_python.sh
│
├── integration/                  # Integration tests (future)
│   └── (to be added)
│
└── fixtures/                     # Test fixtures and sample data
    └── (to be added)
```

## Test Helper Functions

The `test_helper.bash` file provides reusable test utilities:

### Environment Setup
- `setup_test_env()` - Creates isolated temp directory with git repo
- `teardown_test_env()` - Cleans up temp directory
- `find_project_root()` - Locates project root containing pipeline.sh

### Project Setup
- `setup_nodejs_project()` - Creates mock Node.js project with package.json
- `setup_python_project()` - Creates mock Python project with requirements.txt
- `setup_go_project()` - Creates mock Go project with go.mod
- `setup_bash_project()` - Creates mock Bash project structure

### Assertions
- `assert_file_exists(file)` - Verify file exists
- `assert_dir_exists(dir)` - Verify directory exists
- `assert_file_contains(file, text)` - Verify file contains text
- `assert_success(cmd)` - Verify command succeeds
- `assert_failure(cmd)` - Verify command fails

### Utilities
- `run_pipeline(stage, args...)` - Execute pipeline.sh stage
- `count_lines(file)` - Count lines in file
- `mock_acli()` - Mock JIRA CLI for testing

## Writing New Tests

Example test structure:

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../test_helper.bash"

test_my_feature() {
    setup_test_env
    setup_nodejs_project

    run_pipeline work "STORY-123" >/dev/null

    assert_file_exists "src/story_123.js" || {
        teardown_test_env
        return 1
    }

    teardown_test_env
    echo "PASS: my feature works"
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0

    if test_my_feature; then
        ((passed++))
    else
        ((failed++))
    fi

    echo "Results: $passed passed, $failed failed"
    return $failed
}

# Run tests if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_all_tests
    exit $?
fi
```

## Running Tests in CI/CD

The test suite is designed to run in CI/CD environments:

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: bash tests/run_all_tests.sh
```

Tests return:
- Exit code 0 if all tests pass
- Exit code non-zero if any test fails

## Test Requirements

### Required Tools
- `bash` (4.0+)
- `git`
- `node` (for JavaScript syntax validation)
- `python3` (for Python syntax validation)
- `jq` (optional, for JSON state validation)

### Optional Tools
- `go` (for Go code generation tests - coming soon)
- `acli` (for JIRA integration tests - mocked)

## Coverage Metrics

Current test coverage by stage:

| Stage | Coverage | Tests |
|-------|----------|-------|
| requirements | 100% | 4/4 core features |
| gherkin | 100% | 4/4 core features |
| stories | 0% | 0 tests (mocked JIRA) |
| work (JS) | 100% | 7/7 core features |
| work (Python) | 100% | 8/8 core features |
| work (Go) | 0% | 0 tests (to be added) |
| work (Bash) | 0% | 0 tests (to be added) |
| complete | 0% | 0 tests (to be added) |
| cleanup | 0% | 0 tests (to be added) |

**Overall:** ~33% pipeline coverage (4 of 12 language/stage combinations tested)

## Future Tests

### Planned Unit Tests
- ☐ Work stage - Go code generation
- ☐ Work stage - Bash script generation
- ☐ Stories stage (with mocked acli)
- ☐ Complete stage
- ☐ Cleanup stage
- ☐ State management functions
- ☐ Error handling edge cases

### Planned Integration Tests
- ☐ Full workflow: requirements → gherkin → stories → work → complete
- ☐ Multi-story projects
- ☐ State recovery after interruption
- ☐ Git branch management
- ☐ JIRA integration (with real acli if available)

### Planned Edge Case Tests
- ☐ Invalid story IDs
- ☐ Missing dependencies (no node, no python3)
- ☐ Corrupted state.json
- ☐ Network failures
- ☐ Permission errors
- ☐ Concurrent pipeline runs
- ☐ Very long story names
- ☐ Special characters in inputs

## Contributing

When adding new tests:

1. Follow the existing test structure
2. Use `test_helper.bash` utilities
3. Always cleanup with `teardown_test_env`
4. Write descriptive test names
5. Include a PASS message
6. Return 1 on failure, 0 on success
7. Update this README with new tests

## Troubleshooting

### Tests fail with "Cannot find pipeline.sh"
Ensure you're running tests from the project root or a subdirectory.

### Tests fail with "command not found: node/python3"
Install the required language runtime for the tests you're running.

### State bleeding between tests
Each test should call `setup_test_env()` which creates an isolated temp directory.

### Intermittent failures
Check that tests properly cleanup resources and don't depend on execution order.

## License

Same as parent project (MIT)
