# Pipeline Quick Start Guide

## ✅ Installation Complete

The pipeline system is now installed and ready to use!

## Available Systems

### 1. Complete Pipeline (NEW - Recommended)
Full workflow with state management and rich JIRA descriptions:
```bash
/pipeline requirements "Your initiative"
/pipeline gherkin
/pipeline stories
/pipeline work STORY-ID
/pipeline complete STORY-ID
/pipeline status
```

### 2. Simplified Commands (Alternative)
Basic workflow for simple projects:
```bash
/setup
/implement STORY-ID
/review
/deploy
```

## First Time Setup

### For JIRA Projects
```bash
# Run this once per project
~/.claude/jira-hierarchy-setup.sh PROJ "Project Name"
```

### For GitHub/Local Projects
```bash
# Simple setup
/setup
```

## Complete Workflow Example

### Step 1: Generate Requirements
```bash
/pipeline requirements "Build user authentication system"
```
Creates comprehensive `requirements.md` with:
- Functional requirements with acceptance criteria
- Non-functional requirements with metrics
- Success metrics
- Dependencies

### Step 2: Create Gherkin Scenarios
```bash
/pipeline gherkin
```
Creates `features/*.feature` with:
- Feature descriptions
- Rules for business logic
- Concrete examples with test data

### Step 3: Create JIRA Hierarchy
```bash
/pipeline stories
```
Creates in JIRA:
- Epic with business value and ROI
- Feature stories with Gherkin
- Rule stories with rationale
- Implementation tasks

### Step 4: Implement Story
```bash
/pipeline work PROJ-103
```
Executes:
1. Creates feature branch
2. Writes failing tests (TDD Red)
3. Implements code (TDD Green)
4. Commits and pushes
5. Creates PR
6. Updates JIRA to "In Review"

### Step 5: Complete Story
```bash
/pipeline complete PROJ-103
```
Handles:
1. Fetches PR comments
2. Addresses feedback
3. Gets approval
4. Merges PR
5. Updates JIRA to "Done"

## Check Status Anytime

```bash
/pipeline status
```
Shows:
- Current stage
- Progress (Step X of Y)
- Current story
- Next action

## Pipeline State

State is maintained in `pipeline-state.json`:
```json
{
  "stage": "work",
  "currentStory": "PROJ-103",
  "step": 4,
  "totalSteps": 7,
  "nextAction": "Run tests"
}
```

## Key Benefits

1. **Linear Execution** - No confusion about what to do next
2. **State Preservation** - Resume from where you left off
3. **Rich Context** - Every JIRA item explains WHY and VALUE
4. **Complete Workflow** - Requirements to deployment
5. **Predictable** - Same input, same output every time

## Templates

Templates are in `~/.claude/pipeline-templates/`:
- `requirements.md` - Requirements template
- `epic-description.md` - JIRA epic template
- `story-description.md` - JIRA story template

## Troubleshooting

### Reset Pipeline State
```bash
~/.claude/pipeline-state-manager.sh reset
```

### Check Current State
```bash
cat pipeline-state.json
```

### Resume After Interruption
```bash
/pipeline resume
```

## What's Different?

### Old System (Complex)
- 20+ agents with overlapping responsibilities
- 58+ commands to remember
- Nested agent calls causing confusion
- 600+ line JSON configurations

### New Pipeline (Simple)
- Single pipeline controller
- 5 clear stages
- Linear execution with state
- Clear progress indicators

## Next Steps

1. **Try a simple test**:
   ```bash
   /pipeline requirements "Build a contact form"
   /pipeline gherkin
   ```

2. **Check the generated files**:
   - `requirements.md`
   - `features/contact-form.feature`

3. **Continue with JIRA** (if configured):
   ```bash
   /pipeline stories
   ```

## Need Help?

- View examples: `cat COMPLETE_WORKFLOW_EXAMPLE.md`
- View architecture: `cat WORKFLOW_PRESERVED_REFACTOR.md`
- Check status: `/pipeline status`

The pipeline preserves ALL your sophisticated workflow features while making it simple enough for Claude to execute reliably!