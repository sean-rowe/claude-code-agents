# Branch Protection Configuration

This document describes how to configure GitHub branch protection rules to ensure all CI/CD quality gates pass before allowing pull requests to be merged.

## Overview

The CI/CD pipeline (`.github/workflows/test.yml`) includes multiple quality gates:

1. **Test Job** - Runs all tests on Ubuntu + macOS with multiple Node.js and Python versions
2. **Lint Job** - Runs ShellCheck on all bash scripts (BLOCKS merge on failure)
3. **Bash Compatibility Job** - Tests with Bash 4.4, 5.0, 5.1, and system versions
4. **Security Job** - Runs CodeQL, Bandit, and credential scanning
5. **Coverage Job** - Enforces 80%+ code coverage requirement (BLOCKS merge on failure)
6. **PR Status Check** - Final gate that requires ALL jobs to pass

## GitHub Branch Protection Setup

### Required Status Checks

To enforce all quality gates, configure branch protection for the `main` branch:

1. Go to **Settings** → **Branches** → **Branch protection rules**
2. Click **Add rule** for branch name pattern: `main`
3. Enable the following settings:

#### Require Status Checks
☑ **Require status checks to pass before merging**

Select the following required status checks:
- `PR Status Check (All Tests Must Pass)`
- `Test Pipeline / test (ubuntu-latest, 18.x, 3.9)`
- `Test Pipeline / test (ubuntu-latest, 18.x, 3.10)`
- `Test Pipeline / test (ubuntu-latest, 18.x, 3.11)`
- `Test Pipeline / test (ubuntu-latest, 20.x, 3.9)`
- `Test Pipeline / test (ubuntu-latest, 20.x, 3.10)`
- `Test Pipeline / test (ubuntu-latest, 20.x, 3.11)`
- `Test Pipeline / test (macos-latest, 18.x, 3.9)`
- `Test Pipeline / test (macos-latest, 18.x, 3.10)`
- `Test Pipeline / test (macos-latest, 18.x, 3.11)`
- `Test Pipeline / test (macos-latest, 20.x, 3.9)`
- `Test Pipeline / test (macos-latest, 20.x, 3.10)`
- `Test Pipeline / test (macos-latest, 20.x, 3.11)`
- `Lint Shell Scripts`
- `Security Scanning`
- `Test Coverage Report`

☑ **Require branches to be up to date before merging**

#### Require Pull Request Reviews
☑ **Require pull request reviews before merging**
- Required approving reviews: 1 (or more for production)
- Dismiss stale pull request approvals when new commits are pushed

#### Additional Protections
☑ **Require linear history** (optional - prevents merge commits)
☑ **Include administrators** (enforce rules for all, including admins)
☑ **Allow force pushes** → **Specify who can force push** → (None - disable force push)
☑ **Allow deletions** → Disabled

### Minimal Configuration

For a minimal setup that still enforces quality:

**Required Status Checks (Minimum):**
- `PR Status Check (All Tests Must Pass)` - This single check ensures all other jobs pass
- `Test Coverage Report` - Enforces 80%+ coverage
- `Lint Shell Scripts` - Enforces shellcheck compliance

## CI/CD Quality Gates

### Automatic Blocking

The following conditions will **automatically block** PR merges:

1. ❌ **Any test failure** (across any platform or version combination)
2. ❌ **ShellCheck linting errors** (bash syntax or best practice violations)
3. ❌ **Code coverage below 80%** (enforced by coverage job)
4. ❌ **Bash compatibility issues** (any version from 4.4 to 5.1+)

### Security Warnings

The following will generate warnings but not block (can be configured to block):

1. ⚠️ **Bandit security findings** (Python code security issues)
2. ⚠️ **CodeQL alerts** (JavaScript/Python vulnerabilities)
3. ⚠️ **Hardcoded credentials detected** (grep-based scan)

To make security checks blocking, remove `continue-on-error: true` from these steps in `test.yml`.

## Workflow File Matrix

The `test.yml` workflow uses matrix testing to ensure compatibility:

### Operating Systems
- Ubuntu (latest)
- macOS (latest)

### Node.js Versions
- 18.x
- 20.x

### Python Versions
- 3.9
- 3.10
- 3.11

### Bash Versions
- 4.4
- 5.0
- 5.1
- system (default)

**Total Test Combinations:** 12 OS/Node/Python combinations + 8 Bash compatibility tests = **20 test runs per PR**

## Release Workflow

The release workflow (`.github/workflows/release.yml`) is triggered on version tags:

```bash
git tag v2.1.0
git push origin v2.1.0
```

This automatically:
1. Runs full test suite
2. Generates changelog from commits
3. Creates GitHub release
4. Attaches pipeline.sh, install.sh, quickstart.sh, README.md

## Local Pre-commit Testing

Before pushing, developers should run:

```bash
# Run all tests locally
bash tests/run_all_tests.sh

# Check shellcheck compliance
shellcheck pipeline.sh
find tests -name "*.sh" -o -name "*.bash" | xargs shellcheck

# Check code coverage
bash tests/analyze_coverage.sh
```

## Troubleshooting

### PR Status Check Fails

If "PR Status Check (All Tests Must Pass)" fails, check the individual job logs:

```bash
# View GitHub Actions logs
gh run list
gh run view <run-id>
```

### Coverage Below 80%

If coverage enforcement fails:

1. Check `coverage-report.txt` artifact
2. Identify untested functions
3. Add unit tests to `tests/unit/`
4. Re-run tests locally: `bash tests/analyze_coverage.sh`

### ShellCheck Failures

If linting fails:

1. Run locally: `shellcheck pipeline.sh`
2. Fix violations or add exclusions:
   ```bash
   # shellcheck disable=SC2086
   ```
3. Document why exclusion is needed

### Bash Compatibility Issues

If bash-compatibility job fails:

1. Identify which version failed
2. Avoid bash-specific features (e.g., associative arrays in bash 3.x)
3. Use portable constructs
4. Test locally with Docker:
   ```bash
   docker run -it bash:4.4 /bin/bash
   ```

## Enforcement Summary

| Quality Gate | Enforced | Blocking | Can Be Waived |
|--------------|----------|----------|---------------|
| Unit Tests | ✅ Yes | ✅ Yes | ❌ No |
| Integration Tests | ✅ Yes | ✅ Yes | ❌ No |
| ShellCheck Linting | ✅ Yes | ✅ Yes | ❌ No |
| 80% Code Coverage | ✅ Yes | ✅ Yes | ❌ No |
| Multi-platform (Ubuntu/macOS) | ✅ Yes | ✅ Yes | ❌ No |
| Bash Compatibility | ✅ Yes | ✅ Yes | ❌ No |
| Security Scanning | ⚠️ Partial | ❌ No | ✅ Yes |
| PR Review | ☑️ Optional | ☑️ Optional | ✅ Yes |

**Bottom Line:** No PR can merge to `main` if tests fail, coverage drops below 80%, or shellcheck finds violations.

---

**Last Updated:** 2025-10-04
**CI/CD Version:** v2.1.0
