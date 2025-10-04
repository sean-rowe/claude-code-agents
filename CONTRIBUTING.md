# Contributing to Claude Code Agents Pipeline

Thank you for your interest in contributing! This document provides guidelines and instructions for contributors.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [Pre-commit Hooks](#pre-commit-hooks)
4. [Coding Standards](#coding-standards)
5. [Commit Message Guidelines](#commit-message-guidelines)
6. [Pull Request Process](#pull-request-process)
7. [Testing](#testing)
8. [Documentation](#documentation)

---

## Getting Started

### Prerequisites

- **Git** 2.30+
- **Bash** 4.0+ (macOS users: `brew install bash`)
- **jq** 1.6+ - JSON processor (`brew install jq` or `apt-get install jq`)
- **Python** 3.8+ (for pre-commit hooks)
- **Node.js** 18+ (optional, for JavaScript testing)
- **Go** 1.20+ (optional, for Go testing)

### Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/claude-code-agents.git
cd claude-code-agents
git remote add upstream https://github.com/anthropics/claude-code-agents.git
```

---

## Development Setup

### 1. Install Pre-commit Framework

Pre-commit hooks catch issues before they're committed:

```bash
# Install pre-commit (Python)
pip install pre-commit

# Or use Homebrew (macOS)
brew install pre-commit

# Or use pipx (recommended)
pipx install pre-commit
```

### 2. Install Git Hooks

```bash
# Install all pre-commit hooks
pre-commit install

# Install commit message hook
pre-commit install --hook-type commit-msg

# Verify installation
pre-commit --version
```

### 3. Run Initial Check

```bash
# Run all hooks on all files (first run will install hook dependencies)
pre-commit run --all-files
```

**Expected output:**
```
Check for added large files..............................................Passed
Check for case conflicts.................................................Passed
Fix End of Files.........................................................Passed
Trim Trailing Whitespace.................................................Passed
Check Yaml...............................................................Passed
Check JSON...............................................................Passed
Don't commit to branch...................................................Passed
Check for merge conflicts................................................Passed
Detect Private Key.......................................................Passed
Detect AWS Credentials...................................................Passed
Fix mixed line ending....................................................Passed
Shellcheck...............................................................Passed
markdownlint.............................................................Passed
Validate state.json schema...............................................Passed
Validate package.json....................................................Passed
Conventional Commit......................................................Passed
detect-secrets...........................................................Passed
black....................................................................Passed
pretty-format-yaml.......................................................Passed
```

---

## Pre-commit Hooks

### What's Checked

Our pre-commit hooks enforce:

1. **File Quality**
   - No files > 500KB
   - No case conflicts (Windows/macOS compatibility)
   - Files end with newline
   - No trailing whitespace
   - LF line endings (not CRLF)

2. **Code Quality**
   - **Shellcheck** - Bash script linting
   - **Black** - Python code formatting
   - **Markdownlint** - Markdown formatting

3. **Data Validation**
   - **YAML syntax** - GitHub Actions, pre-commit config
   - **JSON syntax** - package.json, state.json
   - **JSON schema** - state.json validates against schema

4. **Security**
   - No private keys committed
   - No AWS credentials
   - No secrets (API keys, passwords)
   - Baseline: `.secrets.baseline`

5. **Git Workflow**
   - Can't commit directly to `main` or `master`
   - No merge conflict markers
   - Conventional commit messages

### Running Hooks Manually

```bash
# Run all hooks on staged files
pre-commit run

# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run shellcheck --all-files
pre-commit run markdownlint --all-files

# Skip hooks (emergency only!)
git commit --no-verify -m "fix: emergency hotfix"
```

### Updating Hooks

```bash
# Update to latest hook versions
pre-commit autoupdate

# Clean and reinstall
pre-commit clean
pre-commit install
```

### Troubleshooting Hooks

#### Issue: "Shellcheck failed"

```bash
# Install shellcheck
brew install shellcheck  # macOS
apt-get install shellcheck  # Ubuntu

# Check specific file
shellcheck pipeline.sh

# Auto-fix (if possible)
shellcheck -f diff pipeline.sh | git apply
```

#### Issue: "Markdownlint failed"

```bash
# Install markdownlint-cli
npm install -g markdownlint-cli

# Check and fix
markdownlint --fix docs/**/*.md

# Configuration: .markdownlint.json
```

#### Issue: "Conventional commit failed"

Your commit message doesn't follow conventional format.

**Bad:**
```
updated documentation
```

**Good:**
```
docs: update API reference with correct error codes
```

See [Commit Message Guidelines](#commit-message-guidelines) below.

#### Issue: "Detect-secrets failed"

A potential secret was found.

```bash
# Scan for secrets
detect-secrets scan --baseline .secrets.baseline

# Audit findings
detect-secrets audit .secrets.baseline

# Mark false positive
# Edit .secrets.baseline and mark as "is_secret": false
```

---

## Coding Standards

### Bash Scripts

**Required:**
- ✅ Use `#!/bin/bash` (not `#!/bin/sh`)
- ✅ Use `set -euo pipefail` for safety
- ✅ Quote all variables: `"$VAR"` not `$VAR`
- ✅ Use `readonly` for constants
- ✅ Functions: `function_name() { ... }` (lowercase, underscores)
- ✅ Pass shellcheck with no warnings

**Example:**
```bash
#!/bin/bash
set -euo pipefail

readonly VERSION="1.0.0"

validate_input() {
  local input="$1"

  if [ -z "$input" ]; then
    echo "Error: Input required" >&2
    return 1
  fi

  return 0
}

# Main
if validate_input "$@"; then
  echo "Valid: $1"
fi
```

### JSON Files

- ✅ Validate against schema (`.github/schemas/*.json`)
- ✅ 2-space indentation
- ✅ No trailing commas
- ✅ Use `jq` for manipulation: `jq '.key = "value"' file.json`

### Markdown Documentation

- ✅ ATX-style headers (`# Header` not `Header\n=====`)
- ✅ Max 120 chars per line (code blocks exempt)
- ✅ Fenced code blocks with language: ` ```bash `
- ✅ Consistent list indentation (2 spaces)

### Error Handling

**Always use the defined error codes:**

```bash
# In pipeline.sh (lines 16-24):
readonly E_SUCCESS=0
readonly E_GENERIC=1
readonly E_INVALID_ARGS=2
readonly E_MISSING_DEPENDENCY=3
readonly E_NETWORK_FAILURE=4
readonly E_STATE_CORRUPTION=5
readonly E_FILE_NOT_FOUND=6
readonly E_PERMISSION_DENIED=7
readonly E_TIMEOUT=8

# Usage:
if [ -z "$STORY_ID" ]; then
  log_error "Story ID required" $E_INVALID_ARGS
  exit $E_INVALID_ARGS
fi
```

---

## Commit Message Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat: add TypeScript support` |
| `fix` | Bug fix | `fix: correct error code in API docs` |
| `docs` | Documentation only | `docs: update installation guide` |
| `style` | Code style (no logic change) | `style: format with shellcheck` |
| `refactor` | Code refactor | `refactor: extract validation function` |
| `perf` | Performance improvement | `perf: optimize state file reads` |
| `test` | Add/update tests | `test: add edge case for story IDs` |
| `chore` | Maintenance | `chore: update pre-commit hooks` |
| `ci` | CI/CD changes | `ci: add shellcheck to GitHub Actions` |
| `revert` | Revert previous commit | `revert: revert feat: add feature X` |

### Scope (Optional)

- `security` - Security fixes
- `api` - API changes
- `cli` - CLI changes
- `pipeline` - Pipeline logic
- `docs` - Documentation
- `tests` - Test suite

### Examples

**Good commit messages:**

```
feat(security): add input validation for story IDs

- Validate story ID format (PROJECT-123)
- Block path traversal attempts
- Prevent command injection
- Add length limits (max 64 chars)

Closes #42
```

```
fix: correct error codes in API_REFERENCE.md

Error codes were documented incorrectly:
- E_INVALID_ARGS was code 1, actually code 2
- E_NETWORK_ERROR doesn't exist, use E_NETWORK_FAILURE
- E_PERMISSION_DENIED was code 13, actually code 7

All error codes now match pipeline.sh (lines 16-24)

Fixes: 5576d67
```

```
docs: add troubleshooting guide for jq errors

Added section on installing jq for macOS, Ubuntu, CentOS.
Includes error message examples and solutions.
```

**Bad commit messages:**

```
❌ updated files
❌ fix bug
❌ WIP
❌ asdf
❌ Fixed the thing that was broken
```

### Breaking Changes

For breaking changes, add `!` after type and `BREAKING CHANGE:` in footer:

```
feat!: change state.json schema to v2

BREAKING CHANGE: state.json now requires 'version' field.
Run migration: ./scripts/migrate-state-v1-to-v2.sh
```

---

## Pull Request Process

### 1. Create Feature Branch

```bash
# Update main
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name
```

**Branch naming:**
- `feature/add-typescript-support`
- `fix/error-code-documentation`
- `docs/update-contributing-guide`
- `refactor/extract-validation-logic`

### 2. Make Changes

```bash
# Make your changes
vim pipeline.sh

# Run hooks before committing
pre-commit run --all-files

# Commit with conventional message
git add .
git commit -m "feat: add TypeScript support"
```

### 3. Push and Create PR

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create PR on GitHub
gh pr create --title "feat: Add TypeScript support" --body "..."
```

### 4. PR Requirements

Your PR must:

- ✅ Pass all pre-commit hooks
- ✅ Pass all CI checks (GitHub Actions)
- ✅ Include tests for new features
- ✅ Update documentation
- ✅ Follow conventional commit format
- ✅ Have clear description of changes
- ✅ Reference related issues: `Closes #123`

### 5. Code Review

Reviewers will check for:

- ❌ **No placeholder code** (`TODO`, `FIXME`, stub implementations)
- ❌ **No comment-only changes** (real code changes required)
- ✅ **SOLID principles** followed
- ✅ **Security** - input validation, no injection vulnerabilities
- ✅ **Error handling** - comprehensive error paths
- ✅ **Documentation** - all public APIs documented

### 6. Address Feedback

```bash
# Make requested changes
vim file.py

# Commit with conventional message
git add .
git commit -m "fix: address PR feedback - add input validation"

# Push updates
git push origin feature/your-feature-name
```

### 7. Merge

Once approved:

1. Squash commits if requested
2. Ensure CI passes
3. Maintainer will merge

---

## Testing

### Running Tests

```bash
# Run all edge case tests
bash tests/edge_cases/run_edge_case_tests.sh

# Run specific test suite
bash tests/edge_cases/test_edge_case_story_ids.sh
bash tests/edge_cases/test_missing_dependencies.sh
bash tests/edge_cases/test_corrupted_state.sh

# Run with verbose output
VERBOSE=1 bash tests/edge_cases/run_edge_case_tests.sh
```

### Writing Tests

**Test structure:**
```bash
#!/bin/bash
# tests/edge_cases/test_your_feature.sh

source "$(dirname "$0")/test_helpers.sh"

test_case_1() {
  local result
  result=$(pipeline.sh work "INVALID-ID" 2>&1 || true)

  assert_contains "$result" "Invalid story ID"
  assert_exit_code 2  # E_INVALID_ARGS
}

# Run tests
run_test_suite \
  test_case_1 \
  test_case_2
```

### Test Coverage

Aim for:
- ✅ 80%+ code coverage for `pipeline.sh`
- ✅ All error paths tested
- ✅ Edge cases covered (empty input, special chars, etc.)
- ✅ Security tests (injection, traversal, etc.)

---

## Documentation

### What to Document

**New features:**
- Update `docs/USER_GUIDE.md` - user-facing guide
- Update `docs/API_REFERENCE.md` - technical reference
- Add examples to both

**Bug fixes:**
- Update troubleshooting section if user-facing
- Document workarounds

**Breaking changes:**
- Update migration guide
- Add to CHANGELOG.md
- Document in PR description

### Documentation Standards

- ✅ Use examples for all APIs
- ✅ Include error messages and solutions
- ✅ Cross-reference related sections
- ✅ Keep version compatibility notes
- ✅ Update table of contents

**Example documentation:**

````markdown
## validate_story_id()

**Purpose:** Validate JIRA story ID format and block security issues.

**Usage:**
```bash
if validate_story_id "$STORY_ID"; then
  echo "Valid"
else
  exit $E_INVALID_ARGS
fi
```

**Security Checks:**
1. Empty check
2. Length limit (64 chars)
3. Format: `^[A-Za-z0-9_\-]+$`
4. Pattern: Must have hyphen and end with numbers
5. Path traversal: Block `..` and `/`
6. Command injection: Block shell metacharacters

**Examples:**
```bash
validate_story_id "PROJ-123"     # ✓ Valid
validate_story_id ""             # ✗ Empty
validate_story_id "PROJ-123;rm"  # ✗ Injection
```

**Errors:**
- `E_INVALID_ARGS` - Invalid format, see error message
````

---

## Release Process

(For maintainers only)

### 1. Version Bump

```bash
# Update VERSION in pipeline.sh
vim pipeline.sh

# Update package.json
npm version patch|minor|major
```

### 2. Update Changelog

```bash
# Add to CHANGELOG.md
## [1.1.0] - 2025-10-04

### Added
- Pre-commit hooks for code quality

### Fixed
- Error code documentation in API_REFERENCE.md

### Changed
- Updated environment variables list
```

### 3. Tag Release

```bash
git add .
git commit -m "chore: bump version to 1.1.0"
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin main --tags
```

### 4. GitHub Release

```bash
gh release create v1.1.0 \
  --title "v1.1.0 - Pre-commit Hooks" \
  --notes "See CHANGELOG.md for details"
```

---

## Getting Help

- 📖 **Documentation:** [docs/](docs/)
- 💬 **Discussions:** [GitHub Discussions](https://github.com/anthropics/claude-code-agents/discussions)
- 🐛 **Issues:** [GitHub Issues](https://github.com/anthropics/claude-code-agents/issues)
- 📧 **Email:** support@anthropic.com

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).

**Summary:**
- Be respectful and inclusive
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

---

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

---

## Thank You!

Your contributions make this project better for everyone. We appreciate your time and effort!

**Happy coding!** 🚀
