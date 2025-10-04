# Changelog

All notable changes to the Claude Code Agents Pipeline will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Pre-commit hooks infrastructure with 19 automated checks
- Comprehensive contributor documentation (CONTRIBUTING.md)
- JSON Schema for state.json validation
- Development setup script (scripts/setup-dev.sh)
- Pre-commit hooks reference guide

### Changed
- Updated environment variables documentation to match implementation
- Corrected API reference error codes to match pipeline.sh

### Fixed
- Error code documentation in API_REFERENCE.md now 100% accurate

## [1.0.0] - 2025-10-04

### Added
- **Core Pipeline Functionality**
  - Five-stage pipeline: init → requirements → gherkin → stories → work → complete
  - Multi-language support: JavaScript/Jest, Python/pytest, Go/testing, Bash/bats
  - TDD workflow enforcement (Red-Green-Refactor)
  - Automatic test generation before implementation

- **Security Features**
  - Input validation with `validate_story_id()` (6-layer security checks)
  - Command injection prevention
  - Path traversal protection
  - Length limits (DoS prevention)
  - File locking with `acquire_lock()` (concurrent access protection)
  - Stale lock detection and cleanup

- **JIRA Integration**
  - acli support for JIRA Cloud and Server
  - Automatic Epic and Story creation
  - CSV export for manual import (fallback)
  - Story status synchronization

- **Git Workflow**
  - Automatic feature branch creation (feature/STORY-ID)
  - Structured commit messages
  - GitHub PR creation via gh CLI
  - Pull request templates

- **State Management**
  - JSON-based pipeline state tracking (.pipeline/state.json)
  - State validation with jq
  - State corruption detection
  - Atomic state updates

- **Documentation**
  - Comprehensive User Guide (docs/USER_GUIDE.md)
  - Complete API Reference (docs/API_REFERENCE.md)
  - Quick start tutorial (5 minutes to first PR)
  - Troubleshooting guide (11 common issues)
  - FAQ section (10 questions)
  - Installation guides (npm, Homebrew, manual)

- **Error Handling**
  - 9 error codes (E_SUCCESS through E_TIMEOUT)
  - Structured logging (error, warn, info, debug)
  - Retry logic for network operations (exponential backoff)
  - Error log file (.pipeline/errors.log)

- **Testing**
  - Edge case test suite (30 tests across 3 categories)
  - Story ID validation tests (10 edge cases)
  - Missing dependency tests (8 scenarios)
  - Corrupted state tests (12 corruption scenarios)
  - Code generation validation suite
  - Pipeline integration tests

- **CLI Features**
  - `--version` flag (shows current version)
  - `--verbose` flag (debug logging)
  - `--debug` flag (detailed debug output)
  - `--dry-run` flag (preview without changes)
  - `--help` flag (usage information)

- **Project Type Detection**
  - Automatic language detection (package.json, go.mod, requirements.txt)
  - Appropriate test framework selection
  - Language-specific code generation

### Changed
- Error codes now follow consistent naming (E_NETWORK_FAILURE not E_NETWORK_ERROR)
- State validation uses JSON schema
- Lock timeout configurable via OPERATION_TIMEOUT

### Fixed
- Go test syntax in test suite
- State corruption recovery
- Concurrent pipeline execution (file locking)

### Security
- All user inputs validated before use
- No command injection vulnerabilities
- No path traversal vulnerabilities
- Secrets never committed (detect-secrets hook)
- Private key detection in pre-commit

## [0.9.0] - 2025-09-28 (Beta)

### Added
- Initial pipeline implementation
- Basic JIRA integration
- JavaScript and Python support
- Manual testing workflows

### Known Issues
- No security validation
- Missing error handling
- No concurrent access protection
- Limited documentation

## [0.5.0] - 2025-09-15 (Alpha)

### Added
- Proof of concept implementation
- Basic test generation
- Simple state management

---

## Upgrade Guide

### Upgrading from v0.9.0 to v1.0.0

**Breaking Changes:**
- State file format changed - migration required
- Error codes changed (use new constants)
- Environment variables updated

**Migration Steps:**

```bash
# 1. Backup existing state
cp .pipeline/state.json .pipeline/state.json.backup

# 2. Pull latest version
git pull origin main

# 3. Reinstall
./install.sh

# 4. Migrate state (if needed)
# State format is backward compatible for v0.9.0
# No migration needed

# 5. Update scripts using error codes
# Old: $E_NETWORK_ERROR
# New: $E_NETWORK_FAILURE
```

### Upgrading from v0.5.0 to v1.0.0

**Not supported - fresh install required:**

```bash
# 1. Export work in progress
cp -r .pipeline .pipeline.old

# 2. Fresh install
rm -rf .pipeline
./pipeline.sh init

# 3. Manually migrate stories
# State format incompatible - manual migration needed
```

---

## Version History

### Version Numbering

We use [Semantic Versioning](https://semver.org/):

- **MAJOR** version (1.x.x): Incompatible API changes
- **MINOR** version (x.1.x): New functionality (backward compatible)
- **PATCH** version (x.x.1): Bug fixes (backward compatible)

### Release Cadence

- **Major releases**: Every 6-12 months
- **Minor releases**: Every 1-2 months
- **Patch releases**: As needed (bug fixes, security)

### Support Policy

- **Current version (1.0.x)**: Full support
- **Previous minor (0.9.x)**: Security fixes only (3 months)
- **Older versions**: No support

---

## Getting Updates

### Check Current Version

```bash
pipeline.sh --version
# Output: Claude Pipeline v1.0.0
```

### Update to Latest

**Via npm:**
```bash
npm update -g claude-pipeline
```

**Via Homebrew:**
```bash
brew upgrade claude-pipeline
```

**Via git:**
```bash
cd claude-code-agents
git pull origin main
./install.sh
```

### Update Notifications

**Enable auto-check (optional):**
```bash
# Add to ~/.bashrc or ~/.zshrc
export PIPELINE_CHECK_UPDATES=1
```

This will check for updates once per day and notify if a new version is available.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Reporting bugs
- Suggesting features
- Submitting pull requests
- Development setup

---

## Links

- [Homepage](https://github.com/anthropics/claude-code-agents)
- [Documentation](https://github.com/anthropics/claude-code-agents/tree/main/docs)
- [Issue Tracker](https://github.com/anthropics/claude-code-agents/issues)
- [Discussions](https://github.com/anthropics/claude-code-agents/discussions)
- [Releases](https://github.com/anthropics/claude-code-agents/releases)

---

**Note:** This changelog is maintained manually. For a complete list of changes, see the [commit history](https://github.com/anthropics/claude-code-agents/commits/main).
