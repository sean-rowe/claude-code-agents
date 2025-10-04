#!/bin/bash
# JIRA Setup Script - Unified setup for JIRA projects
# Replaces: jira-hierarchy-setup.sh, setup-jira-hierarchy.sh, setup-jira-admin.sh

set -euo pipefail

# Load JIRA client library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../../lib"
source "$LIB_DIR/jira-client.sh"

# Configuration
PROJECT_KEY="${1:-PROJ}"
PROJECT_NAME="${2:-$PROJECT_KEY Project}"
REQUIRED_TYPES=("Epic" "Story" "Task")

echo "======================================"
echo "JIRA Project Setup"
echo "======================================"
echo "Project: $PROJECT_KEY"
echo "Name: $PROJECT_NAME"
echo ""

# Step 1: Check connection
echo "[1/5] Checking JIRA connection..."
diagnose_connection
echo ""

# Step 2: Check if project exists
echo "[2/5] Checking project..."
if project_exists "$PROJECT_KEY"; then
  info "Project $PROJECT_KEY already exists"
else
  info "Creating project $PROJECT_KEY..."
  if has_api_credentials; then
    create_project "$PROJECT_KEY" "$PROJECT_NAME"
    info "✓ Project created via REST API"
  elif has_acli; then
    acli jira project create \
      --key "$PROJECT_KEY" \
      --name "$PROJECT_NAME" \
      --lead "$USER" \
      --type software
    info "✓ Project created via acli"
  else
    error "Cannot create project - no acli or API credentials available"
  fi
fi
echo ""

# Step 3: Verify issue types
echo "[3/5] Verifying issue types..."
verify_project_issue_types "$PROJECT_KEY" "${REQUIRED_TYPES[@]}" || true
echo ""

# Step 4: Create test hierarchy
echo "[4/5] Creating test hierarchy..."
HIERARCHY=$(create_custom_hierarchy "$PROJECT_KEY" "Test Initiative: Verify Setup")
IFS=',' read -r EPIC_KEY STORY_KEY <<< "$HIERARCHY"

if [ -n "$EPIC_KEY" ]; then
  info "✓ Created test epic: $EPIC_KEY"
fi

if [ -n "$STORY_KEY" ]; then
  info "✓ Created test story: $STORY_KEY"
fi
echo ""

# Step 5: Save configuration
echo "[5/5] Saving configuration..."
cat > .env <<EOF
PROJECT_KEY=$PROJECT_KEY
PROJECT_NAME=$PROJECT_NAME
JIRA_URL=$JIRA_URL
EOF
info "✓ Configuration saved to .env"
echo ""

echo "======================================"
echo "✓ JIRA Setup Complete"
echo "======================================"
echo ""
echo "Project: $PROJECT_KEY"
echo "Test Epic: $EPIC_KEY"
echo "Test Story: $STORY_KEY"
echo ""
echo "Next steps:"
echo "1. Run: ./pipeline.sh requirements 'Your initiative'"
echo "2. Run: ./pipeline.sh gherkin"
echo "3. Run: ./pipeline.sh stories"
echo ""
