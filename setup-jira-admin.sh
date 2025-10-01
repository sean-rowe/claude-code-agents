#!/bin/bash

# Setup script to create custom issue types with admin credentials

echo "======================================"
echo "Jira Admin Setup for Custom Issue Types"
echo "======================================"
echo ""
echo "To create custom issue types, we need admin access."
echo ""
echo "Steps to provide admin access:"
echo "1. Go to: https://id.atlassian.com/manage-profile/security/api-tokens"
echo "2. Click 'Create API token'"
echo "3. Name it: 'Claude Code Admin'"
echo "4. Copy the token"
echo ""
read -p "Please paste your API token here: " -s API_TOKEN
echo ""
read -p "Please enter your admin email: " EMAIL
echo ""

if [ -z "$API_TOKEN" ] || [ -z "$EMAIL" ]; then
    echo "Error: Email and API token are required"
    exit 1
fi

# Save credentials temporarily (will be deleted after use)
cat > .jira-admin-config <<EOF
JIRA_URL="https://pinyridgelabs.atlassian.net"
ADMIN_EMAIL="$EMAIL"
ADMIN_TOKEN="$API_TOKEN"
EOF

echo "✓ Credentials saved temporarily"
echo ""

# Test authentication
echo "Testing admin access..."
AUTH=$(echo -n "$EMAIL:$API_TOKEN" | base64)

TEST_RESULT=$(curl -s -X GET \
    -H "Authorization: Basic $AUTH" \
    -H "Accept: application/json" \
    "$JIRA_URL/rest/api/3/myself")

if echo "$TEST_RESULT" | grep -q "emailAddress"; then
    echo "✓ Authentication successful!"
    USER_NAME=$(echo "$TEST_RESULT" | jq -r '.displayName' 2>/dev/null)
    echo "Logged in as: $USER_NAME"
else
    echo "✗ Authentication failed. Please check your credentials."
    rm -f .jira-admin-config
    exit 1
fi

echo ""
echo "Now running issue type creation..."
echo ""

# Create Feature issue type
echo "Creating Feature issue type..."
curl -X POST \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/issuetype" \
    -d '{
        "name": "Feature",
        "description": "High-level feature containing multiple epics",
        "type": "standard"
    }'

echo ""
echo "Creating Rule issue type..."
curl -X POST \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/issuetype" \
    -d '{
        "name": "Rule",
        "description": "Business rule or requirement specification",
        "type": "standard"
    }'

echo ""
echo "Creating Scenario issue type..."
curl -X POST \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/issuetype" \
    -d '{
        "name": "Scenario",
        "description": "Test scenario or use case",
        "type": "standard"
    }'

echo ""
echo "Cleaning up credentials..."
rm -f .jira-admin-config

echo ""
echo "✓ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run: ./check-jira-hierarchy.sh to verify"
echo "2. Configure hierarchy in Advanced Roadmaps"
echo "3. The pipeline will automatically use the new types"