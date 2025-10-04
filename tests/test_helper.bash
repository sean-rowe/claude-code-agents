#!/bin/bash
# Test helper functions for pipeline.sh tests

# Find project root (should be called once at the start of each test file)
find_project_root() {
    local search_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"

    # Search up from the test script location
    while [ "$search_dir" != "/" ]; do
        if [ -f "$search_dir/pipeline.sh" ]; then
            echo "$search_dir"
            return 0
        fi
        search_dir="$(dirname "$search_dir")"
    done

    # Try from current working directory
    search_dir="$PWD"
    while [ "$search_dir" != "/" ]; do
        if [ -f "$search_dir/pipeline.sh" ]; then
            echo "$search_dir"
            return 0
        fi
        search_dir="$(dirname "$search_dir")"
    done

    echo "" >&2
    return 1
}

# Initialize - set PROJECT_ROOT globally
if [ -z "$PROJECT_ROOT" ]; then
    PROJECT_ROOT="$(find_project_root)"
    if [ -z "$PROJECT_ROOT" ]; then
        echo "ERROR: Cannot find project root with pipeline.sh" >&2
        exit 1
    fi
    export PROJECT_ROOT
fi

# Setup test environment
setup_test_env() {
    # Save original directory
    export ORIGINAL_PWD="$PWD"

    # Verify PROJECT_ROOT is set
    if [ -z "$PROJECT_ROOT" ] || [ ! -f "$PROJECT_ROOT/pipeline.sh" ]; then
        echo "ERROR: PROJECT_ROOT not set correctly: $PROJECT_ROOT" >&2
        return 1
    fi

    # Create and switch to temp directory
    export TEST_TEMP_DIR="$(mktemp -d)"
    cd "$TEST_TEMP_DIR"

    # Initialize git repo for tests
    git init --quiet 2>/dev/null
    git config user.email "test@example.com"
    git config user.name "Test User"

    # Create initial commit
    touch README.md
    git add README.md
    git commit -m "Initial commit" --quiet 2>/dev/null
}

# Cleanup test environment
teardown_test_env() {
    cd "$ORIGINAL_PWD"
    if [ -n "$TEST_TEMP_DIR" ] && [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Create a mock Node.js project
setup_nodejs_project() {
    cat > package.json <<EOF
{
  "name": "test-project",
  "version": "1.0.0",
  "scripts": {
    "test": "jest"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  }
}
EOF
    mkdir -p src
}

# Create a mock Python project
setup_python_project() {
    cat > requirements.txt <<EOF
pytest>=7.0.0
EOF
    mkdir -p src tests
    touch src/__init__.py
    touch tests/__init__.py
}

# Create a mock Go project
setup_go_project() {
    cat > go.mod <<EOF
module testproject

go 1.21
EOF
}

# Create a mock Bash project
setup_bash_project() {
    mkdir -p tests
}

# Mock acli command for JIRA tests
mock_acli() {
    cat > "$TEST_TEMP_DIR/acli" <<'EOF'
#!/bin/bash
# Mock acli for testing
case "$1" in
    jira)
        case "$2" in
            project)
                if [ "$3" = "view" ]; then
                    echo "Project: PROJ"
                    echo "Name: Test Project"
                    exit 0
                fi
                ;;
            issue)
                if [ "$3" = "create" ]; then
                    echo "PROJ-123"
                    exit 0
                fi
                ;;
        esac
        ;;
esac
exit 0
EOF
    chmod +x "$TEST_TEMP_DIR/acli"
    export PATH="$TEST_TEMP_DIR:$PATH"
}

# Assert file exists
assert_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "FAIL: File does not exist: $file"
        return 1
    fi
    return 0
}

# Assert directory exists
assert_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "FAIL: Directory does not exist: $dir"
        return 1
    fi
    return 0
}

# Assert file contains text
assert_file_contains() {
    local file="$1"
    local text="$2"
    if ! grep -q "$text" "$file" 2>/dev/null; then
        echo "FAIL: File $file does not contain: $text"
        return 1
    fi
    return 0
}

# Assert string contains text
assert_contains() {
    local string="$1"
    local text="$2"
    if ! echo "$string" | grep -q "$text" 2>/dev/null; then
        echo "FAIL: String does not contain: $text"
        return 1
    fi
    return 0
}

# Assert command succeeds
assert_success() {
    local cmd="$1"
    if ! eval "$cmd" >/dev/null 2>&1; then
        echo "FAIL: Command failed: $cmd"
        return 1
    fi
    return 0
}

# Assert command fails
assert_failure() {
    local cmd="$1"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "FAIL: Command should have failed: $cmd"
        return 1
    fi
    return 0
}

# Count lines in file
count_lines() {
    local file="$1"
    wc -l < "$file" | tr -d ' '
}

# Run pipeline stage and capture output
run_pipeline() {
    local stage="$1"
    shift

    if [ -z "$PROJECT_ROOT" ] || [ ! -f "$PROJECT_ROOT/pipeline.sh" ]; then
        echo "ERROR: PROJECT_ROOT not set or pipeline.sh not found" >&2
        return 1
    fi

    bash "$PROJECT_ROOT/pipeline.sh" "$stage" "$@" 2>&1
}
