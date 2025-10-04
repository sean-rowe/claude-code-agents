# Claude Code Agents Pipeline - User Guide

**Version:** 1.0.0
**Last Updated:** 2025-10-04

---

## Table of Contents

1. [Introduction](#introduction)
2. [Quick Start](#quick-start)
3. [Installation](#installation)
4. [Pipeline Stages](#pipeline-stages)
5. [Supported Languages](#supported-languages)
6. [Configuration](#configuration)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)
9. [Examples](#examples)
10. [FAQ](#faq)

---

## Introduction

The Claude Code Agents Pipeline is a **Test-Driven Development (TDD) workflow automation system** that generates test files and implementations across multiple programming languages. It follows a structured pipeline from requirements gathering to deployment.

### What It Does

- ✅ Generates requirements from user stories
- ✅ Creates Gherkin BDD scenarios
- ✅ Breaks down work into manageable stories
- ✅ **Writes tests FIRST** (Red phase of TDD)
- ✅ Generates implementation code (Green phase)
- ✅ Integrates with JIRA for project management
- ✅ Creates GitHub pull requests automatically
- ✅ Supports JavaScript, Python, Go, and Bash

### Why Use It?

- **Enforces TDD**: Tests are written before implementation
- **Multi-language**: Works with your stack
- **Automated workflow**: From story to PR in minutes
- **Quality assurance**: Generated code is validated
- **JIRA integration**: Keeps tickets in sync

---

## Quick Start

### Prerequisites

- Git installed and configured
- One of: Node.js (JS), Python 3 (Python), Go (Go), or Bash 4+
- jq (JSON processor): `brew install jq` or `apt-get install jq`
- Optional: JIRA CLI (`acli`) for JIRA integration
- Optional: GitHub CLI (`gh`) for PR creation

### Your First Pipeline Run (5 Minutes)

```bash
# 1. Clone and install
git clone https://github.com/anthropics/claude-code-agents.git
cd claude-code-agents
./install.sh

# 2. Initialize your project (in your project directory)
cd /path/to/your/project
pipeline.sh init

# 3. Generate requirements for a feature
pipeline.sh requirements "User authentication with email and password"

# 4. Generate Gherkin scenarios
pipeline.sh gherkin

# 5. Break into stories
pipeline.sh stories

# 6. Work on first story
pipeline.sh work PROJ-1

# 7. Complete and create PR
pipeline.sh complete PROJ-1
```

**That's it!** You now have:
- ✅ Test file with comprehensive test cases
- ✅ Implementation that passes the tests
- ✅ Git branch and commit
- ✅ Pull request (if GitHub configured)

---

## Installation

### Method 1: npm (Recommended)

```bash
npm install -g claude-pipeline
```

### Method 2: Homebrew (macOS/Linux)

```bash
brew tap anthropics/claude-code-agents
brew install claude-pipeline
```

### Method 3: Manual Installation

```bash
# Clone repository
git clone https://github.com/anthropics/claude-code-agents.git
cd claude-code-agents

# Run installer
./install.sh

# Verify installation
pipeline.sh --version
```

### Post-Installation Setup

**1. Configure Git:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**2. Configure JIRA (Optional):**
```bash
# Install JIRA CLI
npm install -g @atlassian/jira-cli

# Configure
jira configure

# Set project key (replace PROJ with your key)
export JIRA_PROJECT=PROJ
```

**3. Configure GitHub (Optional):**
```bash
# Install GitHub CLI
brew install gh  # or: apt-get install gh

# Authenticate
gh auth login
```

---

## Pipeline Stages

The pipeline follows a 5-stage workflow:

### Stage 1: Requirements

**Purpose:** Convert user stories into structured requirements

**Command:**
```bash
pipeline.sh requirements "Feature description here"
```

**What It Does:**
- Analyzes the feature request
- Generates functional requirements
- Generates non-functional requirements
- Creates acceptance criteria
- Saves to `.pipeline/requirements.md`

**Example:**
```bash
pipeline.sh requirements "Shopping cart with add/remove items"
```

**Output:**
```
Functional Requirements:
1. User can add items to cart
2. User can remove items from cart
3. Cart displays total price
4. Cart persists across sessions

Non-Functional Requirements:
1. Cart operations complete in <200ms
2. Supports up to 100 items per cart
...
```

---

### Stage 2: Gherkin

**Purpose:** Create Behavior-Driven Development scenarios

**Command:**
```bash
pipeline.sh gherkin
```

**What It Does:**
- Reads requirements from Stage 1
- Generates Gherkin feature files
- Creates Given/When/Then scenarios
- Defines edge cases
- Saves to `.pipeline/gherkin.feature`

**Example Output:**
```gherkin
Feature: Shopping Cart
  As a user
  I want to manage items in my cart
  So that I can purchase products

  Scenario: Add item to cart
    Given I am on the product page
    When I click "Add to Cart"
    Then the item should appear in my cart
    And the cart count should increase by 1

  Scenario: Remove item from cart
    Given I have items in my cart
    When I click "Remove" on an item
    Then the item should be removed
    And the cart total should update
```

---

### Stage 3: Stories

**Purpose:** Break work into manageable JIRA stories

**Command:**
```bash
pipeline.sh stories
```

**What It Does:**
- Analyzes Gherkin scenarios
- Creates JIRA stories (if configured)
- Assigns story points
- Generates story descriptions
- Updates `.pipeline/state.json`

**Example Output:**
```
Created Stories:
- PROJ-1: Implement add to cart functionality (3 points)
- PROJ-2: Implement remove from cart (2 points)
- PROJ-3: Implement cart persistence (5 points)
- PROJ-4: Implement cart total calculation (2 points)

Total: 4 stories, 12 points
```

**State File (`.pipeline/state.json`):**
```json
{
  "current_story": null,
  "stories": {
    "PROJ-1": {
      "title": "Implement add to cart",
      "status": "todo",
      "points": 3
    }
  }
}
```

---

### Stage 4: Work

**Purpose:** Generate tests and implementation for a story

**Command:**
```bash
pipeline.sh work STORY-ID
```

**What It Does:**
1. Validates story ID (security check)
2. Acquires lock (prevents concurrent runs)
3. Creates feature branch (`feature/STORY-ID`)
4. **Writes tests FIRST** (TDD Red phase)
5. Generates implementation (TDD Green phase)
6. Validates syntax
7. Runs tests
8. Commits changes
9. Pushes to remote (if configured)

**Example:**
```bash
pipeline.sh work PROJ-1
```

**Output:**
```
STAGE: work
STEP: 1 of 6
ACTION: Working on story: PROJ-1

STEP: 2 of 6
ACTION: Creating feature branch
✓ Branch created: feature/PROJ-1

STEP: 3 of 6
ACTION: Writing tests (TDD Red phase)
✓ Created test file: tests/cart_test.js

STEP: 4 of 6
ACTION: Implementing (TDD Green phase)
✓ Created implementation: src/cart.js

STEP: 5 of 6
ACTION: Running tests
✓ Tests passed

STEP: 6 of 6
ACTION: Committing changes
✓ Changes committed and pushed

RESULT: Story PROJ-1 implementation complete
NEXT: Run './pipeline.sh complete PROJ-1'
```

**Files Created:**
- Test file: `tests/cart_test.js` (or appropriate for language)
- Implementation: `src/cart.js`
- Git branch: `feature/PROJ-1`
- Commit message: `feat: implement PROJ-1`

---

### Stage 5: Complete

**Purpose:** Finalize story and create pull request

**Command:**
```bash
pipeline.sh complete STORY-ID
```

**What It Does:**
1. Validates all tests pass
2. Updates JIRA status to "Done"
3. Creates GitHub pull request
4. Adds PR description with changes
5. Links PR to JIRA ticket
6. Updates state to "complete"

**Example:**
```bash
pipeline.sh complete PROJ-1
```

**Output:**
```
STAGE: complete
Completing story: PROJ-1

✓ Tests verified (all passing)
✓ JIRA ticket updated to Done
✓ Pull request created: #42
  URL: https://github.com/user/repo/pull/42
✓ PR linked to JIRA ticket

Story PROJ-1 is complete!
```

---

## Supported Languages

### JavaScript (Node.js)

**Detection:** Presence of `package.json`

**Test Framework:** Jest

**Generated Files:**
- Test: `*.test.js` or `*.spec.js`
- Implementation: `*.js`

**Example Test:**
```javascript
const { addToCart } = require('./cart');

describe('Cart', () => {
  test('should add item to cart', () => {
    const cart = [];
    const item = { id: 1, name: 'Product' };

    addToCart(cart, item);

    expect(cart).toContain(item);
  });
});
```

**Syntax Validation:** `node --check`

---

### Python

**Detection:** Presence of `requirements.txt` or `setup.py`

**Test Framework:** pytest

**Generated Files:**
- Test: `test_*.py` or `*_test.py`
- Implementation: `*.py`

**Example Test:**
```python
from cart import add_to_cart

def test_add_to_cart():
    cart = []
    item = {'id': 1, 'name': 'Product'}

    add_to_cart(cart, item)

    assert item in cart
```

**Syntax Validation:** `python3 -m py_compile`

---

### Go

**Detection:** Presence of `go.mod`

**Test Framework:** testing package

**Generated Files:**
- Test: `*_test.go`
- Implementation: `*.go`

**Example Test:**
```go
package cart

import "testing"

func TestAddToCart(t *testing.T) {
    cart := []Item{}
    item := Item{ID: 1, Name: "Product"}

    cart = AddToCart(cart, item)

    if len(cart) != 1 {
        t.Errorf("Expected 1 item, got %d", len(cart))
    }
}
```

**Syntax Validation:** `go build`

---

### Bash

**Detection:** Lack of other project files

**Test Framework:** Custom test scripts

**Generated Files:**
- Test: `test_*.sh` or `*_test.sh`
- Implementation: `*.sh`

**Example Test:**
```bash
#!/bin/bash
source ./cart.sh

test_add_to_cart() {
    result=$(add_to_cart "item1")

    if [[ "$result" == *"item1"* ]]; then
        echo "PASS: add_to_cart"
        return 0
    else
        echo "FAIL: add_to_cart"
        return 1
    fi
}

test_add_to_cart
```

**Syntax Validation:** `bash -n`

---

## Configuration

### Environment Variables

```bash
# Verbose output
export VERBOSE=1

# Debug mode (very detailed logs)
export DEBUG=1

# Dry-run mode (show what would happen, don't execute)
export DRY_RUN=1

# JIRA project key
export JIRA_PROJECT=PROJ

# Custom retry settings
export MAX_RETRIES=5
export RETRY_DELAY=3

# Operation timeout (seconds)
export OPERATION_TIMEOUT=600
```

### Command-Line Flags

```bash
# Verbose mode
pipeline.sh --verbose work PROJ-1
pipeline.sh -v work PROJ-1

# Debug mode
pipeline.sh --debug work PROJ-1
pipeline.sh -d work PROJ-1

# Dry-run mode
pipeline.sh --dry-run work PROJ-1
pipeline.sh -n work PROJ-1

# Combine flags
pipeline.sh --verbose --dry-run work PROJ-1
```

### State File (`.pipeline/state.json`)

Located at `.pipeline/state.json`, tracks pipeline state:

```json
{
  "stage": "work",
  "current_story": "PROJ-1",
  "stories": {
    "PROJ-1": {
      "title": "Implement feature",
      "status": "in_progress",
      "points": 3,
      "created_at": "2025-10-04T12:00:00Z"
    }
  }
}
```

**Manual Editing:**
```bash
# View state
cat .pipeline/state.json | jq

# Set current story
jq '.current_story = "PROJ-2"' .pipeline/state.json > tmp.json && mv tmp.json .pipeline/state.json
```

---

## Troubleshooting

### Common Issues

#### Issue: "jq: command not found"

**Cause:** jq is not installed

**Solution:**
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq
```

---

#### Issue: "Invalid story ID format"

**Cause:** Story ID doesn't match required format (PROJECT-123)

**Solution:**
```bash
# ❌ Wrong
pipeline.sh work "my story"
pipeline.sh work "PROJ 123"

# ✅ Correct
pipeline.sh work "PROJ-123"
pipeline.sh work "STORY-45"
```

**Valid Format:**
- Letters and numbers, followed by hyphen, followed by numbers
- Examples: `PROJ-1`, `FEAT-42`, `BUG-999`
- Max 64 characters

---

#### Issue: "Another pipeline process is running"

**Cause:** Lock file exists from previous run

**Check Lock:**
```bash
ls -la .pipeline/pipeline.lock/
cat .pipeline/pipeline.lock/pid
```

**Solution:**
```bash
# If process is truly stuck, remove lock
rm -rf .pipeline/pipeline.lock

# Then retry
pipeline.sh work PROJ-1
```

**Prevention:** Pipeline automatically removes stale locks

---

#### Issue: "State file is corrupted"

**Cause:** Invalid JSON in `.pipeline/state.json`

**Diagnose:**
```bash
# Validate JSON
jq empty .pipeline/state.json

# View errors
cat .pipeline/state.json
```

**Solution:**
```bash
# Backup corrupted file
cp .pipeline/state.json .pipeline/state.json.backup

# Reinitialize
pipeline.sh init

# Restore stories manually if needed
```

---

#### Issue: "fatal: 'origin' does not appear to be a git repository"

**Cause:** No remote repository configured

**Solution:**
```bash
# Add remote
git remote add origin https://github.com/user/repo.git

# Verify
git remote -v

# Retry push
git push -u origin feature/PROJ-1
```

---

#### Issue: "Permission denied" when acquiring lock

**Cause:** Lock directory has wrong permissions

**Solution:**
```bash
# Fix permissions
chmod -R 755 .pipeline/

# Remove lock if needed
rm -rf .pipeline/pipeline.lock

# Retry
pipeline.sh work PROJ-1
```

---

#### Issue: Tests fail during work stage

**Cause:** Generated implementation doesn't match tests (expected behavior in TDD)

**Solution:**
```bash
# This is normal! Tests are written FIRST (Red phase)
# Implementation makes them pass (Green phase)

# View generated test
cat tests/your_test_file.*

# View implementation
cat src/your_impl_file.*

# Manually fix if needed, then commit
git add .
git commit -m "fix: adjust implementation"
```

---

### Debug Mode

Enable detailed logging:

```bash
# Method 1: Environment variable
export DEBUG=1
pipeline.sh work PROJ-1

# Method 2: Command flag
pipeline.sh --debug work PROJ-1
```

**Debug Output:**
```
[DEBUG 2025-10-04 12:00:00] Executing with retry: git push -u origin feature/PROJ-1
[DEBUG 2025-10-04 12:00:00] Attempt 1/3
[DEBUG 2025-10-04 12:00:01] Command succeeded on attempt 1
[DEBUG 2025-10-04 12:00:01] Story ID validation passed: PROJ-1
```

### Log Files

All errors logged to `.pipeline/errors.log`:

```bash
# View recent errors
tail -50 .pipeline/errors.log

# Search for specific error
grep "PROJ-1" .pipeline/errors.log

# Monitor in real-time
tail -f .pipeline/errors.log
```

---

## Best Practices

### 1. Always Initialize First

```bash
# In your project directory
pipeline.sh init
```

Creates necessary directories and state files.

### 2. One Story at a Time

```bash
# ✅ Good
pipeline.sh work PROJ-1
# ... wait for completion ...
pipeline.sh complete PROJ-1
pipeline.sh work PROJ-2

# ❌ Bad (will get locked)
pipeline.sh work PROJ-1 &
pipeline.sh work PROJ-2 &  # Will fail with lock error
```

### 3. Review Generated Code

```bash
# After work stage
git diff feature/PROJ-1

# Review test file
cat tests/*_test.*

# Review implementation
cat src/*.*
```

**Always review before completing!**

### 4. Use Meaningful Story Descriptions

```bash
# ✅ Good
pipeline.sh requirements "User can filter products by price range with min/max inputs"

# ❌ Bad
pipeline.sh requirements "filter stuff"
```

### 5. Keep State File Clean

```bash
# Periodically backup
cp .pipeline/state.json .pipeline/state.json.backup

# Remove completed stories (manually)
jq 'del(.stories["PROJ-1"])' .pipeline/state.json > tmp.json && mv tmp.json .pipeline/state.json
```

### 6. Use Dry-Run for Complex Operations

```bash
# See what would happen
pipeline.sh --dry-run work PROJ-1

# Review output, then run for real
pipeline.sh work PROJ-1
```

---

## Examples

### Example 1: JavaScript Project - REST API

```bash
# 1. Initialize
cd my-api-project
pipeline.sh init

# 2. Generate requirements
pipeline.sh requirements "REST API for user registration with email validation"

# 3. Create Gherkin scenarios
pipeline.sh gherkin

# 4. Break into stories
pipeline.sh stories
# Output: Created PROJ-1, PROJ-2, PROJ-3

# 5. Work on first story (email validation)
pipeline.sh work PROJ-1

# 6. Review generated files
cat tests/user_registration.test.js
cat src/user_registration.js

# 7. Run tests manually
npm test

# 8. Complete story
pipeline.sh complete PROJ-1
```

**Generated Test (Jest):**
```javascript
describe('User Registration', () => {
  test('should validate email format', () => {
    expect(validateEmail('user@example.com')).toBe(true);
    expect(validateEmail('invalid-email')).toBe(false);
  });
});
```

---

### Example 2: Python Project - Data Processing

```bash
# 1. Initialize
cd data-processor
pipeline.sh init

# 2. Generate requirements
pipeline.sh requirements "CSV parser that handles quotes and commas"

# 3-4. Gherkin and stories
pipeline.sh gherkin
pipeline.sh stories

# 5. Work on parser story
pipeline.sh work DATA-1

# 6. Review
cat tests/test_csv_parser.py
cat csv_parser.py

# 7. Run pytest
pytest tests/

# 8. Complete
pipeline.sh complete DATA-1
```

**Generated Test (pytest):**
```python
def test_parse_csv_with_quotes():
    csv_data = '"Name","Age"\n"John, Doe",30'
    result = parse_csv(csv_data)
    assert result[0]['Name'] == 'John, Doe'
```

---

### Example 3: Go Project - CLI Tool

```bash
# 1. Initialize Go project
mkdir cli-tool && cd cli-tool
go mod init github.com/user/cli-tool
pipeline.sh init

# 2. Requirements
pipeline.sh requirements "CLI flag parser for -v --verbose --output=file"

# 3-4. Scenarios and stories
pipeline.sh gherkin
pipeline.sh stories

# 5. Work on flag parser
pipeline.sh work CLI-1

# 6. Build and test
go test ./...
go build

# 7. Complete
pipeline.sh complete CLI-1
```

---

## FAQ

### Q: Does this replace writing code?

**A:** No, this **accelerates** development by:
- Generating boilerplate tests
- Creating basic implementations
- Enforcing TDD workflow

You still review, customize, and enhance the generated code.

---

### Q: What if generated code is wrong?

**A:** The pipeline generates a starting point. You should:
1. Review all generated code
2. Fix any issues
3. Enhance with domain-specific logic
4. Commit your changes

Think of it as an AI pair programmer, not a replacement.

---

### Q: Can I use this with an existing project?

**A:** Yes! Just run `pipeline.sh init` in your project directory. It works alongside your existing code.

---

### Q: Do I need JIRA?

**A:** No, JIRA integration is optional. Without it:
- Stories still created (stored in state.json)
- Manual story IDs (you provide them)
- No ticket linking

---

### Q: Can I customize test templates?

**A:** Currently, tests are generated based on language and framework detection. Customization requires modifying the pipeline itself.

---

### Q: How do I handle merge conflicts?

**A:** Standard Git workflow:
```bash
# Update main
git checkout main
git pull

# Rebase feature branch
git checkout feature/PROJ-1
git rebase main

# Resolve conflicts
# ... fix conflicts ...
git add .
git rebase --continue

# Push
git push -f origin feature/PROJ-1
```

---

### Q: What's the difference between --verbose and --debug?

**A:**
- `--verbose`: Shows INFO level logs (useful for tracking progress)
- `--debug`: Shows DEBUG level logs (useful for troubleshooting issues)

---

### Q: Can I run multiple stories in parallel?

**A:** No, the pipeline uses file locking to prevent concurrent modifications. This protects state integrity.

---

### Q: How do I upgrade the pipeline?

**A:**
```bash
# npm
npm update -g claude-pipeline

# Homebrew
brew upgrade claude-pipeline

# Manual
cd claude-code-agents
git pull
./install.sh
```

---

## Getting Help

### Documentation

- **This Guide:** `docs/USER_GUIDE.md`
- **Installation:** `INSTALL.md`
- **Quick Start:** `quickstart.sh`
- **README:** `README.md`

### Command Help

```bash
pipeline.sh --help
```

### Community

- **Issues:** https://github.com/anthropics/claude-code-agents/issues
- **Discussions:** https://github.com/anthropics/claude-code-agents/discussions

### Support

For bugs or feature requests, please open a GitHub issue with:
1. Pipeline version (`pipeline.sh --version`)
2. Error message (from `.pipeline/errors.log`)
3. Steps to reproduce
4. Expected vs actual behavior

---

## Next Steps

1. ✅ **Complete Installation** (see [Installation](#installation))
2. ✅ **Run Quick Start** (see [Quick Start](#quick-start))
3. ✅ **Read Pipeline Stages** (see [Pipeline Stages](#pipeline-stages))
4. ✅ **Try an Example** (see [Examples](#examples))
5. ✅ **Customize for Your Project** (see [Configuration](#configuration))

**Happy Coding with TDD!** 🚀
