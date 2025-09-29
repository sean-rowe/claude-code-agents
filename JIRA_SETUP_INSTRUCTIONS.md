# JIRA Project Setup Instructions for Agents

## Creating a Proper JIRA Project with Epic/Story Support

When creating a JIRA project for BDD/TDD workflow, use the template provided in `jira-project-template.json`. This ensures the project has all required issue types including Epic, Story, Task, and Sub-task.

## Method 1: Using ACLI (Recommended)

```bash
# Create project from template
acli jira project create --file jira-project-template.json

# Or create with explicit Scrum template
acli jira project create \
  --project "PROJ" \
  --name "Project Name" \
  --lead "admin" \
  --template "com.pyxis.greenhopper.jira:gh-simplified-scrum-classic"
```

## Method 2: Manual Creation in JIRA UI

1. Go to Projects → Create Project
2. Select "Scrum" template (NOT Basic)
3. Choose "Company-managed project"
4. Configure with these settings:
   - Name: Your Project Name
   - Key: PROJ (or your prefix)
   - Template: Scrum

## Method 3: Using REST API

```bash
curl -X POST \
  -H "Authorization: Bearer $JIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -d @jira-project-template.json \
  https://your-domain.atlassian.net/rest/api/3/project
```

## Important Notes for Agents

### ⚠️ Common Mistake to Avoid
Do NOT create a project with just `"projectTypeKey": "software"` as this creates a basic project with only Task and Sub-task types. You MUST use a Scrum template to get Epic and Story issue types.

### ✅ Correct Project Structure
```
Epic (High-level feature/initiative)
├── Story (User story with acceptance criteria)
│   ├── Sub-task (Implementation task)
│   ├── Sub-task (Test task)
│   └── Sub-task (Documentation task)
├── Story (Another user story)
│   └── Sub-task (Implementation)
└── Story (Another user story)
    └── Sub-task (Implementation)
```

### 🔧 Verify Project Has Correct Issue Types
```bash
# Check available issue types
acli jira issuetype list --project PROJ

# Should return:
# - Epic
# - Story
# - Task
# - Bug
# - Sub-task
```

### 📝 Creating Issues in Hierarchy

```bash
# 1. Create Epic
EPIC_ID=$(acli jira issue create \
  --type "Epic" \
  --summary "User Authentication System" \
  --description "Complete auth system with SSO" \
  --project "PROJ" \
  --custom "epicName:Auth")

# 2. Create Story under Epic
STORY_ID=$(acli jira issue create \
  --type "Story" \
  --summary "As a user I want to login" \
  --description "Login functionality" \
  --project "PROJ" \
  --custom "epicLink:$EPIC_ID")

# 3. Create Sub-task under Story
TASK_ID=$(acli jira issue create \
  --type "Sub-task" \
  --parent "$STORY_ID" \
  --summary "Implement login API" \
  --description "REST endpoint for login")
```

### 🚫 What NOT to Do

```bash
# DON'T create a Task and try to link it as an Epic
# This will fail:
acli jira issue create --type "Task" --custom "epicName:Something"  # ❌ Wrong

# DON'T create a basic project
acli jira project create --project "PROJ" --type "software"  # ❌ Missing template
```

### ✨ Pipeline Integration

When the pipeline controller creates JIRA hierarchy:

1. **Requirements Stage** → Creates Epic
2. **Gherkin Stage** → Enriches Epic description
3. **Stories Stage** → Creates Stories under Epic
4. **Work Stage** → Creates Sub-tasks under Stories
5. **Complete Stage** → Transitions all to Done

## Troubleshooting

### Issue: "Issue type 'Epic' does not exist"
**Cause**: Project was created without Scrum template
**Fix**: Delete and recreate project with proper template

### Issue: "Cannot set epicLink custom field"
**Cause**: Epic Link field not configured
**Fix**: Enable Scrum features in project settings

### Issue: "Cannot create sub-task"
**Cause**: Sub-task issue type not enabled
**Fix**: Enable sub-tasks in project configuration

## Template Customization

The `jira-project-template.json` file can be customized:

- **projectKey**: Change to your prefix (max 10 chars, uppercase)
- **projectName**: Your project's display name
- **lead**: JIRA username of project lead
- **components**: Add/modify to match your architecture
- **customFields**: Add project-specific fields
- **workflows**: Customize state transitions
- **priorities**: Adjust to match your team's needs

## For Python Scripts

If using Python scripts to create JIRA issues:

```python
from jira import JIRA

# Connect
jira = JIRA(server='https://your-domain.atlassian.net',
           basic_auth=('email', 'api_token'))

# Create Epic
epic = jira.create_issue(
    project='PROJ',
    issuetype='Epic',
    summary='Authentication System',
    description='Complete auth with SSO',
    customfield_10011='Auth'  # Epic Name field
)

# Create Story linked to Epic
story = jira.create_issue(
    project='PROJ',
    issuetype='Story',
    summary='User login functionality',
    description='As a user...',
    customfield_10014=epic.key  # Epic Link field
)

# Create Sub-task
subtask = jira.create_issue(
    project='PROJ',
    issuetype='Sub-task',
    parent={'key': story.key},
    summary='Implement login endpoint'
)
```

## Summary

Always ensure your JIRA project:
1. Uses a Scrum template (not basic)
2. Has Epic, Story, and Sub-task issue types
3. Has Epic Link and Epic Name custom fields
4. Supports proper parent-child relationships

This enables the full BDD/TDD workflow with rich hierarchical tracking.