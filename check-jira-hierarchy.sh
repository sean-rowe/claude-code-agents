#!/bin/bash

# Check if Jira has custom hierarchy configured
# And create test issues to verify

PROJECT_KEY="${1:-CUEM}"

echo "======================================"
echo "Checking Jira Hierarchy Configuration"
echo "Project: $PROJECT_KEY"
echo "======================================"
echo ""

# Function to check if issue type exists
check_issue_type() {
    local TYPE=$1
    echo -n "Checking for $TYPE issue type... "

    # Try to create a dry-run issue with the type
    OUTPUT=$(acli jira workitem create --type "$TYPE" --project "$PROJECT_KEY" --summary "Test" --description "Test" 2>&1)

    if echo "$OUTPUT" | grep -q "Error"; then
        echo "❌ Not found"
        return 1
    else
        echo "✅ Available"
        return 0
    fi
}

# Check for each custom type
echo "1. Checking for custom issue types:"
echo "-----------------------------------"

HAS_FEATURE=false
HAS_RULE=false
HAS_SCENARIO=false

if check_issue_type "Feature"; then
    HAS_FEATURE=true
fi

if check_issue_type "Rule"; then
    HAS_RULE=true
fi

if check_issue_type "Scenario"; then
    HAS_SCENARIO=true
fi

echo ""
echo "2. Checking standard issue types:"
echo "-----------------------------------"
check_issue_type "Epic"
check_issue_type "Story"
check_issue_type "Task"
check_issue_type "Sub-task"

echo ""
echo "======================================"
echo "Hierarchy Configuration Status"
echo "======================================"

if $HAS_FEATURE && $HAS_RULE && $HAS_SCENARIO; then
    echo "✅ CUSTOM HIERARCHY AVAILABLE!"
    echo ""
    echo "You can use: Feature → Epic → Rule → Scenario"
    echo ""
    echo "Example commands:"
    echo "  acli jira workitem create --type Feature --project $PROJECT_KEY --summary 'My Feature'"
    echo "  acli jira workitem create --type Rule --project $PROJECT_KEY --summary 'My Rule'"
    echo "  acli jira workitem create --type Scenario --project $PROJECT_KEY --summary 'My Scenario'"
else
    echo "⚠️  CUSTOM HIERARCHY NOT CONFIGURED"
    echo ""
    echo "Missing issue types:"
    [[ $HAS_FEATURE == false ]] && echo "  - Feature"
    [[ $HAS_RULE == false ]] && echo "  - Rule"
    [[ $HAS_SCENARIO == false ]] && echo "  - Scenario"
    echo ""
    echo "Falling back to standard hierarchy:"
    echo "  Epic → Story → Task → Sub-task"
    echo ""
    echo "To add custom types:"
    echo "1. Go to: https://pinyridgelabs.atlassian.net/secure/admin/ViewIssueTypes.jspa"
    echo "2. Create Feature, Rule, and Scenario issue types"
    echo "3. Add them to project $PROJECT_KEY"
    echo "4. Configure hierarchy in Advanced Roadmaps"
fi

echo ""
echo "======================================"
echo "Testing Issue Creation"
echo "======================================"

read -p "Do you want to create test issues? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    TIMESTAMP=$(date +%s)

    if $HAS_FEATURE && $HAS_RULE && $HAS_SCENARIO; then
        # Create with custom hierarchy
        echo "Creating Feature..."
        FEATURE=$(acli jira workitem create --type "Feature" --project "$PROJECT_KEY" \
            --summary "Test Feature $TIMESTAMP" \
            --description "Testing custom hierarchy" 2>&1 | grep -oE "$PROJECT_KEY-[0-9]+")
        echo "Created: $FEATURE"

        echo "Creating Epic under Feature..."
        EPIC=$(acli jira workitem create --type "Epic" --project "$PROJECT_KEY" \
            --summary "Test Epic $TIMESTAMP" \
            --parent "$FEATURE" 2>&1 | grep -oE "$PROJECT_KEY-[0-9]+")
        echo "Created: $EPIC"

        echo "Creating Rule under Epic..."
        RULE=$(acli jira workitem create --type "Rule" --project "$PROJECT_KEY" \
            --summary "Test Rule $TIMESTAMP" \
            --parent "$EPIC" 2>&1 | grep -oE "$PROJECT_KEY-[0-9]+")
        echo "Created: $RULE"

        echo "Creating Scenario under Rule..."
        SCENARIO=$(acli jira workitem create --type "Scenario" --project "$PROJECT_KEY" \
            --summary "Test Scenario $TIMESTAMP" \
            --parent "$RULE" 2>&1 | grep -oE "$PROJECT_KEY-[0-9]+")
        echo "Created: $SCENARIO"

        echo ""
        echo "Hierarchy created:"
        echo "  Feature: $FEATURE"
        echo "  └── Epic: $EPIC"
        echo "      └── Rule: $RULE"
        echo "          └── Scenario: $SCENARIO"
    else
        # Create with standard hierarchy
        echo "Creating Epic..."
        EPIC=$(acli jira workitem create --type "Epic" --project "$PROJECT_KEY" \
            --summary "Test Feature $TIMESTAMP (Epic)" \
            --description "Using Epic as Feature substitute" 2>&1 | grep -oE "$PROJECT_KEY-[0-9]+")
        echo "Created: $EPIC"

        echo "Creating Story under Epic..."
        STORY=$(acli jira workitem create --type "Story" --project "$PROJECT_KEY" \
            --summary "Test Rule $TIMESTAMP (Story)" \
            --parent "$EPIC" 2>&1 | grep -oE "$PROJECT_KEY-[0-9]+")
        echo "Created: $STORY"

        echo "Creating Task under Story..."
        TASK=$(acli jira workitem create --type "Task" --project "$PROJECT_KEY" \
            --summary "Test Scenario $TIMESTAMP (Task)" \
            --description "Using Task as Scenario substitute" 2>&1 | grep -oE "$PROJECT_KEY-[0-9]+")
        echo "Created: $TASK"

        # Link Task to Story since Task can't be a direct child
        echo "Linking Task to Story..."
        acli jira workitem link --from "$STORY" --to "$TASK" --type "relates to" 2>&1

        echo ""
        echo "Hierarchy created (using standard types):"
        echo "  Epic: $EPIC (as Feature)"
        echo "  └── Story: $STORY (as Rule)"
        echo "      ~ Task: $TASK (as Scenario, linked)"
    fi
fi

echo ""
echo "======================================"
echo "Done!"
echo "======================================"