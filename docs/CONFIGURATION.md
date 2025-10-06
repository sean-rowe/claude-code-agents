# Configuration Guide - Claude Code Agents Pipeline

**Version:** 1.0.0
**Last Updated:** 2025-10-05

---

## Table of Contents

1. [Overview](#overview)
2. [Environment Variables](#environment-variables)
3. [Command-Line Flags](#command-line-flags)
4. [State File Configuration](#state-file-configuration)
5. [Project Configuration](#project-configuration)
6. [JIRA Configuration](#jira-configuration)
7. [Git Configuration](#git-configuration)
8. [Language Detection](#language-detection)
9. [Advanced Configuration](#advanced-configuration)
10. [Configuration Examples](#configuration-examples)

---

## Overview

The Claude Code Agents Pipeline can be configured through multiple methods:

1. **Configuration Files** - `.pipelinerc` (global and project-level)
2. **Environment Variables** - Global settings
3. **Command-Line Flags** - Per-execution settings
4. **State File** - Pipeline state and story data
5. **Project Files** - Language and framework detection

**Priority Order** (highest to lowest):
```
Command-Line Flags > Environment Variables > Project .pipelinerc > Global .pipelinerc > Default Values
```

**Configuration File Locations:**
```
1. ~/.claude/.pipelinerc    (global config, applies to all projects)
2. ./.pipelinerc            (project config, overrides global)
```

---

## Configuration Files (.pipelinerc)

### Overview

The `.pipelinerc` file allows you to set configuration values without using environment variables. This is more convenient for persistent project settings.

**Format:** Shell script syntax (bash)

### Creating a Configuration File

**Project-level config (recommended for project-specific settings):**
```bash
# Copy example file
cp .pipelinerc.example .pipelinerc

# Edit as needed
nano .pipelinerc
```

**Global config (recommended for personal preferences):**
```bash
# Create directory if needed
mkdir -p ~/.claude

# Create config
nano ~/.claude/.pipelinerc
```

### Example Configuration

**`.pipelinerc` for development:**
```bash
# Development configuration
VERBOSE=1
DEBUG=1
SKIP_GIT_PUSH=1
MAX_RETRIES=3
```

**`.pipelinerc` for production:**
```bash
# Production configuration
VERBOSE=0
DEBUG=0
MAX_RETRIES=10
RETRY_DELAY=5
OPERATION_TIMEOUT=900
JIRA_PROJECT=PROD
```

**Global `~/.claude/.pipelinerc` for personal preferences:**
```bash
# Personal preferences
VERBOSE=1
GIT_MAIN_BRANCH=main
```

### How Config Files Work

1. **Global config loaded first:** `~/.claude/.pipelinerc`
2. **Project config loaded second:** `./.pipelinerc` (overrides global)
3. **Environment variables override config files**
4. **Command-line flags override everything**

**Example:**
```bash
# ~/.claude/.pipelinerc
VERBOSE=1
MAX_RETRIES=3

# ./.pipelinerc (current project)
MAX_RETRIES=5
JIRA_PROJECT=MYAPP

# Command line
export VERBOSE=0
pipeline.sh work PROJ-1

# Result:
# VERBOSE=0 (from environment variable)
# MAX_RETRIES=5 (from project .pipelinerc)
# JIRA_PROJECT=MYAPP (from project .pipelinerc)
```

### Available Settings

All environment variables can be set in `.pipelinerc`. See the [Environment Variables](#environment-variables) section for a complete list.

### Security Considerations

**DO NOT** commit `.pipelinerc` files containing sensitive data (API tokens, passwords).

**Add to `.gitignore`:**
```bash
echo ".pipelinerc" >> .gitignore
```

**For team sharing:**
- Commit `.pipelinerc.example` with safe defaults
- Keep actual `.pipelinerc` local and gitignored

---

## Environment Variables

### Core Settings

#### `VERBOSE`
**Description:** Enable verbose output
**Type:** Boolean (0 or 1)
**Default:** `0`
**Example:**
```bash
export VERBOSE=1
pipeline.sh work PROJ-1
```

**Output When Enabled:**
```
[INFO] Acquiring lock for concurrent access protection
[INFO] Lock acquired successfully
[INFO] Validating story ID format
[INFO] Creating feature branch: feature/PROJ-1
```

---

#### `DEBUG`
**Description:** Enable debug mode (very detailed logs)
**Type:** Boolean (0 or 1)
**Default:** `0`
**Example:**
```bash
export DEBUG=1
pipeline.sh work PROJ-1
```

**Output When Enabled:**
```
[DEBUG] Function called: validate_story_id("PROJ-1")
[DEBUG] Regex match: PROJ-1 matches ^[A-Z]+-[0-9]+$
[DEBUG] Story ID validation passed
[DEBUG] Executing: git checkout -b feature/PROJ-1
[DEBUG] Git command succeeded with exit code 0
```

**Note:** `DEBUG=1` automatically enables `VERBOSE=1`

---

#### `DRY_RUN`
**Description:** Preview mode - show what would happen without executing
**Type:** Boolean (0 or 1)
**Default:** `0`
**Example:**
```bash
export DRY_RUN=1
pipeline.sh work PROJ-1
```

**Output:**
```
[DRY-RUN] Would acquire lock: .pipeline/pipeline.lock
[DRY-RUN] Would create branch: feature/PROJ-1
[DRY-RUN] Would generate test file: tests/proj_1.test.js
[DRY-RUN] Would generate implementation: src/proj_1.js
[DRY-RUN] Would commit changes
[DRY-RUN] Would push to remote: origin feature/PROJ-1
```

**Use Cases:**
- Testing pipeline changes
- Verifying what will happen before running
- Debugging complex workflows

---

### Network & Retry Settings

#### `MAX_RETRIES`
**Description:** Number of retry attempts for network operations
**Type:** Integer (1-10)
**Default:** `3`
**Example:**
```bash
export MAX_RETRIES=5
pipeline.sh work PROJ-1
```

**Applies To:**
- Git push operations
- JIRA API calls
- External network requests

---

#### `RETRY_DELAY`
**Description:** Delay (in seconds) between retry attempts
**Type:** Integer (1-60)
**Default:** `2`
**Example:**
```bash
export RETRY_DELAY=5
pipeline.sh work PROJ-1
```

**Behavior:**
```
Attempt 1: Immediate
Attempt 2: Wait 5 seconds
Attempt 3: Wait 5 seconds
...
```

---

#### `OPERATION_TIMEOUT`
**Description:** Maximum time (in seconds) for long operations
**Type:** Integer (30-3600)
**Default:** `300` (5 minutes)
**Example:**
```bash
export OPERATION_TIMEOUT=600
pipeline.sh work PROJ-1
```

**Applies To:**
- Test execution
- Git operations
- Code generation

**Recommended Values:**
- Simple projects: `300` (5 minutes)
- Large codebases: `600` (10 minutes)
- Complex tests: `900` (15 minutes)

---

### JIRA Integration

#### `JIRA_PROJECT`
**Description:** Default JIRA project key
**Type:** String (uppercase letters)
**Default:** `PROJ`
**Example:**
```bash
export JIRA_PROJECT=MYAPP
pipeline.sh stories
```

**Story IDs Generated:**
```
MYAPP-1, MYAPP-2, MYAPP-3, ...
```

---

#### `JIRA_URL`
**Description:** JIRA instance URL
**Type:** URL
**Default:** (none - uses acli configuration)
**Example:**
```bash
export JIRA_URL=https://company.atlassian.net
```

---

#### `JIRA_USER`
**Description:** JIRA username
**Type:** String
**Default:** (none - uses acli configuration)
**Example:**
```bash
export JIRA_USER=user@company.com
```

**Note:** Better to use `acli jira login` than environment variables for security

---

### Git Integration

#### `SKIP_GIT_PUSH`
**Description:** Skip git push step (useful for slow networks)
**Type:** Boolean (0 or 1)
**Default:** `0`
**Example:**
```bash
export SKIP_GIT_PUSH=1
pipeline.sh work PROJ-1
```

**Behavior:**
- Commits created locally
- Branches created
- No push to remote
- Manual push required: `git push -u origin feature/PROJ-1`

---

#### `GIT_BRANCH_PREFIX`
**Description:** Prefix for feature branches
**Type:** String
**Default:** `feature/`
**Example:**
```bash
export GIT_BRANCH_PREFIX="story/"
pipeline.sh work PROJ-1
# Creates: story/PROJ-1
```

**Common Patterns:**
- `feature/` - Feature development (default)
- `bugfix/` - Bug fixes
- `story/` - User stories
- `task/` - Tasks

---

### Logging

#### `LOG_FILE`
**Description:** Path to error log file
**Type:** File path
**Default:** `.pipeline/errors.log`
**Example:**
```bash
export LOG_FILE=/var/log/pipeline-errors.log
pipeline.sh work PROJ-1
```

---

#### `LOG_LEVEL`
**Description:** Minimum log level to display
**Type:** String (ERROR, WARN, INFO, DEBUG)
**Default:** `ERROR`
**Example:**
```bash
export LOG_LEVEL=INFO
pipeline.sh work PROJ-1
```

**Log Levels:**
- `ERROR` - Only errors (default)
- `WARN` - Errors + warnings
- `INFO` - Errors + warnings + info (same as VERBOSE=1)
- `DEBUG` - Everything (same as DEBUG=1)

---

## Command-Line Flags

### Global Flags

#### `--verbose` / `-v`
**Description:** Enable verbose output
**Example:**
```bash
pipeline.sh --verbose work PROJ-1
pipeline.sh -v work PROJ-1
```

**Equivalent To:**
```bash
export VERBOSE=1
pipeline.sh work PROJ-1
```

---

#### `--debug` / `-d`
**Description:** Enable debug mode
**Example:**
```bash
pipeline.sh --debug work PROJ-1
pipeline.sh -d work PROJ-1
```

**Equivalent To:**
```bash
export DEBUG=1
pipeline.sh work PROJ-1
```

---

#### `--dry-run` / `-n`
**Description:** Dry-run mode (preview only)
**Example:**
```bash
pipeline.sh --dry-run work PROJ-1
pipeline.sh -n work PROJ-1
```

**Equivalent To:**
```bash
export DRY_RUN=1
pipeline.sh work PROJ-1
```

---

#### `--version` / `-V`
**Description:** Show version information
**Example:**
```bash
pipeline.sh --version
```

**Output:**
```
Claude Code Agents Pipeline v1.0.0
```

---

#### `--help` / `-h`
**Description:** Show help message
**Example:**
```bash
pipeline.sh --help
pipeline.sh -h
```

---

### Combining Flags

**Multiple flags:**
```bash
pipeline.sh --verbose --dry-run work PROJ-1
pipeline.sh -v -n work PROJ-1
pipeline.sh -vn work PROJ-1  # Short form
```

**Order doesn't matter:**
```bash
pipeline.sh work PROJ-1 --verbose --debug
pipeline.sh --verbose work --debug PROJ-1
```

---

## State File Configuration

Location: `.pipeline/state.json`

### Structure

```json
{
  "stage": "work",
  "projectKey": "PROJ",
  "epicId": "PROJ-1",
  "stories": {
    "PROJ-2": {
      "title": "Implement feature",
      "status": "in_progress",
      "points": 3,
      "created_at": "2025-10-05T12:00:00Z"
    }
  },
  "currentStory": "PROJ-2",
  "branch": "feature/PROJ-2",
  "pr": null,
  "startTime": "2025-10-05T10:00:00Z",
  "version": "1.0.0"
}
```

### Fields

#### `stage`
**Type:** String
**Values:** `requirements`, `gherkin`, `stories`, `work`, `complete`
**Description:** Current pipeline stage

---

#### `projectKey`
**Type:** String
**Default:** `PROJ`
**Description:** JIRA project key for story IDs

**Editing:**
```bash
jq '.projectKey = "MYAPP"' .pipeline/state.json > tmp.json && mv tmp.json .pipeline/state.json
```

---

#### `epicId`
**Type:** String or null
**Description:** Epic story ID (e.g., "PROJ-1")

---

#### `stories`
**Type:** Object
**Description:** Map of story IDs to story data

**Story Object:**
```json
{
  "title": "Story title",
  "status": "todo|in_progress|complete",
  "points": 3,
  "created_at": "2025-10-05T12:00:00Z"
}
```

**Adding a story manually:**
```bash
jq '.stories["PROJ-5"] = {
  "title": "New feature",
  "status": "todo",
  "points": 5,
  "created_at": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
}' .pipeline/state.json > tmp.json && mv tmp.json .pipeline/state.json
```

---

#### `currentStory`
**Type:** String or null
**Description:** Story currently being worked on

**Setting:**
```bash
jq '.currentStory = "PROJ-3"' .pipeline/state.json > tmp.json && mv tmp.json .pipeline/state.json
```

---

#### `branch`
**Type:** String or null
**Description:** Current git branch

---

#### `pr`
**Type:** String or null
**Description:** Pull request URL

---

### Viewing State

```bash
# Entire state
cat .pipeline/state.json | jq

# Specific field
jq '.currentStory' .pipeline/state.json

# All stories
jq '.stories' .pipeline/state.json

# Stories by status
jq '.stories | to_entries[] | select(.value.status == "todo")' .pipeline/state.json
```

### Backup & Restore

**Automatic Backups:**
- Location: `.pipeline/backups/`
- Format: `state_YYYYMMDD_HHMMSS.json`
- Created: Before every state modification

**Restore from backup:**
```bash
# List backups
ls -lt .pipeline/backups/

# Restore latest
cp .pipeline/backups/state_$(ls -t .pipeline/backups/ | head -1) .pipeline/state.json

# Verify
jq empty .pipeline/state.json
```

---

## Project Configuration

### Language Detection

Pipeline automatically detects project language:

#### JavaScript/Node.js
**Detection:** Presence of `package.json`
**Test Framework:** Jest
**Files Generated:**
- Test: `*.test.js` or `*.spec.js`
- Implementation: `*.js`

**Override:**
```bash
# Force JavaScript even without package.json
touch package.json
pipeline.sh work PROJ-1
```

---

#### Python
**Detection:** Presence of `requirements.txt` or `pyproject.toml`
**Test Framework:** pytest
**Files Generated:**
- Test: `test_*.py`
- Implementation: `*.py`

**Setup:**
```bash
# Create requirements.txt
touch requirements.txt
pipeline.sh work PROJ-1
```

---

#### Go
**Detection:** Presence of `go.mod`
**Test Framework:** testing package
**Files Generated:**
- Test: `*_test.go`
- Implementation: `*.go`

**Setup:**
```bash
# Initialize Go module
go mod init github.com/user/project
pipeline.sh work PROJ-1
```

---

#### Bash
**Detection:** No other project files (default fallback)
**Test Framework:** Custom shell scripts
**Files Generated:**
- Test: `*_test.sh`
- Implementation: `*.sh`

---

### Directory Structure

**Recommended structure:**
```
project/
├── .pipeline/
│   ├── state.json
│   ├── requirements.md
│   ├── features/
│   ├── exports/
│   └── backups/
├── src/              # JavaScript/Python implementation
├── tests/            # Test files
├── package.json      # JavaScript
├── requirements.txt  # Python
└── go.mod           # Go
```

**Customizing test directory:**
```bash
# Pipeline respects existing structure
mkdir -p __tests__  # JavaScript convention
mkdir -p spec       # Ruby/RSpec convention

# Pipeline will detect and use existing test directories
```

---

## JIRA Configuration

### Setup JIRA CLI (acli)

**Installation:**
```bash
npm install -g @atlassian/acli
```

**Configuration:**
```bash
# Login to JIRA
acli jira login

# Enter credentials:
# - JIRA URL: https://company.atlassian.net
# - Username: your.email@company.com
# - API Token: (generate at: https://id.atlassian.com/manage-profile/security/api-tokens)
```

**Verify:**
```bash
acli jira project list
```

---

### Project Configuration

**Create JIRA project (if needed):**
```bash
# Use provided template
acli jira project create --from-json jira-scrum-project.json

# Or create manually through JIRA UI
```

**Configure project key:**
```bash
export JIRA_PROJECT=MYAPP
jq '.projectKey = "MYAPP"' .pipeline/state.json > tmp.json && mv tmp.json .pipeline/state.json
```

---

### Without JIRA

Pipeline works without JIRA:

**What happens:**
- Creates local story files
- Generates CSV for import: `.pipeline/exports/jira_import.csv`
- Saves hierarchy: `.pipeline/exports/jira_hierarchy.json`

**Manual import:**
1. Open CSV: `.pipeline/exports/jira_import.csv`
2. Import to JIRA: **Project Settings** → **Import**
3. Map fields as prompted

---

## Git Configuration

### Repository Setup

**Initialize repository:**
```bash
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

**Add remote:**
```bash
git remote add origin https://github.com/user/repo.git

# Or SSH
git remote add origin git@github.com:user/repo.git
```

**Verify:**
```bash
git remote -v
```

---

### Branch Configuration

**Default branch auto-detection (v1.1.0+):**
```bash
# Pipeline auto-detects main branch using multiple methods:
#
# Method 1: Check remote HEAD symbolic reference
#   git symbolic-ref refs/remotes/origin/HEAD
#
# Method 2: Search for common branch names
#   Checks in order: main, master, develop
#   Looks in both local and remote branches
#
# Method 3: Fallback to current branch
#   Uses current HEAD if no default detected
```

**Detection behavior:**
- When creating feature branches, pipeline checks out the default branch first
- Ensures feature branches are based on latest default branch
- Works with repos using main, master, develop, or custom default branches

**Manual override:**
```bash
export GIT_MAIN_BRANCH=develop
```

**Set remote HEAD manually (if needed):**
```bash
# If remote HEAD is not set, configure it:
git remote set-head origin --auto

# Or set manually:
git remote set-head origin main
```

---

### Commit Message Format

**Default format:**
```
feat: implement PROJ-1

- Added tests for PROJ-1
- Implemented feature to pass tests
- Generated via pipeline.sh

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Customizing:**
```bash
# Edit git commit command in pipeline.sh (advanced)
# Or use git hooks to modify commit messages
```

---

## Language Detection

### Detection Priority

1. **Go:** If `go.mod` exists
2. **Python:** If `requirements.txt` or `pyproject.toml` exists
3. **JavaScript:** If `package.json` exists
4. **Bash:** Default fallback

### Force Specific Language

**JavaScript:**
```bash
touch package.json
echo '{"name":"project","version":"1.0.0"}' > package.json
```

**Python:**
```bash
touch requirements.txt
```

**Go:**
```bash
go mod init github.com/user/project
```

**Bash:**
```bash
# Remove other language files
rm package.json requirements.txt go.mod
```

---

## Advanced Configuration

### Custom Test Frameworks

**JavaScript - Use Mocha instead of Jest:**
```json
// package.json
{
  "devDependencies": {
    "mocha": "^10.0.0"
  },
  "scripts": {
    "test": "mocha"
  }
}
```

**Python - Use unittest instead of pytest:**
```python
# Still generates pytest-compatible tests
# Can run with: python -m unittest discover
```

---

### Environment-Specific Configuration

**.env file:**
```bash
# .pipeline/.env
VERBOSE=1
MAX_RETRIES=5
JIRA_PROJECT=MYAPP
```

**Load before running:**
```bash
source .pipeline/.env
pipeline.sh work PROJ-1
```

---

### Configuration Profiles

**Development profile:**
```bash
# dev.env
export VERBOSE=1
export DEBUG=1
export DRY_RUN=0
export SKIP_GIT_PUSH=1
```

**Production profile:**
```bash
# prod.env
export VERBOSE=0
export DEBUG=0
export MAX_RETRIES=5
export OPERATION_TIMEOUT=600
```

**Usage:**
```bash
source dev.env && pipeline.sh work PROJ-1
source prod.env && pipeline.sh work PROJ-1
```

---

## Configuration Examples

### Example 1: Minimal Setup (Defaults)

```bash
# No configuration needed
pipeline.sh requirements "Feature description"
pipeline.sh gherkin
pipeline.sh stories
pipeline.sh work PROJ-1
```

---

### Example 2: Verbose Mode for Debugging

```bash
export VERBOSE=1
export DEBUG=1
pipeline.sh work PROJ-1 2>&1 | tee debug.log
```

---

### Example 3: Custom JIRA Project

```bash
export JIRA_PROJECT=MYAPP
pipeline.sh stories
# Creates: MYAPP-1, MYAPP-2, etc.
```

---

### Example 4: Slow Network

```bash
export MAX_RETRIES=10
export RETRY_DELAY=5
export OPERATION_TIMEOUT=900
pipeline.sh work PROJ-1
```

---

### Example 5: Preview Before Execution

```bash
pipeline.sh --dry-run --verbose work PROJ-1
# Review output
# If looks good:
pipeline.sh work PROJ-1
```

---

### Example 6: Python Project

```bash
# Setup
touch requirements.txt
echo "pytest" > requirements.txt

# Configure
export VERBOSE=1

# Run
pipeline.sh work PROJ-1

# Test
pytest tests/
```

---

### Example 7: Large Codebase

```bash
export OPERATION_TIMEOUT=1800  # 30 minutes
export MAX_RETRIES=10
export VERBOSE=1
pipeline.sh work PROJ-1
```

---

### Example 8: Multiple Projects

**Project A:**
```bash
cd project-a
export JIRA_PROJECT=PROJA
pipeline.sh work PROJA-1
```

**Project B:**
```bash
cd project-b
export JIRA_PROJECT=PROJB
pipeline.sh work PROJB-1
```

---

## Configuration Checklist

### Initial Setup

- [ ] Install dependencies (jq, git, language runtime)
- [ ] Configure git (name, email, remote)
- [ ] Configure JIRA (optional - acli login)
- [ ] Set project key (export JIRA_PROJECT=...)
- [ ] Create project files (package.json, requirements.txt, etc.)

### Per-Project Setup

- [ ] Initialize pipeline (pipeline.sh init)
- [ ] Set environment variables if needed
- [ ] Review default configuration
- [ ] Test with dry-run mode

### Production Setup

- [ ] Set appropriate timeouts
- [ ] Configure retry settings
- [ ] Set up logging
- [ ] Test error handling

---

## Configuration Reference

### All Environment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `VERBOSE` | Boolean | 0 | Enable verbose output |
| `DEBUG` | Boolean | 0 | Enable debug mode |
| `DRY_RUN` | Boolean | 0 | Preview mode only |
| `MAX_RETRIES` | Integer | 3 | Network retry attempts |
| `RETRY_DELAY` | Integer | 2 | Delay between retries (seconds) |
| `OPERATION_TIMEOUT` | Integer | 300 | Operation timeout (seconds) |
| `JIRA_PROJECT` | String | PROJ | JIRA project key |
| `JIRA_URL` | URL | - | JIRA instance URL |
| `JIRA_USER` | String | - | JIRA username |
| `SKIP_GIT_PUSH` | Boolean | 0 | Skip git push step |
| `GIT_BRANCH_PREFIX` | String | feature/ | Branch name prefix |
| `GIT_MAIN_BRANCH` | String | (auto-detect) | Override default branch detection |
| `LOG_FILE` | Path | .pipeline/errors.log | Error log file |
| `LOG_LEVEL` | String | ERROR | Minimum log level |

### All Command Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--verbose` | `-v` | Enable verbose output |
| `--debug` | `-d` | Enable debug mode |
| `--dry-run` | `-n` | Preview mode only |
| `--version` | `-V` | Show version |
| `--help` | `-h` | Show help |

---

**Last Updated:** 2025-10-05
**Version:** 1.0.0
