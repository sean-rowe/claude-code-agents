# ACLI JIRA Command Reference

## CORRECT Command Structure

The correct structure for ACLI JIRA commands is:
```
acli jira [resource] [action] [options]
```

## Key Resources:
- `project` - For project management
- `workitem` - For issues/stories/tasks/subtasks
- `user` - For user management
- `dashboard` - For dashboard operations
- `filter` - For filter operations

## Project Commands

### List Projects
```bash
# List all projects
acli jira project list

# List with pagination
acli jira project list --paginate

# List in JSON format
acli jira project list --json --limit 50

# List recent projects
acli jira project list --recent
```

### Create Project
```bash
# Create from existing project (recommended)
acli jira project create --from-project "DEMO" --key "NEWKEY" --name "Project Name"

# Create with all options
acli jira project create \
  --from-project "DEMO" \
  --key "PROJ" \
  --name "Project Name" \
  --description "Project description" \
  --lead-email "user@example.com" \
  --url "https://example.com"

# Create from JSON
acli jira project create --from-json "project.json"
```

### View Project
```bash
acli jira project view --key "PROJ"
acli jira project view --key "PROJ" --json
```

### Update/Delete Project
```bash
acli jira project update --key "PROJ" --name "New Name"
acli jira project delete --key "PROJ"
acli jira project archive --key "PROJ"
acli jira project restore --key "PROJ"
```

## Work Item Commands (Issues/Stories/Tasks)

### Search Work Items
```bash
# Search with JQL
acli jira workitem search --jql "project = PROJ AND issuetype = Story"

# Search with options
acli jira workitem search \
  --jql "project = PROJ" \
  --fields "key,summary,status,issuetype" \
  --limit 100 \
  --json

# Search with CSV output
acli jira workitem search --jql "project = PROJ" --csv

# Search with pagination
acli jira workitem search --jql "project = PROJ" --paginate
```

### View Work Item
```bash
acli jira workitem view --key "PROJ-123"
acli jira workitem view --key "PROJ-123" --json
acli jira workitem view --key "PROJ-123" --fields "summary,description,status"
```

### Create Work Item
```bash
# Create a story
acli jira workitem create \
  --type "Story" \
  --project "PROJ" \
  --summary "Story title" \
  --description "Story description"

# Create a task
acli jira workitem create \
  --type "Task" \
  --project "PROJ" \
  --summary "Task title" \
  --description "Task description"

# Create a subtask
acli jira workitem create \
  --type "Subtask" \
  --parent "PROJ-123" \
  --summary "Subtask title" \
  --description "Subtask description"

# Create with description from file
acli jira workitem create \
  --type "Story" \
  --project "PROJ" \
  --summary "Title" \
  --description-file "/tmp/desc.txt"
```

### Edit Work Item
```bash
# Update description
acli jira workitem edit --key "PROJ-123" --description "New description"

# Update from file
acli jira workitem edit --key "PROJ-123" --description-file "/tmp/desc.txt" --yes

# Update summary
acli jira workitem edit --key "PROJ-123" --summary "New title"

# Assign
acli jira workitem assign --key "PROJ-123" --assignee "user@example.com"

# Transition
acli jira workitem transition --key "PROJ-123" --status "In Progress"
```

### Delete Work Item
```bash
acli jira workitem delete --key "PROJ-123"
acli jira workitem archive --key "PROJ-123"
```

## User Commands
```bash
# Get current user
acli jira user current
acli jira user current --json
```

## Common Patterns

### Check if project exists
```bash
if acli jira project list --json | grep -q '"key":"PROJ"'; then
  echo "Project exists"
else
  echo "Project does not exist"
fi
```

### Get project URL
```bash
# Extract URL from project list
JIRA_URL=$(acli jira project view --key "PROJ" --json | jq -r '.self' | sed 's|/rest/api/.*||')
```

### Count issues
```bash
# Count stories in project
STORY_COUNT=$(acli jira workitem search --jql "project = PROJ AND issuetype = Story" --json | jq '. | length')
```

## Important Notes

1. **NO `acli jira issue` command** - Use `acli jira workitem` instead
2. **Issue types**: Use exact case - "Story", "Task", "Bug", "Subtask" (not "Sub-task")
3. **JSON output**: Most commands support `--json` for parsing
4. **JQL queries**: Must be quoted properly in bash
5. **Description files**: Use `--description-file` for complex formatting

## Error Handling

Common errors and solutions:
- `unknown flag: --project` → Use `--jql "project = PROJ"` instead
- `unknown command: issue` → Use `workitem` instead
- `type 'Sub-task' not found` → Use "Subtask" instead