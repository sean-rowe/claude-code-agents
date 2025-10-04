# API Reference

Complete technical reference for the Claude Code Agents Pipeline.

## Table of Contents

1. [CLI Commands](#cli-commands)
2. [State Schema](#state-schema)
3. [Integration Points](#integration-points)
4. [Security Functions](#security-functions)
5. [Error Codes](#error-codes)
6. [Environment Variables](#environment-variables)

---

## CLI Commands

### `pipeline.sh init`

**Description:** Initialize a new pipeline in the current directory.

**Usage:**
```bash
pipeline.sh init [options]
```

**Options:**
- `--dry-run` - Preview actions without making changes
- `--verbose` - Enable debug logging
- `--no-color` - Disable colored output

**Behavior:**
1. Creates `.pipeline/` directory structure
2. Initializes `state.json` with default values
3. Creates subdirectories: `exports/`, `features/`, `work/`
4. Validates directory permissions

**Exit Codes:**
- `0` - Success
- `1` - Invalid arguments
- `13` - Permission denied

**Example:**
```bash
cd /path/to/project
pipeline.sh init --verbose
```

**Output:**
```
STAGE: init
STEP: 1 of 3
ACTION: Creating .pipeline directory
✓ Created .pipeline/
✓ Initialized state.json
RESULT: Pipeline initialized
NEXT: Run './pipeline.sh requirements "description"'
```

---

### `pipeline.sh requirements`

**Description:** Generate requirements document from natural language description.

**Usage:**
```bash
pipeline.sh requirements "USER_REQUIREMENTS" [options]
```

**Arguments:**
- `USER_REQUIREMENTS` (required) - Natural language description of what to build

**Options:**
- `--dry-run` - Preview without creating files
- `--verbose` - Enable debug logging

**Behavior:**
1. Validates requirements are not empty
2. Sanitizes input to prevent injection attacks
3. Creates `.pipeline/requirements.md` with structured format
4. Updates state to `requirements` stage
5. Outputs next step instructions

**Exit Codes:**
- `0` - Success
- `1` - Invalid arguments (empty requirements)
- `2` - Dependency missing (markdown processor)

**Example:**
```bash
pipeline.sh requirements "User authentication with email and password, JWT tokens, password reset flow"
```

**Output File:** `.pipeline/requirements.md`
```markdown
# Requirements

## User Story
As a developer, I need user authentication with email and password, JWT tokens, password reset flow

## Functional Requirements
- User registration with email/password
- JWT token generation and validation
- Password reset via email
...
```

---

### `pipeline.sh gherkin`

**Description:** Generate BDD feature files from requirements.

**Usage:**
```bash
pipeline.sh gherkin [options]
```

**Options:**
- `--dry-run` - Preview without creating files
- `--verbose` - Enable debug logging

**Prerequisites:**
- Must have run `requirements` stage first
- `.pipeline/requirements.md` must exist

**Behavior:**
1. Reads `.pipeline/requirements.md`
2. Extracts functional requirements
3. Generates Gherkin scenarios for each requirement
4. Creates `.pipeline/features/*.feature` files
5. Updates state to `gherkin` stage

**Exit Codes:**
- `0` - Success
- `5` - State error (requirements not run first)
- `6` - Missing file (requirements.md not found)

**Example:**
```bash
pipeline.sh gherkin --verbose
```

**Output Files:**
- `.pipeline/features/authentication.feature`
- `.pipeline/features/authorization.feature`
- `.pipeline/features/data.feature`

**Feature File Format:**
```gherkin
Feature: User Authentication
  As a user
  I want to authenticate with email and password
  So that I can access protected resources

  Scenario: Successful login
    Given a registered user with email "user@example.com"
    When the user logs in with correct password
    Then the user receives a JWT token
    And the token is valid for 24 hours
```

---

### `pipeline.sh stories`

**Description:** Generate JIRA stories from Gherkin features.

**Usage:**
```bash
pipeline.sh stories [options]
```

**Options:**
- `--dry-run` - Preview without creating files
- `--verbose` - Enable debug logging

**Prerequisites:**
- Must have run `gherkin` stage first
- `.pipeline/features/*.feature` files must exist

**Behavior:**
1. Scans `.pipeline/features/` directory
2. Creates JIRA project structure (Epic + Stories)
3. Generates CSV import file
4. Creates hierarchy JSON
5. Updates state with Epic ID and Story IDs

**Exit Codes:**
- `0` - Success
- `5` - State error (gherkin not run first)
- `6` - Missing files (no feature files)

**Optional Dependencies:**
- `acli` - Atlassian CLI for JIRA integration

**Example:**
```bash
pipeline.sh stories
```

**Output Files:**
- `.pipeline/exports/jira_import.csv`
- `.pipeline/exports/jira_hierarchy.json`

**CSV Format:**
```csv
Issue Type,Summary,Description,Epic Link,Parent,Project Key,Status
Epic,"Initiative","From requirements.md","","","PROJ","Created"
Story,"Feature: Authentication","From authentication.feature","PROJ-1","","PROJ","Created"
Story,"Feature: Authorization","From authorization.feature","PROJ-1","","PROJ","Created"
```

**Hierarchy JSON:**
```json
{
  "epicId": "PROJ-1",
  "stories": ["PROJ-2", "PROJ-3", "PROJ-4"],
  "createdAt": "2025-10-04T12:34:56Z",
  "files": {
    "requirements": ".pipeline/requirements.md",
    "features": ".pipeline/features/",
    "csvExport": ".pipeline/exports/jira_import.csv"
  }
}
```

---

### `pipeline.sh work STORY-ID`

**Description:** Implement a specific story with TDD workflow.

**Usage:**
```bash
pipeline.sh work STORY-ID [options]
```

**Arguments:**
- `STORY-ID` (required) - JIRA story ID (format: PROJECT-123)

**Options:**
- `--dry-run` - Preview without making changes
- `--verbose` - Enable debug logging

**Prerequisites:**
- Must have run `stories` stage first
- Valid JIRA story ID

**Behavior:**
1. **Validates story ID** (security hardened):
   - Checks format: `^[A-Za-z0-9_\-]+$`
   - Max 64 characters
   - Must contain hyphen and end with numbers
   - Blocks path traversal (`..`, `/`)
   - Blocks command injection (`;`, `|`, `&`, etc.)

2. **Acquires file lock** (concurrent protection):
   - Creates `.pipeline/pipeline.lock` atomically
   - 30-second timeout with stale lock detection
   - Auto-cleanup on exit/interrupt

3. **Validates state**:
   - Checks `.pipeline/state.json` exists
   - Validates JSON schema with `jq`
   - Ensures `stories` array exists

4. **Creates feature branch**:
   - Format: `feature/STORY-ID`
   - Auto-checkout if exists

5. **Generates tests** (TDD Red phase):
   - Detects project type (Node.js, Python, Go, Bash)
   - Creates failing tests based on story requirements
   - Uses appropriate test framework

6. **Generates implementation** (TDD Green phase):
   - Minimal code to pass tests
   - Follows project conventions
   - Runs tests to verify

**Supported Project Types:**

| Type | Detection | Test Framework | Test File Pattern |
|------|-----------|----------------|-------------------|
| Node.js | `package.json` | Jest | `src/*.test.js` |
| Python | `requirements.txt` or `pyproject.toml` | pytest | `tests/test_*.py` |
| Go | `go.mod` | testing | `*_test.go` |
| Bash | `*.sh` files | Custom | `tests/*.bats` |

**Exit Codes:**
- `0` - Success
- `1` - Invalid story ID format
- `5` - State error (stories not run first)
- `7` - State corruption
- `8` - Timeout (lock acquisition failed)

**Security Validations:**

```bash
# ✓ Valid story IDs
pipeline.sh work PROJ-123
pipeline.sh work AUTH-42
pipeline.sh work feature_user_login-001

# ✗ Invalid (blocked)
pipeline.sh work "PROJ-123; rm -rf /"     # Command injection
pipeline.sh work "../../../etc/passwd"     # Path traversal
pipeline.sh work "PROJ-$(whoami)"          # Command substitution
pipeline.sh work "PROJ-123@#$"             # Invalid characters
```

**Example:**
```bash
pipeline.sh work PROJ-2 --verbose
```

**Output:**
```
STAGE: work
STEP: 1 of 6
ACTION: Working on story: PROJ-2

STEP: 2 of 6
ACTION: Creating feature branch
✓ Branch created: feature/PROJ-2

STEP: 3 of 6
ACTION: Writing tests (TDD Red phase)
✓ Created test file: src/proj_2.test.js

STEP: 4 of 6
ACTION: Running tests (should fail)
✗ Tests failed (expected - Red phase)

STEP: 5 of 6
ACTION: Generating implementation
✓ Created: src/proj_2.js

STEP: 6 of 6
ACTION: Running tests again
✓ Tests passed (Green phase)

RESULT: Story PROJ-2 implemented
NEXT: Run './pipeline.sh complete PROJ-2'
```

**Lock File Structure:**
```
.pipeline/pipeline.lock/
└── pid          # Contains process ID
```

---

### `pipeline.sh complete STORY-ID`

**Description:** Complete a story by running tests and creating PR.

**Usage:**
```bash
pipeline.sh complete STORY-ID [options]
```

**Arguments:**
- `STORY-ID` (required) - JIRA story ID to complete

**Options:**
- `--dry-run` - Preview without pushing/creating PR
- `--verbose` - Enable debug logging

**Prerequisites:**
- Must have run `work STORY-ID` first
- Tests must pass
- Git repository must be initialized

**Behavior:**
1. Validates story ID (same security checks as `work`)
2. Runs full test suite
3. Commits changes with structured message
4. Pushes feature branch to remote
5. Creates GitHub/GitLab pull request
6. Updates JIRA story status (if `acli` available)
7. Updates state to `complete`

**Exit Codes:**
- `0` - Success
- `1` - Invalid story ID
- `4` - Tests failed
- `5` - State error
- `9` - Git error (push failed)

**Example:**
```bash
pipeline.sh complete PROJ-2
```

**Commit Message Format:**
```
feat(PROJ-2): Implement user authentication

- Add login endpoint with JWT tokens
- Add password validation
- Add user registration flow

Tests: ✓ 12 passed
Coverage: 95%

Closes PROJ-2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**PR Creation:**
```bash
gh pr create \
  --title "feat(PROJ-2): Implement user authentication" \
  --body "$(cat <<EOF
## Summary
- Implemented login endpoint with JWT tokens
- Added password validation
- Added user registration flow

## Test Results
✓ 12 tests passed
✓ 95% code coverage

## Story
Closes PROJ-2

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

### `pipeline.sh status`

**Description:** Show current pipeline status and next steps.

**Usage:**
```bash
pipeline.sh status [options]
```

**Options:**
- `--verbose` - Show detailed state information
- `--json` - Output as JSON

**Output:**
```
Pipeline Status
===============

Current Stage: work
Current Story: PROJ-2
Branch: feature/PROJ-2
Epic ID: PROJ-1

Stories:
  ✓ PROJ-2 (completed)
  ○ PROJ-3 (pending)
  ○ PROJ-4 (pending)

Files:
  Requirements: .pipeline/requirements.md
  Features: .pipeline/features/ (3 files)
  Tests: src/ (1 test file)

Next Steps:
  1. Run './pipeline.sh complete PROJ-2'
  2. Or work on: PROJ-3, PROJ-4
```

**JSON Output (`--json`):**
```json
{
  "stage": "work",
  "currentStory": "PROJ-2",
  "branch": "feature/PROJ-2",
  "epicId": "PROJ-1",
  "stories": [
    {"id": "PROJ-2", "status": "in_progress"},
    {"id": "PROJ-3", "status": "pending"},
    {"id": "PROJ-4", "status": "pending"}
  ],
  "files": {
    "requirements": ".pipeline/requirements.md",
    "features": 3,
    "tests": 1
  }
}
```

---

## State Schema

### `.pipeline/state.json`

**Description:** Persistent state file tracking pipeline progress.

**Location:** `.pipeline/state.json`

**Schema:**
```json
{
  "stage": "string",           // Current pipeline stage
  "epicId": "string",          // JIRA Epic ID (PROJ-1)
  "currentStory": "string",    // Active story ID (PROJ-2)
  "branch": "string",          // Git branch name
  "stories": [                 // All stories from Epic
    {
      "id": "string",          // Story ID (PROJ-2)
      "status": "string",      // pending|in_progress|completed
      "feature": "string",     // Feature file path
      "createdAt": "string"    // ISO 8601 timestamp
    }
  ],
  "createdAt": "string",       // Pipeline init timestamp
  "updatedAt": "string"        // Last update timestamp
}
```

**Validation Rules:**

1. **stage** (required):
   - Enum: `init`, `requirements`, `gherkin`, `stories`, `work`, `complete`
   - Must follow linear progression (cannot skip stages)

2. **epicId** (optional):
   - Format: `^[A-Z]+-[0-9]+$`
   - Set during `stories` stage

3. **currentStory** (optional):
   - Format: `^[A-Z]+-[0-9]+$`
   - Must exist in `stories` array
   - Set during `work` stage

4. **branch** (optional):
   - Format: `feature/STORY-ID`
   - Set during `work` stage

5. **stories** (required):
   - Array of story objects
   - Must have at least one entry after `stories` stage

**Example State Progression:**

**After `init`:**
```json
{
  "stage": "init",
  "stories": [],
  "createdAt": "2025-10-04T10:00:00Z",
  "updatedAt": "2025-10-04T10:00:00Z"
}
```

**After `stories`:**
```json
{
  "stage": "stories",
  "epicId": "PROJ-1",
  "stories": [
    {
      "id": "PROJ-2",
      "status": "pending",
      "feature": ".pipeline/features/authentication.feature",
      "createdAt": "2025-10-04T10:15:00Z"
    }
  ],
  "createdAt": "2025-10-04T10:00:00Z",
  "updatedAt": "2025-10-04T10:15:00Z"
}
```

**After `work PROJ-2`:**
```json
{
  "stage": "work",
  "epicId": "PROJ-1",
  "currentStory": "PROJ-2",
  "branch": "feature/PROJ-2",
  "stories": [
    {
      "id": "PROJ-2",
      "status": "in_progress",
      "feature": ".pipeline/features/authentication.feature",
      "createdAt": "2025-10-04T10:15:00Z"
    }
  ],
  "createdAt": "2025-10-04T10:00:00Z",
  "updatedAt": "2025-10-04T10:30:00Z"
}
```

### State Validation Functions

**validate_json()**
```bash
# Validates JSON syntax
validate_json ".pipeline/state.json"
# Returns: 0 (valid) or 1 (invalid)
```

**validate_json_schema()**
```bash
# Validates JSON schema structure
validate_json_schema ".pipeline/state.json" "stories"
# Checks: 'stories' key exists and is an array
# Returns: 0 (valid) or 1 (invalid)
```

---

## Integration Points

### JIRA Integration (via acli)

**Installation:**
```bash
# Download from Atlassian
# https://bobswift.atlassian.net/wiki/spaces/ACLI/overview

# Or use Docker
docker run --rm -it bobswift/atlassian-cli:latest
```

**Commands Used:**

1. **Check Project:**
```bash
acli jira project view --key PROJ
```

2. **Create Project:**
```bash
acli jira project create --from-json jira-scrum-project.json
```

3. **Create Issues:**
```bash
acli jira issue create \
  --project PROJ \
  --type Epic \
  --summary "User Authentication" \
  --description "From requirements.md"
```

4. **Update Status:**
```bash
acli jira issue transition \
  --issue PROJ-2 \
  --transition "In Progress"
```

**Fallback Behavior:**
- If `acli` not installed, pipeline creates mock JIRA data
- CSV export still generated for manual import
- Hierarchy JSON still created for tracking

---

### Git/GitHub Integration

**Required Tools:**
- `git` (required)
- `gh` (GitHub CLI - optional but recommended)

**Git Operations:**

1. **Branch Creation:**
```bash
git checkout -b feature/PROJ-2
```

2. **Commit:**
```bash
git add .
git commit -m "feat(PROJ-2): Implement feature"
```

3. **Push:**
```bash
git push -u origin feature/PROJ-2
```

**GitHub PR Creation:**
```bash
gh pr create \
  --title "feat(PROJ-2): Title" \
  --body "Description\n\nCloses PROJ-2"
```

**Fallback (no gh CLI):**
```bash
# Pipeline outputs PR creation URL
echo "Create PR manually at:"
echo "https://github.com/user/repo/compare/feature/PROJ-2?expand=1"
```

---

### Test Framework Integration

#### Jest (Node.js)

**Detection:** `package.json` exists

**Test Command:**
```bash
npm test
```

**Test File Format:**
```javascript
// src/story_name.test.js
describe('STORY-ID', () => {
  it('should implement feature', () => {
    const result = require('./story_name');
    expect(result).toBeDefined();
  });
});
```

**Coverage:**
```bash
npm test -- --coverage
```

---

#### pytest (Python)

**Detection:** `requirements.txt` or `pyproject.toml` exists

**Test Command:**
```bash
pytest tests/
```

**Test File Format:**
```python
# tests/test_story_name.py
def test_story_feature():
    from src.story_name import implement
    result = implement()
    assert result is not None
```

**Coverage:**
```bash
pytest --cov=src tests/
```

---

#### Go testing

**Detection:** `go.mod` exists

**Test Command:**
```bash
go test ./...
```

**Test File Format:**
```go
// story_name_test.go
package main

import "testing"

func TestStoryFeature(t *testing.T) {
    result := ImplementFeature()
    if result == nil {
        t.Error("Expected result")
    }
}
```

**Coverage:**
```bash
go test -cover ./...
```

---

#### Bash (bats)

**Detection:** `*.sh` files exist

**Test Command:**
```bash
bats tests/*.bats
```

**Test File Format:**
```bash
#!/usr/bin/env bats
# tests/story_name.bats

@test "feature works" {
  run ./story_name.sh
  [ "$status" -eq 0 ]
  [ "$output" = "expected" ]
}
```

---

## Security Functions

### Input Validation

#### `validate_story_id(story_id)`

**Purpose:** Validate and sanitize JIRA story IDs to prevent injection attacks.

**Security Checks:**
1. **Empty Check:** Rejects empty/null values
2. **Length Limit:** Max 64 characters (DoS prevention)
3. **Format Validation:** `^[A-Za-z0-9_\-]+$` (alphanumeric + hyphens/underscores)
4. **Pattern Check:** Must contain hyphen and end with numbers
5. **Path Traversal:** Blocks `..` and `/` characters
6. **Command Injection:** Regex blocks shell metacharacters

**Usage:**
```bash
if validate_story_id "$STORY_ID"; then
  echo "Valid"
else
  exit $E_INVALID_ARGS
fi
```

**Examples:**
```bash
validate_story_id "PROJ-123"       # ✓ Valid
validate_story_id "AUTH-42"        # ✓ Valid
validate_story_id ""               # ✗ Empty
validate_story_id "PROJ-123;rm"    # ✗ Command injection
validate_story_id "../etc/passwd"  # ✗ Path traversal
```

**Error Messages:**
```
Story ID is required and cannot be empty
Story ID too long (max 64 characters): 100 characters
Invalid story ID format: 'PROJ@123'. Must contain only letters, numbers, hyphens, and underscores
Invalid story ID format: 'PROJ123'. Expected format: PROJECT-123
Story ID contains invalid characters (path traversal attempt?): ../PROJ-1
```

---

#### `sanitize_input(input)`

**Purpose:** Remove dangerous characters from user input.

**Sanitization Rules:**
1. Strips shell metacharacters: `; | & $ ( ) < > \` ' "`
2. Removes control characters
3. Trims whitespace
4. Preserves alphanumeric, hyphens, underscores, dots

**Usage:**
```bash
SAFE_INPUT=$(sanitize_input "$USER_INPUT")
```

**Examples:**
```bash
sanitize_input "PROJ-123"          # → "PROJ-123"
sanitize_input "PROJ-123; rm -rf"  # → "PROJ-123 rm -rf"
sanitize_input "test$(whoami)"     # → "testwhoami"
```

---

#### `validate_safe_path(path)`

**Purpose:** Validate file paths to prevent path traversal attacks.

**Security Checks:**
1. Rejects absolute paths (must be relative)
2. Blocks `..` sequences
3. Blocks paths starting with `/` or `~/`
4. Ensures path stays within project directory

**Usage:**
```bash
if validate_safe_path "$FILE_PATH"; then
  cat "$FILE_PATH"
else
  echo "Unsafe path rejected"
fi
```

**Examples:**
```bash
validate_safe_path ".pipeline/state.json"  # ✓ Valid
validate_safe_path "src/file.js"           # ✓ Valid
validate_safe_path "../../../etc/passwd"   # ✗ Path traversal
validate_safe_path "/etc/passwd"           # ✗ Absolute path
validate_safe_path "~/config"              # ✗ Home expansion
```

---

### File Locking (Concurrent Access Protection)

#### `acquire_lock(lock_file, timeout)`

**Purpose:** Acquire exclusive lock to prevent concurrent pipeline executions.

**Algorithm:**
1. Attempt atomic directory creation (`mkdir`)
2. Write process ID to `lock_file/pid`
3. Retry with exponential backoff if locked
4. Check for stale locks (process no longer exists)
5. Remove stale locks automatically
6. Timeout after N seconds

**Parameters:**
- `lock_file` - Lock file path (default: `.pipeline/pipeline.lock`)
- `timeout` - Max wait time in seconds (default: 30)

**Usage:**
```bash
if acquire_lock ".pipeline/pipeline.lock" 30; then
  trap 'release_lock ".pipeline/pipeline.lock"' EXIT INT TERM
  # ... do work ...
else
  echo "Failed to acquire lock"
  exit $E_TIMEOUT
fi
```

**Lock Detection:**
```bash
# Stale lock cleanup
if [ -f "$lock_file/pid" ]; then
  LOCK_PID=$(cat "$lock_file/pid")
  if ! kill -0 "$LOCK_PID" 2>/dev/null; then
    # Process dead, remove stale lock
    rm -rf "$lock_file"
  fi
fi
```

**Exit Codes:**
- `0` - Lock acquired
- `8` - Timeout (lock held by another process)

---

#### `release_lock(lock_file)`

**Purpose:** Release exclusive lock.

**Behavior:**
1. Verifies lock owned by current process
2. Removes lock directory atomically
3. Logs lock release

**Usage:**
```bash
release_lock ".pipeline/pipeline.lock"
```

**Auto-Release:**
```bash
# Ensure lock released on any exit
trap 'release_lock ".pipeline/pipeline.lock"' EXIT INT TERM
```

---

### JSON Validation

#### `validate_json(file)`

**Purpose:** Validate JSON syntax.

**Method:**
- Uses `jq` to parse JSON
- Returns error if invalid syntax

**Usage:**
```bash
if validate_json ".pipeline/state.json"; then
  echo "Valid JSON"
else
  echo "Corrupted JSON file"
  exit $E_STATE_CORRUPTION
fi
```

---

#### `validate_json_schema(file, required_key)`

**Purpose:** Validate JSON schema structure.

**Method:**
- Checks if required key exists
- Validates key is correct type (array/object)

**Usage:**
```bash
if validate_json_schema ".pipeline/state.json" "stories"; then
  echo "Schema valid"
else
  echo "Missing 'stories' key"
  exit $E_STATE_CORRUPTION
fi
```

**Examples:**
```bash
# Check for 'stories' array
validate_json_schema ".pipeline/state.json" "stories"

# Check for 'stage' field
validate_json_schema ".pipeline/state.json" "stage"
```

---

## Error Codes

**Exit Code Constants:**

| Code | Constant | Description |
|------|----------|-------------|
| 0 | E_SUCCESS | Success |
| 1 | E_GENERIC | Generic error |
| 2 | E_INVALID_ARGS | Invalid arguments |
| 3 | E_MISSING_DEPENDENCY | Required dependency not found |
| 4 | E_NETWORK_FAILURE | Network/API call failed |
| 5 | E_STATE_CORRUPTION | State file corrupted |
| 6 | E_FILE_NOT_FOUND | Required file missing |
| 7 | E_PERMISSION_DENIED | Permission denied |
| 8 | E_TIMEOUT | Operation timeout |

**Error Handling:**

```bash
# Exit with error code
log_error "Invalid story ID" $E_INVALID_ARGS
exit $E_INVALID_ARGS

# Retry on network errors
if ! retry_command $MAX_RETRIES "acli jira project view"; then
  log_error "Network error" $E_NETWORK_FAILURE
  exit $E_NETWORK_FAILURE
fi
```

**Logging Functions:**

```bash
# Error (red, to stderr)
log_error "message" $ERROR_CODE

# Warning (yellow)
log_warn "message"

# Info (blue)
log_info "message"

# Debug (only with --verbose)
log_debug "message"
```

---

## Environment Variables

### Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VERBOSE` | `0` | Verbose logging (1=enabled) |
| `DEBUG` | `0` | Debug mode (1=enabled) |
| `DRY_RUN` | `0` | Dry-run mode (1=enabled) |
| `LOG_FILE` | `.pipeline/errors.log` | Error log file location |
| `MAX_RETRIES` | `3` | Network retry attempts |
| `RETRY_DELAY` | `2` | Seconds between retry attempts |
| `OPERATION_TIMEOUT` | `300` | Timeout for long operations (seconds) |

### Usage

**Set via environment:**
```bash
export VERBOSE=1
export DRY_RUN=1
pipeline.sh work PROJ-2
```

**Set via CLI flags:**
```bash
pipeline.sh work PROJ-2 --verbose --dry-run
```

**Programmatic access:**
```bash
if [ "$VERBOSE" -eq 1 ]; then
  log_debug "Debug message"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  log_info "[DRY-RUN] Would execute command"
  exit 0
fi
```

### Color Output

**Color constants used in pipeline output:**
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

echo -e "${GREEN}✓ Success${NC}"
echo -e "${RED}✗ Error${NC}"
```

**Note:** Color output is always enabled. To suppress colors, redirect output or use a terminal that doesn't support ANSI codes.

---

## Retry Logic

**retry_command(max_retries, command)**

**Purpose:** Retry network/API commands with exponential backoff.

**Algorithm:**
1. Execute command
2. If success (exit 0), return immediately
3. If failure, wait with exponential backoff
4. Retry up to `max_retries` times
5. Log each retry attempt

**Usage:**
```bash
if retry_command 3 "acli jira project view --key PROJ"; then
  echo "Command succeeded"
else
  log_error "Command failed after 3 retries" $E_NETWORK_ERROR
fi
```

**Backoff Schedule:**
- Attempt 1: Execute immediately
- Attempt 2: Wait 2s, execute
- Attempt 3: Wait 4s, execute
- Attempt N: Wait 2^(N-1) seconds

**Example Output:**
```
Executing: acli jira project view --key PROJ
Error: Network timeout
Retrying in 2 seconds... (attempt 2/3)
Executing: acli jira project view --key PROJ
Error: Network timeout
Retrying in 4 seconds... (attempt 3/3)
Executing: acli jira project view --key PROJ
✓ Success
```

---

## File Structure Reference

```
.pipeline/
├── state.json                    # Pipeline state
├── requirements.md               # Requirements document
├── features/                     # Gherkin feature files
│   ├── authentication.feature
│   ├── authorization.feature
│   └── data.feature
├── exports/                      # JIRA export files
│   ├── jira_import.csv
│   └── jira_hierarchy.json
├── work/                         # Work artifacts
│   └── story_artifacts/
├── pipeline.lock/                # Concurrent access lock
│   └── pid                       # Lock owner process ID
└── logs/                         # Optional logs
    └── pipeline.log
```

---

## API Stability

**Versioning:** Semantic versioning (MAJOR.MINOR.PATCH)

**Current Version:** 1.7.0

**Stability Guarantees:**

1. **CLI Interface (Stable):**
   - Command names will not change
   - Required arguments will not be removed
   - Exit codes will remain consistent

2. **State Schema (Stable):**
   - Existing keys will not be removed
   - New optional keys may be added
   - Migration scripts provided for breaking changes

3. **File Locations (Stable):**
   - `.pipeline/` directory structure
   - Output file paths and formats

4. **Integration Points (Semi-Stable):**
   - JIRA/acli integration may evolve
   - Test framework detection may expand
   - New project types may be added

**Deprecation Policy:**
- Deprecated features marked in changelog
- 2 minor version grace period before removal
- Migration guides provided

---

## Troubleshooting

See [USER_GUIDE.md](USER_GUIDE.md#troubleshooting) for common issues and solutions.

For API-specific issues:

1. **State corruption:**
   ```bash
   # Validate state
   jq . .pipeline/state.json

   # Reinitialize if needed
   rm -rf .pipeline
   pipeline.sh init
   ```

2. **Lock timeout:**
   ```bash
   # Check lock owner
   cat .pipeline/pipeline.lock/pid

   # Remove stale lock
   rm -rf .pipeline/pipeline.lock
   ```

3. **Validation errors:**
   ```bash
   # Test story ID validation
   pipeline.sh work "PROJ-123" --verbose

   # Check logs for detailed error
   ```

---

## Related Documentation

- [User Guide](USER_GUIDE.md) - Step-by-step tutorials and examples
- [PRODUCTION_READINESS_ASSESSMENT.md](../PRODUCTION_READINESS_ASSESSMENT.md) - Production checklist
- [Edge Case Tests](../tests/edge_cases/) - Security and robustness tests
