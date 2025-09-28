---
name: jira-clean
description: DANGEROUS - Completely wipes ALL issues from a JIRA project for fresh start
type: agent
agent_name: jira-clean
---

# /jira-clean

⚠️ **EXTREMELY DANGEROUS** ⚠️ - Completely deletes ALL issues from a JIRA project.

## What It Does

1. **Complete Deletion**: Removes EVERY issue from the project
2. **Creates Backup**: Saves list of deleted items before deletion
3. **Requires Confirmation**: Must type exact confirmation to proceed
4. **Cannot Be Undone**: This is PERMANENT deletion

## When to Use

Only use when:
- Project structure is completely wrong
- Starting fresh is faster than fixing
- Testing/development projects need reset
- You have explicit approval to wipe production data

## Safety Features

- 🔒 Requires typing `DELETE PROJECT-KEY` exactly
- 💾 Creates backup file with all issue details
- 📊 Shows count and breakdown before deletion
- ⚠️ Multiple warning prompts
- ✅ Verifies project is empty after

## Usage

```
/jira-clean
```

The agent will:
1. Detect project key from .env
2. Count all issues (Stories, Tasks, Subtasks, etc.)
3. Create backup files
4. Show final warning
5. Require exact confirmation
6. Delete all issues
7. Verify project is empty

## Example Output

```
📊 Counting all issues in project OPS...
⚠️  Found 30 issues that will be PERMANENTLY DELETED

📋 Issue breakdown:
  - 30 Tasks

💾 Creating backup list...
✅ Backup saved to: jira_deleted_20240327_143022_OPS.txt

═══════════════════════════════════════════════════════
 ⚠️  FINAL WARNING ⚠️
═══════════════════════════════════════════════════════

 You are about to PERMANENTLY DELETE:
 • Project: OPS
 • Issues: 30

 This action CANNOT be undone!

 Type exactly 'DELETE OPS' to confirm
 Or press Ctrl+C to cancel

 > DELETE OPS

🗑️  Starting deletion process...
   Progress: 30/30 deleted

✅ Project OPS is now EMPTY and ready for fresh setup

Next steps:
1. Run /jira-setup to create new structure from Gherkin
2. Or manually create new issues
```

## After Cleaning

Once project is empty:
1. Run `/jira-setup` to create proper hierarchy from Gherkin
2. Verify with `/jira-verify` that all items created correctly
3. Check backup files if you need to reference old issues

## ⚠️ WARNING ⚠️

This is a DESTRUCTIVE operation that CANNOT be reversed.
The backup files are for reference only - they cannot restore deleted issues.
NEVER use on production without explicit written approval.