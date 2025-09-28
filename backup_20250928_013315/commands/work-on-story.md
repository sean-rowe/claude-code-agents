# Work On Story Command

Automated story workflow from ticket retrieval to merged PR with review handling.

## Usage
```
/work-on-story [STORY-ID]
```

Examples:
- `/work-on-story PROJ-123` - Start working on JIRA story
- `/work-on-story 456` - Start working on GitHub issue #456
- `/work-on-story AB#789` - Start working on Azure DevOps item

## What This Command Does

Complete automated workflow:

1. **Detects Your Tools**
   - Checks for `acli` (JIRA)
   - Checks for `gh` (GitHub)
   - Checks for `az` (Azure DevOps)

2. **Retrieves Story Details**
   - Gets title, description, acceptance criteria
   - Extracts requirements and test scenarios
   - Updates status to "In Progress"

3. **Creates Feature Branch**
   - Smart naming: `feature/STORY-123-descriptive-title`
   - Or `bugfix/` for bugs, `hotfix/` for hotfixes
   - Pushes branch and sets upstream

4. **Implements Story**
   - Writes BDD tests from acceptance criteria
   - Implements with TDD (Red-Green-Refactor)
   - Commits with conventional commits
   - Links commits to story

5. **Creates Pull Request**
   - Generates PR description from story
   - Links PR to original ticket
   - Adds appropriate labels
   - Requests reviewers

6. **Handles PR Reviews**
   - Monitors for review comments
   - Auto-fixes common issues:
     - Adds missing tests
     - Adds documentation
     - Fixes type issues
     - Adds error handling
   - Responds to reviewers
   - Re-requests review

7. **Completes Story**
   - Merges PR when approved
   - Updates ticket status to "Done"
   - Deletes feature branch
   - Updates sprint metrics

## Automated Tool Detection

```javascript
async function detectTracker() {
  if (await commandExists('acli')) {
    console.log('Using JIRA (acli detected)');
    return { type: 'jira', cli: 'acli' };
  } else if (await commandExists('gh')) {
    console.log('Using GitHub Issues (gh detected)');
    return { type: 'github', cli: 'gh' };
  } else if (await commandExists('az')) {
    console.log('Using Azure DevOps (az detected)');
    return { type: 'azure', cli: 'az' };
  }
  throw new Error('No issue tracker found. Install acli, gh, or az');
}
```

## Story Retrieval Examples

### JIRA (acli)
```bash
# Get story details
acli jira issue get PROJ-123 --output json

# Update status
acli jira issue transition PROJ-123 --transition "In Progress"

# Add comment with PR link
acli jira issue comment add PROJ-123 --comment "PR: https://github.com/..."
```

### GitHub (gh)
```bash
# Get issue details
gh issue view 456 --json title,body,labels

# Update labels
gh issue edit 456 --add-label "in-progress"

# Link PR
gh issue comment 456 --body "PR: #789"
```

### Azure DevOps (az)
```bash
# Get work item
az boards work-item show --id 789

# Update state
az boards work-item update --id 789 --state "Active"

# Link PR
az repos pr create --work-items 789
```

## Branch Creation Strategy

```bash
# Intelligent branch naming
STORY-123: "Add user authentication" → feature/STORY-123-add-user-authentication
BUG-456: "Fix login error" → bugfix/BUG-456-fix-login-error
HOTFIX-789: "Critical security patch" → hotfix/HOTFIX-789-security-patch
```

## PR Review Automation

The command automatically handles common review requests:

| Review Comment | Automated Fix |
|----------------|---------------|
| "Add test for this" | Generates and adds test |
| "Missing documentation" | Adds JSDoc/docstring |
| "Handle error case" | Wraps in try-catch |
| "Remove any type" | Infers proper type |
| "Fix linting" | Runs linter and fixes |

## Complete Workflow Example

```typescript
async function workOnStory(storyId: string) {
  // 1. Detect tracker
  const tracker = await detectTracker();
  console.log(`Using ${tracker.type} with ${tracker.cli}`);

  // 2. Get story
  const story = await Task({
    subagent_type: "general-purpose",
    description: "Get story details",
    prompt: `Use story-workflow agent to retrieve ${storyId} from ${tracker.type}`
  });

  // 3. Create branch
  await Task({
    subagent_type: "general-purpose",
    description: "Create branch",
    prompt: `Create feature branch for ${storyId}: ${story.title}`
  });

  // 4. Implement
  await Task({
    subagent_type: "general-purpose",
    description: "Implement story",
    prompt: `
      Implement ${storyId} using TDD:
      - Write BDD tests from acceptance criteria
      - Implement minimal code to pass
      - Refactor for clean code
      - Ensure SOLID principles
    `
  });

  // 5. Create PR
  const pr = await Task({
    subagent_type: "general-purpose",
    description: "Create PR",
    prompt: `Create PR for ${storyId} and link to ${tracker.type} ticket`
  });

  // 6. Monitor reviews
  await Task({
    subagent_type: "general-purpose",
    description: "Handle reviews",
    prompt: `Use pr-review agent to monitor PR ${pr.number} and auto-fix issues`
  });

  // 7. Complete
  await Task({
    subagent_type: "general-purpose",
    description: "Complete story",
    prompt: `
      When PR is approved:
      - Merge PR
      - Update ${tracker.type} ticket to Done
      - Delete feature branch
    `
  });
}
```

## Status Updates

Throughout the process, you'll see:

```
📋 Retrieved story PROJ-123: "Add user authentication"
🌿 Created branch: feature/PROJ-123-add-user-authentication
✅ Updated JIRA status to "In Progress"
🧪 Writing BDD tests...
💻 Implementing feature...
✅ All tests passing
🔄 Created PR #456
🔗 Linked PR to JIRA ticket
👀 Monitoring for review comments...
🔧 Found review comment - adding missing test...
✅ Fixed and pushed
🎯 PR approved and merged
✅ Updated JIRA status to "Done"
🗑️ Deleted feature branch
```

## Configuration

The command auto-detects your setup, but you can configure defaults:

```json
// .claude/story-workflow.json
{
  "tracker": "jira",  // or "github", "azure"
  "defaultReviewers": ["teammate1", "teammate2"],
  "autoMerge": true,
  "deletebranchAfterMerge": true,
  "transitionNames": {
    "start": "In Progress",
    "complete": "Done"
  }
}
```

## PR Review Monitoring

Once PR is created, the pr-review agent:
- Polls for new comments every 60 seconds
- Categorizes comments (test, docs, types, etc.)
- Auto-fixes what it can
- Commits fixes
- Responds to reviewer
- Re-requests review

## Success Criteria

Story is complete when:
- ✅ All acceptance criteria implemented
- ✅ All tests passing (>90% coverage)
- ✅ PR approved by reviewers
- ✅ All review comments addressed
- ✅ Security scans passed
- ✅ Performance benchmarks met
- ✅ PR merged to main branch
- ✅ Ticket updated to "Done"
- ✅ Feature branch deleted

This provides a complete, automated workflow from "start working on story" to "merged and done"!