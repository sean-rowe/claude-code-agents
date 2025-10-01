#!/bin/bash

# Setup Jira Custom Issue Types via REST API
# Requires: Jira admin permissions

echo "======================================"
echo "Jira Custom Issue Types - REST API Setup"
echo "======================================"
echo ""

# Configuration - You'll need to set these
JIRA_URL="https://pinyridgelabs.atlassian.net"
EMAIL="your-email@example.com"
API_TOKEN="your-api-token"  # Get from https://id.atlassian.com/manage-profile/security/api-tokens
PROJECT_KEY="TD"

# Check if credentials are set
if [ "$EMAIL" = "your-email@example.com" ]; then
    echo "ERROR: Please edit this script and set your email and API token"
    echo "Get API token from: https://id.atlassian.com/manage-profile/security/api-tokens"
    exit 1
fi

# Base64 encode credentials for auth
AUTH=$(echo -n "$EMAIL:$API_TOKEN" | base64)

echo "1. Getting current issue types..."
curl -s -X GET \
  -H "Authorization: Basic $AUTH" \
  -H "Accept: application/json" \
  "$JIRA_URL/rest/api/3/issuetype" | jq '.[] | {id, name, hierarchyLevel}' 2>/dev/null || echo "Install jq for formatted output"

echo ""
echo "2. Getting project configuration..."
curl -s -X GET \
  -H "Authorization: Basic $AUTH" \
  -H "Accept: application/json" \
  "$JIRA_URL/rest/api/3/project/$PROJECT_KEY" | jq '{key, name, issueTypes: .issueTypes[].name}' 2>/dev/null || echo "Project info retrieved"

echo ""
echo "3. Creating Feature issue type..."
FEATURE_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  "$JIRA_URL/rest/api/3/issuetype" \
  -d '{
    "name": "Feature",
    "description": "High-level feature containing multiple epics",
    "type": "standard",
    "hierarchyLevel": 2
  }')

echo "$FEATURE_RESPONSE" | jq '.' 2>/dev/null || echo "$FEATURE_RESPONSE"

echo ""
echo "4. Creating Rule issue type..."
RULE_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  "$JIRA_URL/rest/api/3/issuetype" \
  -d '{
    "name": "Rule",
    "description": "Business rule or requirement specification",
    "type": "standard",
    "hierarchyLevel": 0
  }')

echo "$RULE_RESPONSE" | jq '.' 2>/dev/null || echo "$RULE_RESPONSE"

echo ""
echo "5. Creating Scenario issue type..."
SCENARIO_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  "$JIRA_URL/rest/api/3/issuetype" \
  -d '{
    "name": "Scenario",
    "description": "Test scenario or use case",
    "type": "standard",
    "hierarchyLevel": 0
  }')

echo "$SCENARIO_RESPONSE" | jq '.' 2>/dev/null || echo "$SCENARIO_RESPONSE"

echo ""
echo "6. Configuring Advanced Roadmaps hierarchy..."
echo "Note: This requires Premium and admin access"

# Try to configure hierarchy in Advanced Roadmaps
curl -s -X POST \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  "$JIRA_URL/rest/api/3/project/$PROJECT_KEY/hierarchy" \
  -d '{
    "levels": [
      {"name": "Feature", "level": 3, "issueTypes": ["Feature"]},
      {"name": "Epic", "level": 2, "issueTypes": ["Epic"]},
      {"name": "Rule", "level": 1, "issueTypes": ["Rule"]},
      {"name": "Scenario", "level": 0, "issueTypes": ["Scenario"]}
    ]
  }' 2>&1 || echo "Hierarchy configuration attempted"

echo ""
echo "======================================"
echo "Setup Status"
echo "======================================"
echo ""
echo "If you see errors above, you may need to:"
echo "1. Ensure you have Jira admin permissions"
echo "2. Create issue types manually in Jira UI"
echo "3. Configure hierarchy in Advanced Roadmaps settings"
echo ""
echo "Manual steps:"
echo "1. Go to: $JIRA_URL/secure/admin/ViewIssueTypes.jspa"
echo "2. Add issue types: Feature, Rule, Scenario"
echo "3. Go to: Project settings → Issue types → Edit scheme"
echo "4. Add the new types to your project"
echo "5. Configure hierarchy in Advanced Roadmaps"