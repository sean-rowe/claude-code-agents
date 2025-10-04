# Pre-commit Hooks Reference

This document provides quick reference for the pre-commit hooks used in this project.

## Quick Setup

```bash
# Automated setup (recommended)
./scripts/setup-dev.sh

# Manual setup
pip install pre-commit
pre-commit install
pre-commit install --hook-type commit-msg
pre-commit run --all-files
```

## Installed Hooks

### 1. File Quality Checks

| Hook | Purpose | Auto-fix |
|------|---------|----------|
| `check-added-large-files` | Prevent files > 500KB | No |
| `check-case-conflict` | Detect case-sensitive conflicts | No |
| `end-of-file-fixer` | Ensure newline at EOF | Yes |
| `trailing-whitespace` | Remove trailing spaces | Yes |
| `mixed-line-ending` | Enforce LF line endings | Yes |
| `check-merge-conflict` | Detect merge markers | No |

### 2. Security Checks

| Hook | Purpose | Config |
|------|---------|--------|
| `detect-private-key` | Block private keys | - |
| `detect-aws-credentials` | Block AWS keys | - |
| `detect-secrets` | Block all secrets | `.secrets.baseline` |

### 3. Code Quality

| Hook | Purpose | Config |
|------|---------|--------|
| `shellcheck` | Bash linting | Excludes SC1091 |
| `black` | Python formatting | - |
| `markdownlint` | Markdown linting | `.markdownlint.json` |
| `pretty-format-yaml` | YAML formatting | 2-space indent |

### 4. Data Validation

| Hook | Purpose | Config |
|------|---------|--------|
| `check-yaml` | YAML syntax | - |
| `check-json` | JSON syntax | - |
| `check-jsonschema` | state.json validation | `.github/schemas/state-schema.json` |

### 5. Git Workflow

| Hook | Purpose | Config |
|------|---------|--------|
| `no-commit-to-branch` | Block direct commits to main | Blocks: main, master |
| `conventional-pre-commit` | Validate commit messages | Conventional Commits format |

## Common Commands

```bash
# Run all hooks on staged files
pre-commit run

# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run shellcheck
pre-commit run markdownlint

# Update hooks to latest versions
pre-commit autoupdate

# Bypass hooks (emergency only!)
git commit --no-verify
```

## Troubleshooting

### Shellcheck Errors

```bash
# View errors
shellcheck pipeline.sh

# Common issues:
# SC2086: Quote variables
"$VAR"  # Good
$VAR    # Bad

# SC2155: Declare and assign separately
local var
var=$(command)  # Good

local var=$(command)  # Bad
```

### Markdownlint Errors

```bash
# Auto-fix
markdownlint --fix docs/**/*.md

# Common issues:
# MD013: Line too long (120 chars max)
# MD033: No raw HTML (except allowed elements)
# MD041: First line must be h1
```

### Conventional Commit Errors

**Error:** `commit message does not follow Conventional Commits format`

**Fix:** Use proper format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Valid types:** feat, fix, docs, style, refactor, perf, test, chore, ci, revert

**Examples:**
```
feat: add TypeScript support
fix(security): validate story ID format
docs: update API reference
```

### Secret Detection

**Error:** `Potential secret found`

```bash
# Audit the finding
detect-secrets audit .secrets.baseline

# If false positive, mark as "is_secret": false in .secrets.baseline
```

### JSON Schema Validation

**Error:** `state.json does not match schema`

The state.json file must conform to `.github/schemas/state-schema.json`.

**Required fields:**
- `stage` (enum)
- `stories` (array)
- `createdAt` (ISO 8601)
- `updatedAt` (ISO 8601)

**Example valid state.json:**
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
      "createdAt": "2025-10-04T10:00:00Z"
    }
  ],
  "createdAt": "2025-10-04T10:00:00Z",
  "updatedAt": "2025-10-04T10:00:00Z"
}
```

## Hook Configuration Files

| File | Purpose |
|------|---------|
| `.pre-commit-config.yaml` | Main hook configuration |
| `.markdownlint.json` | Markdown linting rules |
| `.secrets.baseline` | Secret detection baseline |
| `.github/schemas/state-schema.json` | State file JSON schema |

## CI/CD Integration

Pre-commit hooks also run in CI:

```yaml
# .github/workflows/pre-commit.yml
- uses: pre-commit/action@v3.0.0
```

This ensures all PRs pass the same checks locally and in CI.

## Performance

First run installs hook environments (~30s):
```
pre-commit run --all-files
```

Subsequent runs are fast (~2-5s):
```
pre-commit run
```

To speed up local development:
```bash
# Only run on staged files
git add changed_file.sh
pre-commit run
```

## Updating Hooks

```bash
# Update to latest hook versions
pre-commit autoupdate

# Review changes
git diff .pre-commit-config.yaml

# Test
pre-commit run --all-files

# Commit
git add .pre-commit-config.yaml
git commit -m "chore: update pre-commit hooks"
```

## Disabling Hooks

**Globally disable (not recommended):**
```bash
pre-commit uninstall
```

**Skip for one commit (emergency only):**
```bash
git commit --no-verify -m "fix: emergency hotfix"
```

**Skip specific hook:**
```bash
SKIP=shellcheck git commit -m "docs: update README"
```

## Adding New Hooks

1. Find hook at https://pre-commit.com/hooks.html
2. Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/author/hook-repo
    rev: v1.0.0
    hooks:
      - id: hook-id
        args: ['--option']
```

3. Install and test:

```bash
pre-commit install --install-hooks
pre-commit run hook-id --all-files
```

4. Document in CONTRIBUTING.md

## Support

- 📖 Docs: [CONTRIBUTING.md](../CONTRIBUTING.md)
- 🐛 Issues: https://github.com/anthropics/claude-code-agents/issues
- 💬 Discussions: https://github.com/anthropics/claude-code-agents/discussions
