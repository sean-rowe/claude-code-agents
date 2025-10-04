#!/bin/bash
# JIRA Diagnostic Script
# Replaces: diagnose-jira-templates.sh, check-jira-hierarchy.sh, test-jira-api.sh

set -euo pipefail

# Load JIRA client library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../../lib"
source "$LIB_DIR/jira-client.sh"

PROJECT_KEY="${1:-PROJ}"

echo "======================================"
echo "JIRA Diagnostic Report"
echo "======================================"
echo "Project: $PROJECT_KEY"
echo "Date: $(date)"
echo ""

# Check 1: Connection
echo "=== Connection Test ==="
diagnose_connection
echo ""

# Check 2: Project exists
echo "=== Project Status ==="
if project_exists "$PROJECT_KEY"; then
  info "✓ Project $PROJECT_KEY exists"

  # Get project details
  if has_acli; then
    echo ""
    echo "Project details:"
    acli jira project view --key "$PROJECT_KEY" || true
  fi
else
  warning "✗ Project $PROJECT_KEY does not exist"
fi
echo ""

# Check 3: Issue types
echo "=== Issue Types ==="
ISSUE_TYPES=$(get_issue_types "$PROJECT_KEY")
if [ -n "$ISSUE_TYPES" ]; then
  echo "$ISSUE_TYPES"

  # Check for specific types
  for type in "Epic" "Story" "Task" "Sub-task" "Bug"; do
    if echo "$ISSUE_TYPES" | grep -qi "$type"; then
      info "✓ $type is available"
    else
      warning "✗ $type is NOT available"
    fi
  done
else
  warning "Could not retrieve issue types"
fi
echo ""

# Check 4: Test issue creation
echo "=== Test Issue Creation ==="
info "Attempting to create test epic..."
TEST_RESULT=$(create_epic "$PROJECT_KEY" "DIAGNOSTIC TEST - DELETE ME" "Automated diagnostic test" 2>&1)

if echo "$TEST_RESULT" | grep -qE '[A-Z]+-[0-9]+'; then
  TEST_KEY=$(echo "$TEST_RESULT" | grep -oE '[A-Z]+-[0-9]+' | head -1)
  info "✓ Successfully created test issue: $TEST_KEY"
  info "  (You can delete this issue from JIRA)"
else
  warning "✗ Failed to create test issue"
  echo "Response: $TEST_RESULT"
fi
echo ""

# Check 5: Recent issues
echo "=== Recent Issues ==="
if has_acli; then
  info "Last 5 issues in $PROJECT_KEY:"
  acli jira workitem list --project "$PROJECT_KEY" --limit 5 2>/dev/null || warning "Could not list issues"
else
  info "Install acli to see recent issues"
fi
echo ""

echo "======================================"
echo "Diagnostic Complete"
echo "======================================"
