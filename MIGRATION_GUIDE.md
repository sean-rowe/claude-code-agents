# Migration Guide: Old Scripts → New Structure

## Overview

The codebase has been reorganized to eliminate duplication and improve maintainability.

## New Directory Structure

```
.
├── lib/
│   └── jira-client.sh          # Centralized JIRA operations library
├── scripts/
│   ├── setup/
│   │   └── setup-jira.sh       # Unified JIRA project setup
│   └── utils/
│       └── diagnose-jira.sh    # Unified JIRA diagnostics
├── pipeline.sh                  # Main pipeline (now with real implementation)
├── pipeline-state-manager.sh   # State management
└── install.sh                   # Installation script
```

## Deprecated Scripts

The following scripts have been **consolidated** and should no longer be used:

### Replaced by `lib/jira-client.sh` + `scripts/setup/setup-jira.sh`:
- ❌ `jira-hierarchy-setup.sh`
- ❌ `setup-jira-hierarchy.sh`
- ❌ `setup-jira-admin.sh`

### Replaced by `scripts/utils/diagnose-jira.sh`:
- ❌ `diagnose-jira-templates.sh`
- ❌ `check-jira-hierarchy.sh`
- ❌ `test-jira-api.sh`

### Replaced by `lib/jira-client.sh` functionality:
- ❌ `get-projects.sh`
- ❌ `apply-types-to-all-projects.sh`
- ❌ `apply-custom-types-globally.sh`
- ❌ `setup-via-rest-api.sh`

## Migration Instructions

### If you were using:

#### `jira-hierarchy-setup.sh PROJ "My Project"`
**New command:**
```bash
./scripts/setup/setup-jira.sh PROJ "My Project"
```

#### `diagnose-jira-templates.sh` or `check-jira-hierarchy.sh`
**New command:**
```bash
./scripts/utils/diagnose-jira.sh PROJ
```

#### Custom JIRA operations in your own scripts
**New approach:**
```bash
#!/bin/bash
source lib/jira-client.sh

# Now you have access to:
# - project_exists <key>
# - create_project <key> <name>
# - create_epic <project> <summary> <description>
# - create_story <project> <summary> <description> [parent]
# - get_issue_types <project>
# - verify_project_issue_types <project> type1 type2 ...
# - diagnose_connection
# ... and more
```

## What Changed in Core Scripts

### `pipeline.sh`
**BEFORE (v1.0):**
- Work stage only printed what "would be" done (placeholder code)

**NOW (v2.0):**
- ✅ Actually creates git branches
- ✅ Actually generates test files (Jest/Go/pytest/bash)
- ✅ Actually creates implementation files
- ✅ Actually runs tests
- ✅ Actually commits and pushes to git

### `agents/implementer.json`
**BEFORE:**
- Had placeholder comments like `# Create test file with failing test`

**NOW:**
- ✅ Contains actual heredoc templates for test generation
- ✅ Contains actual implementation file generation

## Benefits of New Structure

1. **No Duplication**: One JIRA client library instead of 9+ scripts
2. **Consistent Error Handling**: All scripts use `set -euo pipefail`
3. **Better Testability**: Library functions can be tested independently
4. **Easier Maintenance**: Fix a bug once in the library, not in 9 scripts
5. **Real Implementation**: No more placeholder code

## Cleanup (Optional)

To remove deprecated scripts:

```bash
# Backup first
mkdir -p .deprecated
mv jira-hierarchy-setup.sh .deprecated/
mv setup-jira-hierarchy.sh .deprecated/
mv setup-jira-admin.sh .deprecated/
mv diagnose-jira-templates.sh .deprecated/
mv check-jira-hierarchy.sh .deprecated/
mv test-jira-api.sh .deprecated/
mv get-projects.sh .deprecated/
mv apply-types-to-all-projects.sh .deprecated/
mv apply-custom-types-globally.sh .deprecated/
mv setup-via-rest-api.sh .deprecated/

echo "Deprecated scripts moved to .deprecated/"
echo "After confirming everything works, you can delete this directory"
```

## Environment Variables

The new JIRA client supports both acli and REST API:

```bash
# For REST API (optional, acli is preferred)
export JIRA_URL="https://your-domain.atlassian.net"
export JIRA_EMAIL="your-email@example.com"
export JIRA_API_TOKEN="your-api-token"

# For acli (recommended)
acli jira auth login
```

## Need Help?

- **Setup a new project**: `./scripts/setup/setup-jira.sh PROJ "Project Name"`
- **Diagnose issues**: `./scripts/utils/diagnose-jira.sh PROJ`
- **Use library in scripts**: `source lib/jira-client.sh`
- **Report issues**: Create an issue in the repository
