# Pipeline State Transitions

## State Flow Diagram

```
┌─────────┐
│  ready  │ ← Initial state
└────┬────┘
     │ /pipeline requirements
     ↓
┌─────────────┐
│requirements │ ← Generate requirements document
└──────┬──────┘
       │ /pipeline gherkin
       ↓
┌─────────┐
│ gherkin │ ← Create BDD scenarios
└────┬────┘
     │ /pipeline stories
     ↓
┌─────────┐
│ stories │ ← Create JIRA hierarchy
└────┬────┘
     │ /pipeline work STORY-ID
     ↓
┌─────────┐
│  work   │ ← Implement story with TDD
└────┬────┘
     │ /pipeline complete STORY-ID
     ↓
┌──────────┐
│ complete │ ← Review, merge, close
└────┬─────┘
     │
     ├─→ /pipeline work NEXT-ID (loop to work)
     │
     └─→ /pipeline deploy (optional)
         ↓
    ┌────────┐
    │ deploy │ ← Deploy to production
    └────────┘
```

## Valid Transitions

| From State | Command | To State | Description |
|------------|---------|----------|-------------|
| ready | `/pipeline requirements` | requirements | Start new feature |
| requirements | `/pipeline gherkin` | gherkin | Create scenarios |
| gherkin | `/pipeline stories` | stories | Create JIRA items |
| stories | `/pipeline work ID` | work | Start implementation |
| work | `/pipeline complete ID` | complete | Finish story |
| complete | `/pipeline work ID` | work | Start next story |
| complete | `/pipeline deploy` | deploy | Deploy to production |
| deploy | `/pipeline requirements` | requirements | Start new feature |
| any | `/pipeline reset` | ready | Reset pipeline |
| any | `/pipeline status` | same | Check current state |

## Error States

When an error occurs, additional state fields are added:

```json
{
  "stage": "work",
  "error": true,
  "errorDetails": "Tests failing",
  "errorStage": "work",
  "errorStep": 5
}
```

### Error Recovery Options

| Command | Action | Result |
|---------|--------|--------|
| `/pipeline retry` | Retry failed step | Continues from error point |
| `/pipeline skip` | Skip failed step | Moves to next step |
| `/pipeline reset` | Start over | Returns to ready state |
| `/pipeline resume` | Continue from last good | Resumes workflow |

## State Persistence

State is stored in `pipeline-state.json`:

```json
{
  "stage": "work",
  "projectKey": "PROJ",
  "epicId": "PROJ-100",
  "featureStories": ["PROJ-101", "PROJ-102"],
  "ruleStories": ["PROJ-103", "PROJ-104"],
  "tasks": ["PROJ-105", "PROJ-106"],
  "currentStory": "PROJ-105",
  "branch": "feature/PROJ-105",
  "pr": 456,
  "step": 4,
  "totalSteps": 7,
  "lastAction": "Tests passed",
  "nextAction": "Commit changes",
  "completedStories": ["PROJ-103", "PROJ-104"],
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## Guards and Validations

### Pre-transition Guards

1. **requirements → gherkin**
   - Requires: requirements.md exists
   - Validates: File has content

2. **gherkin → stories**
   - Requires: features/*.feature exists
   - Validates: Valid Gherkin syntax

3. **stories → work**
   - Requires: Story ID provided
   - Validates: Story exists in tracker

4. **work → complete**
   - Requires: PR created
   - Validates: Tests passing

5. **complete → deploy**
   - Requires: All stories complete
   - Validates: Main branch clean

## Automatic Transitions

Some transitions happen automatically:

1. **Error Detection**: Any command failure adds error state
2. **Step Progress**: Within a stage, steps increment automatically
3. **Story Completion**: Marks story in completedStories array

## State Query Commands

| Command | Description | Output |
|---------|-------------|--------|
| `/pipeline status` | Current state and progress | Stage, step, next action |
| `/pipeline history` | Recent state changes | Last 10 transitions |
| `/pipeline stories list` | List all stories | Created, in progress, completed |
| `/pipeline validate` | Check state consistency | Validation results |

## Best Practices

1. **Always Check Status First**
   ```bash
   /pipeline status
   ```

2. **Complete Current Stage**
   Don't skip stages unless recovering from error

3. **Use Resume After Interruption**
   ```bash
   /pipeline resume
   ```

4. **Reset Only When Necessary**
   Preserve state when possible for audit trail

5. **Monitor Error States**
   Check errorDetails for recovery hints

## Example Flow

```bash
# Start new feature
/pipeline requirements "User authentication"
# State: requirements

/pipeline gherkin
# State: gherkin

/pipeline stories
# State: stories, created PROJ-100 to PROJ-106

/pipeline work PROJ-103
# State: work, currentStory: PROJ-103

# If error occurs
/pipeline status
# Shows: error: true, errorDetails: "Test failed"

/pipeline retry
# Retries failed step

/pipeline complete PROJ-103
# State: complete, completedStories: ["PROJ-103"]

/pipeline work PROJ-104
# State: work, currentStory: PROJ-104
```

This state machine ensures predictable, trackable workflow execution with clear recovery paths.