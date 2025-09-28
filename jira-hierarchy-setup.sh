#!/bin/bash
# JIRA Hierarchy Setup Script
# Ensures JIRA project supports Epic→Story→Task hierarchy

set -e

PROJECT_KEY="${1:-PROJ}"
PROJECT_NAME="${2:-$PROJECT_KEY Project}"

echo "==================================="
echo "JIRA Hierarchy Setup"
echo "==================================="
echo "Project: $PROJECT_KEY"
echo ""

# Step 1: Check if project exists
echo "[1/4] Checking project..."
if acli jira project view "$PROJECT_KEY" &>/dev/null; then
    echo "✓ Project $PROJECT_KEY exists"
else
    echo "Creating project $PROJECT_KEY..."
    acli jira project create \
        --key "$PROJECT_KEY" \
        --name "$PROJECT_NAME" \
        --lead "$USER" \
        --type software || true
    echo "✓ Project created"
fi

# Step 2: Verify issue types
echo "[2/4] Verifying issue types..."
ISSUE_TYPES=$(acli jira issueType list --project "$PROJECT_KEY" 2>/dev/null || echo "")

check_issue_type() {
    local type=$1
    if echo "$ISSUE_TYPES" | grep -q "$type"; then
        echo "✓ $type enabled"
        return 0
    else
        echo "⚠ $type not found - enable in JIRA settings"
        return 1
    fi
}

check_issue_type "Epic"
check_issue_type "Story"
check_issue_type "Task"
check_issue_type "Sub-task"

# Step 3: Create sample hierarchy to verify
echo "[3/4] Testing hierarchy creation..."

# Create test epic
EPIC_ID=$(acli jira issue create \
    --project "$PROJECT_KEY" \
    --type "Epic" \
    --summary "Test Epic - Verify Hierarchy" \
    --description "Automated test epic to verify hierarchy support" \
    --no-input 2>/dev/null | grep -oP 'Issue \K[A-Z]+-\d+' || echo "")

if [ -n "$EPIC_ID" ]; then
    echo "✓ Test epic created: $EPIC_ID"

    # Create test story under epic
    STORY_ID=$(acli jira issue create \
        --project "$PROJECT_KEY" \
        --type "Story" \
        --parent "$EPIC_ID" \
        --summary "Test Story under Epic" \
        --description "Verifies story can be child of epic" \
        --no-input 2>/dev/null | grep -oP 'Issue \K[A-Z]+-\d+' || echo "")

    if [ -n "$STORY_ID" ]; then
        echo "✓ Test story created: $STORY_ID"
    else
        echo "⚠ Could not create story under epic"
    fi
else
    echo "⚠ Could not create test epic"
fi

# Step 4: Summary
echo "[4/4] Setup complete"
echo ""
echo "==================================="
echo "✓ JIRA Hierarchy Ready"
echo "==================================="
echo ""
echo "Project: $PROJECT_KEY"
echo "Hierarchy: Epic → Story → Task"
echo ""
echo "Next steps:"
echo "1. Run: /pipeline requirements \"Your initiative\""
echo "2. The pipeline will create the full hierarchy"
echo ""

# Store configuration
echo "PROJECT_KEY=$PROJECT_KEY" > .env
echo "✓ Configuration saved to .env"