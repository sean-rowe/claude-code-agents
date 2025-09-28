# Story Breakdown Command

Creates JIRA stories from Gherkin scenarios with subtasks, acceptance criteria, and full tracking.

## Usage
```
/story-breakdown [feature-file]
```

Examples:
- `/story-breakdown features/authentication.feature` - Create stories from specific feature
- `/story-breakdown` - Process all feature files and create stories

## Prerequisites

1. **Install ACLI** (Atlassian Command Line Interface)
```bash
npm install -g @atlassian/acli
```

2. **Configure ACLI** with your JIRA instance
```bash
acli configure
# Enter your JIRA URL, username, and API token
```

3. **Test Connection**
```bash
acli jira project list
```

## What This Command Does

1. **Parses Gherkin Features**
   - Reads `.feature` files
   - Extracts scenarios as stories
   - Identifies acceptance criteria
   - Estimates story points

2. **Creates JIRA Stories**
   - User story format: "As a... I want... So that..."
   - Adds Gherkin as acceptance criteria
   - Sets Definition of Done
   - Estimates points based on complexity

3. **Generates Subtasks**
   - Write Gherkin scenario
   - Create step definitions
   - Implement functionality
   - Write unit tests
   - Code review
   - Documentation
   - Stakeholder demo

4. **Tracks Progress**
   - Updates subtask status
   - Adds test results as comments
   - Attaches coverage reports
   - Verifies completion

## Command Implementation

```javascript
async function storyBreakdown(featureFile) {
  await Task({
    subagent_type: "general-purpose",
    description: "Create JIRA stories",
    prompt: `Use story-creator agent to:

1. SETUP PHASE:
   - Verify ACLI is installed and configured
   - Test JIRA connection
   - Get current project key

2. PARSE PHASE:
   - Read ${featureFile || 'all feature files'}
   - Extract scenarios as potential stories
   - Parse "As a... I want... So that..." from features
   - Identify acceptance criteria from Given/When/Then

3. STORY CREATION:
   For each scenario, create a JIRA story with:
   - Title: Scenario name
   - Description: User story format
   - Acceptance Criteria: Gherkin steps
   - Definition of Done checklist
   - Story points estimate
   - Labels: bdd, gherkin, automated-test

4. SUBTASK GENERATION:
   Create subtasks for each story:
   - Write Gherkin scenario (1h)
   - Create step definitions (2h)
   - Implement functionality (4h)
   - Write unit tests (2h)
   - Code review (1h)
   - Documentation (1h)
   - Stakeholder demo (30m)

5. EPIC CREATION:
   - Create epic to group all stories
   - Link stories to epic
   - Add to current/next sprint

6. REPORTING:
   Show created stories with:
   - Story IDs
   - Points total
   - Sprint assignment
   - Epic link

Output format:
Created X stories in project PROJ:
- PROJ-123: User Login (5 points)
- PROJ-124: Password Reset (3 points)
Epic: PROJ-100
Sprint: Active Sprint #15`
  });
}
```

## Example Feature to Stories

### Input: authentication.feature
```gherkin
Feature: User Authentication
  As a registered user
  I want to securely log in
  So that I can access my account

  Scenario: Successful login
    Given I have a valid account
    When I enter correct credentials
    Then I should be logged in

  Scenario: Password reset
    Given I have forgotten my password
    When I request a password reset
    Then I should receive a reset email
```

### Output: JIRA Stories

#### Story 1: PROJ-123 - Successful login
```markdown
## User Story
As a registered user
I want to securely log in
So that I can access my account

## Acceptance Criteria
- Given I have a valid account
- When I enter correct credentials
- Then I should be logged in

## Definition of Done
✅ Gherkin scenario implemented
✅ Step definitions created
✅ BDD tests passing
✅ Unit tests >90% coverage
✅ Code reviewed
✅ Deployed to staging
✅ Stakeholder demo complete

## Subtasks
1. PROJ-123-1: Write Gherkin scenario
2. PROJ-123-2: Create step definitions
3. PROJ-123-3: Implement login functionality
4. PROJ-123-4: Write unit tests
5. PROJ-123-5: Code review
6. PROJ-123-6: Documentation
7. PROJ-123-7: Demo to stakeholder
```

## Story Tracking

The command also provides tracking capabilities:

```javascript
// Track story progress
/story-track PROJ-123

// Output:
Story PROJ-123: Successful login
Status: In Progress
Progress: 3/7 subtasks complete
  ✅ Write Gherkin scenario
  ✅ Create step definitions
  ✅ Implement functionality
  ⏳ Write unit tests (In Progress)
  ⌛ Code review
  ⌛ Documentation
  ⌛ Demo to stakeholder

Test Status:
- BDD Tests: ✅ Passing
- Unit Tests: 87% coverage
- Build: ✅ Success
```

## Batch Processing

Process all features at once:

```bash
/story-breakdown

Scanning features directory...
Found 5 feature files:
- authentication.feature (3 scenarios)
- user-management.feature (5 scenarios)
- payment.feature (4 scenarios)
- reporting.feature (2 scenarios)
- settings.feature (3 scenarios)

Creating 17 stories...
✅ Created PROJ-123 through PROJ-139
✅ Created epic PROJ-100: "BDD Implementation"
✅ Added to Sprint 15
✅ Total points: 68

Next: Run /work-on-story PROJ-123 to start implementation
```

## Integration with Other Commands

After creating stories:
1. `/bdd-setup` - Optimize Gherkin and create step definitions
2. `/work-on-story PROJ-123` - Start implementing a story
3. `/production-orchestrator` - Full implementation pipeline
4. `/story-track PROJ-123` - Check story progress

## Benefits

1. **Traceability** - Links Gherkin to JIRA stories
2. **Automation** - No manual story creation
3. **Consistency** - All stories follow same format
4. **Tracking** - Full visibility of progress
5. **Integration** - Works with existing workflow