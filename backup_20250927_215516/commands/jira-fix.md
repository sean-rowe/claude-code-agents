---
name: jira-fix
description: Fix improperly created JIRA stories - converts fake subtasks to real subtasks and fixes formatting
type: agent
agent_name: jira-fix
---

# /jira-fix

Fixes JIRA stories that were created incorrectly:
- Converts stories that should be subtasks into proper subtasks
- Fixes markdown formatting to JIRA wiki markup
- Adds meaningful descriptions
- Ensures proper parent-child relationships

## What It Fixes

1. **Wrong Issue Types**: Stories created as "Sub-task" type instead of "Subtask"
2. **Wrong Formatting**: Markdown (`**bold**`, `\n`) converted to wiki (`*bold*`, `\r\n`)
3. **Missing Descriptions**: Adds comprehensive context to all items
4. **Structure Problems**: Ensures scenarios appear as subtasks under stories

## Usage

```
/jira-fix
```

The agent will:
1. Analyze all stories in the project
2. Identify issues (fake subtasks, wrong formatting)
3. Create proper subtasks with correct parent
4. Delete old incorrect issues
5. Fix all formatting issues
6. Verify everything worked

## When to Use

- After running old version of jira-setup that created wrong types
- When subtasks don't appear under stories in swimlanes
- When descriptions show markdown instead of formatted text
- To add missing descriptions and context

## Example Output

```
🔍 Analyzing JIRA project: ACTIONS
Found 7 stories with 5 fake subtasks

🔧 Converting ACTIONS-2 from story to subtask under ACTIONS-1
✅ Created proper subtask ACTIONS-8
🗑️ Deleted old issue ACTIONS-2

✅ Fixed 5 fake subtasks
✅ Fixed 7 formatting issues
```