#!/bin/bash

# Setup Custom Issue Types for Therapy Docs Project
# Creates: Feature -> Epic -> Rule -> Scenario hierarchy

echo "======================================"
echo "Setting up Jira Custom Issue Types"
echo "======================================"
echo ""

PROJECT_KEY="TD"

# First, let's check if acli is configured and working
echo "1. Testing Jira connection..."
acli jira project view --key $PROJECT_KEY 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Cannot connect to Jira. Please check your acli configuration."
    echo "You may need to authenticate with: acli jira auth"
    exit 1
fi

echo "✓ Connected to Jira"
echo ""

# Check what issue types already exist
echo "2. Checking existing issue types in project $PROJECT_KEY..."
acli jira project view --key $PROJECT_KEY 2>&1 | grep -E "(Issue Types|type)" || true

echo ""
echo "3. Creating custom issue types (if they don't exist)..."
echo ""

# Note: Creating issue types requires Jira admin permissions
# The actual creation might need to be done via the Jira UI or REST API

# Create configuration JSON files for each issue type
cat > feature-type.json <<'EOF'
{
  "name": "Feature",
  "description": "High-level feature containing multiple epics",
  "type": "standard",
  "hierarchyLevel": 3
}
EOF

cat > rule-type.json <<'EOF'
{
  "name": "Rule",
  "description": "Business rule or requirement specification",
  "type": "standard",
  "hierarchyLevel": 1
}
EOF

cat > scenario-type.json <<'EOF'
{
  "name": "Scenario",
  "description": "Test scenario or use case",
  "type": "standard",
  "hierarchyLevel": 0
}
EOF

echo "Created configuration files:"
echo "  - feature-type.json"
echo "  - rule-type.json"
echo "  - scenario-type.json"
echo ""

# Try to create issue types using acli
echo "4. Attempting to add issue types to project..."

# Check if we can list available commands for project configuration
echo "Available project commands:"
acli jira project --help 2>&1 | grep -E "create|update|add" || true

echo ""
echo "5. Creating test hierarchy with existing types..."
echo ""

# For now, let's create a test with existing types to verify connectivity
echo "Creating test Epic..."
TEST_EPIC=$(acli jira workitem create \
  --type "Epic" \
  --project "$PROJECT_KEY" \
  --summary "Test Feature: Custom Hierarchy Setup" \
  --description "Testing hierarchy configuration" 2>&1)

if echo "$TEST_EPIC" | grep -q "Created"; then
    EPIC_KEY=$(echo "$TEST_EPIC" | grep -oE "$PROJECT_KEY-[0-9]+")
    echo "✓ Created test Epic: $EPIC_KEY"

    # Create a Story under the Epic
    echo "Creating test Story under Epic..."
    TEST_STORY=$(acli jira workitem create \
        --type "Story" \
        --project "$PROJECT_KEY" \
        --summary "Test Rule: Validation Requirements" \
        --description "Testing story as rule placeholder" \
        --parent "$EPIC_KEY" 2>&1)

    if echo "$TEST_STORY" | grep -q "Created"; then
        STORY_KEY=$(echo "$TEST_STORY" | grep -oE "$PROJECT_KEY-[0-9]+")
        echo "✓ Created test Story: $STORY_KEY"
    fi
else
    echo "Could not create test issues. Output:"
    echo "$TEST_EPIC"
fi

echo ""
echo "======================================"
echo "Next Steps:"
echo "======================================"
echo ""
echo "Since creating custom issue types requires Jira admin permissions,"
echo "you'll need to:"
echo ""
echo "1. Go to Jira Settings (gear icon) → Issues → Issue types"
echo "2. Click 'Add issue type' and create:"
echo "   - Feature (standard type, icon: feature)"
echo "   - Rule (standard type, icon: requirement)"
echo "   - Scenario (standard type, icon: test)"
echo ""
echo "3. Go to your project settings → Issue types"
echo "4. Add the new types to your project's scheme"
echo ""
echo "5. Configure Advanced Roadmaps hierarchy:"
echo "   - Settings → Advanced Roadmaps → Hierarchy configuration"
echo "   - Set levels: Feature (3) → Epic (2) → Rule (1) → Scenario (0)"
echo ""
echo "Alternative: Use the Jira REST API directly with curl"
echo "See: setup-via-rest-api.sh (being created now)"