# Jira Custom Hierarchy Setup Guide

## Your Custom Hierarchy: Feature → Epic → Rule → Scenario

Since you have Jira Premium, you can create this exact 4-level hierarchy. Your project is **CUEM** (CueMap).

## Manual Setup Steps (Required for Admin Configuration)

### Step 1: Create Custom Issue Types
1. Go to: https://pinyridgelabs.atlassian.net/secure/admin/ViewIssueTypes.jspa
2. Click "Add issue type" and create:
   - **Feature**: "High-level feature containing multiple epics" (Standard type)
   - **Rule**: "Business rule or requirement specification" (Standard type)
   - **Scenario**: "Test scenario or use case" (Standard type or Sub-task)

### Step 2: Add Issue Types to Your Project
1. Go to Project Settings → Issue types
2. Click "Edit issue type scheme"
3. Add Feature, Rule, and Scenario to your project

### Step 3: Configure Advanced Roadmaps Hierarchy
1. Go to: Plans → Create plan (or edit existing)
2. In plan settings → Configure → Issue source configuration
3. Set hierarchy levels:
   - Level 3: Feature
   - Level 2: Epic
   - Level 1: Rule
   - Level 0: Scenario

### Step 4: Set Parent-Child Relationships
1. In Advanced Roadmaps settings
2. Configure which types can be parents/children:
   - Feature can contain Epics
   - Epic can contain Rules
   - Rule can contain Scenarios

## Automated Check and Creation Script

```bash
#!/bin/bash
# File: check-and-create-hierarchy.sh

PROJECT_KEY="CUEM"

echo "Checking CUEM project for custom hierarchy..."

# Check if custom types exist
acli jira workitem create --type "Feature" --project "$PROJECT_KEY" --summary "Test" --dry-run 2>&1 | grep -q "Error"
HAS_FEATURE=$?

acli jira workitem create --type "Rule" --project "$PROJECT_KEY" --summary "Test" --dry-run 2>&1 | grep -q "Error"
HAS_RULE=$?

acli jira workitem create --type "Scenario" --project "$PROJECT_KEY" --summary "Test" --dry-run 2>&1 | grep -q "Error"
HAS_SCENARIO=$?

if [ $HAS_FEATURE -ne 0 ] || [ $HAS_RULE -ne 0 ] || [ $HAS_SCENARIO -ne 0 ]; then
    echo "❌ Custom issue types not found!"
    echo "Please create them manually using the steps above"
    exit 1
fi

echo "✅ Custom hierarchy is configured!"
```

## Testing Your Hierarchy

Once configured, test with:

```bash
# Create a Feature
FEATURE=$(acli jira workitem create \
  --type "Feature" \
  --project "CUEM" \
  --summary "User Management System" \
  --description "Complete user management feature")

# Create an Epic under Feature
EPIC=$(acli jira workitem create \
  --type "Epic" \
  --project "CUEM" \
  --summary "User Registration" \
  --parent "$FEATURE")

# Create a Rule under Epic
RULE=$(acli jira workitem create \
  --type "Rule" \
  --project "CUEM" \
  --summary "Email must be unique" \
  --parent "$EPIC")

# Create a Scenario under Rule
SCENARIO=$(acli jira workitem create \
  --type "Scenario" \
  --project "CUEM" \
  --summary "Test duplicate email rejection" \
  --parent "$RULE")
```

## Integration with Pipeline Controller

Update the pipeline-controller agent to use this hierarchy:

```javascript
// In pipeline-controller.json stories stage:
// Create Feature first
FEATURE_ID=$(acli jira workitem create \
  --type "Feature" \
  --project "CUEM" \
  --summary "Initiative: $INITIATIVE_NAME")

// Create Epic under Feature
EPIC_ID=$(acli jira workitem create \
  --type "Epic" \
  --project "CUEM" \
  --summary "Epic for $FEATURE_NAME" \
  --parent "$FEATURE_ID")

// Create Rules under Epic
RULE_ID=$(acli jira workitem create \
  --type "Rule" \
  --project "CUEM" \
  --summary "Rule: $REQUIREMENT" \
  --parent "$EPIC_ID")

// Create Scenarios under Rule
SCENARIO_ID=$(acli jira workitem create \
  --type "Scenario" \
  --project "CUEM" \
  --summary "Scenario: $TEST_CASE" \
  --parent "$RULE_ID")
```

## Quick Check Commands

```bash
# List all work items of custom types
acli jira workitem search --jql "project = CUEM AND issuetype = Feature"
acli jira workitem search --jql "project = CUEM AND issuetype = Rule"
acli jira workitem search --jql "project = CUEM AND issuetype = Scenario"

# View hierarchy in terminal
acli jira workitem view --key CUEM-123 --with-subtasks
```

## Important Notes

1. **Admin Access Required**: Creating issue types requires Jira admin permissions
2. **Premium Features**: 4-level hierarchy requires Jira Premium (which you have)
3. **Project Key**: Your project is CUEM, not TD
4. **API Limitations**: Issue type creation cannot be fully automated via API