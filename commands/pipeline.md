# Pipeline Command

Execute complete workflow from requirements to deployment with state management.

## Usage
```bash
/pipeline [stage] [options]

# Stages:
/pipeline requirements "Initiative description"
/pipeline gherkin
/pipeline stories
/pipeline work STORY-ID
/pipeline complete STORY-ID
/pipeline status
/pipeline resume
```

## What It Does

Manages the complete agile workflow:
1. **requirements** - Generates comprehensive requirements document
2. **gherkin** - Creates BDD scenarios with Feature/Rule/Example
3. **stories** - Creates JIRA hierarchy with rich descriptions
4. **work** - Implements story with TDD and PR
5. **complete** - Reviews, merges, and closes story

## Implementation

Use pipeline-controller agent:
```javascript
await Task({
  subagent_type: "general-purpose",
  description: "Pipeline execution",
  prompt: `Use pipeline-controller agent to execute: ${stage} ${options}`
});
```

## State Management

Pipeline maintains state in pipeline-state.json:
```json
{
  "stage": "work",
  "projectKey": "PROJ",
  "epicId": "PROJ-100",
  "currentStory": "PROJ-103",
  "branch": "feature/PROJ-103",
  "pr": 456,
  "step": 4,
  "totalSteps": 7
}
```

## Examples

### Complete workflow:
```bash
/pipeline requirements "Build shopping cart"
/pipeline gherkin
/pipeline stories
/pipeline work PROJ-103
/pipeline complete PROJ-103
```

### Check status:
```bash
/pipeline status
# Output: Stage: work, Step 4 of 7, Next: Run tests
```

### Resume after interruption:
```bash
/pipeline resume
# Continues from last successful step
```

## Output Format

Every command shows:
```
STAGE: [stage_name]
STEP: [X of Y]
ACTION: [current action]
RESULT: [outcome]
NEXT: [next step]
```