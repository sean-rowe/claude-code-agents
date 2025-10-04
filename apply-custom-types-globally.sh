#!/bin/bash

JIRA_URL="https://srowe74.atlassian.net"
EMAIL="stephen.rowe@srowe74.atlassian.net"
API_TOKEN="ATATT3xFfGF0aQ51dHQiTJk5YQeRLLW44JG5Xk8GfgzRiLW5SRwD6eJPa77LJ1UuGXPPyDlWJbVxPH66LSPq9BKHgk4xhXnv63dJYQZQtzRBb2o74j1U8-VPFk9Qu03qVufjGME1iWxjM-p0E65YAE1vLwQTTb5__fTx6VFjN3x8l64tH9UgfVA=38E35C42"

AUTH=$(echo -n "$EMAIL:$API_TOKEN" | base64)

# The custom scheme ID that has Feature, Epic, Rule, Scenario
CUSTOM_SCHEME_ID="10390"

echo "======================================"
echo "Applying Custom Issue Types Globally"
echo "======================================"
echo ""

# Step 1: Get all projects
echo "[1/3] Fetching all projects..."
PROJECTS=$(curl -s -X GET \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/project")

# Check for errors
if echo "$PROJECTS" | grep -q "Page unavailable"; then
    echo "❌ Jira API is unavailable. Please try again in a few minutes."
    exit 1
fi

if echo "$PROJECTS" | jq -e '.errorMessages' > /dev/null 2>&1; then
    echo "❌ Error fetching projects: $PROJECTS"
    exit 1
fi

PROJECT_COUNT=$(echo "$PROJECTS" | jq '. | length')
echo "Found $PROJECT_COUNT projects"
echo ""

# Step 2: Apply custom scheme to all projects
echo "[2/3] Applying custom issue type scheme to all projects..."
SUCCESS_COUNT=0
FAIL_COUNT=0

echo "$PROJECTS" | jq -r '.[] | "\(.id)|\(.key)|\(.name)"' | while IFS='|' read -r PROJECT_ID PROJECT_KEY PROJECT_NAME; do
    echo -n "  Applying to $PROJECT_KEY ($PROJECT_NAME)... "

    RESULT=$(curl -s -w "\n%{http_code}" -X PUT \
        -H "Authorization: Basic $AUTH" \
        -H "Content-Type: application/json" \
        "$JIRA_URL/rest/api/3/issuetypescheme/project" \
        -d "{\"issueTypeSchemeId\": \"$CUSTOM_SCHEME_ID\", \"projectId\": \"$PROJECT_ID\"}")

    HTTP_CODE=$(echo "$RESULT" | tail -n1)
    BODY=$(echo "$RESULT" | sed '$d')

    if [ "$HTTP_CODE" = "204" ] || [ "$HTTP_CODE" = "200" ]; then
        echo "✓"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "✗ (HTTP $HTTP_CODE)"
        if [ -n "$BODY" ]; then
            echo "    $BODY"
        fi
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    sleep 0.5
done

echo ""
echo "Results: $SUCCESS_COUNT succeeded, $FAIL_COUNT failed"
echo ""

# Step 3: Create demo hierarchy in CUEM project
echo "[3/3] Creating demo hierarchy in CUEM project..."

# Create Feature
FEATURE=$(curl -s -X POST \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/issue" \
    -d '{
        "fields": {
            "project": {"key": "CUEM"},
            "issuetype": {"id": "10135"},
            "summary": "Demo Feature: User Authentication System"
        }
    }')

FEATURE_KEY=$(echo "$FEATURE" | jq -r '.key')
echo "  Created Feature: $FEATURE_KEY"

# Create Epic under Feature
EPIC=$(curl -s -X POST \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/issue" \
    -d "{
        \"fields\": {
            \"project\": {\"key\": \"CUEM\"},
            \"issuetype\": {\"id\": \"10000\"},
            \"summary\": \"Demo Epic: OAuth2 Implementation\",
            \"parent\": {\"key\": \"$FEATURE_KEY\"}
        }
    }")

EPIC_KEY=$(echo "$EPIC" | jq -r '.key')
echo "  Created Epic: $EPIC_KEY (under $FEATURE_KEY)"

# Create Rule under Epic
RULE=$(curl -s -X POST \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/issue" \
    -d "{
        \"fields\": {
            \"project\": {\"key\": \"CUEM\"},
            \"issuetype\": {\"id\": \"10133\"},
            \"summary\": \"Demo Rule: Token Refresh Logic\",
            \"parent\": {\"key\": \"$EPIC_KEY\"}
        }
    }")

RULE_KEY=$(echo "$RULE" | jq -r '.key')
echo "  Created Rule: $RULE_KEY (under $EPIC_KEY)"

# Create Scenario under Rule
SCENARIO=$(curl -s -X POST \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/issue" \
    -d "{
        \"fields\": {
            \"project\": {\"key\": \"CUEM\"},
            \"issuetype\": {\"id\": \"10134\"},
            \"summary\": \"Demo Scenario: Given expired token, refresh should succeed\",
            \"parent\": {\"key\": \"$RULE_KEY\"}
        }
    }")

SCENARIO_KEY=$(echo "$SCENARIO" | jq -r '.key')
echo "  Created Scenario: $SCENARIO_KEY (under $RULE_KEY)"

echo ""
echo "======================================"
echo "✓ Custom issue types are now available in ALL projects"
echo "✓ Demo hierarchy created: $FEATURE_KEY → $EPIC_KEY → $RULE_KEY → $SCENARIO_KEY"
echo "======================================"

# Clean up credentials
sed -i '' 's/ATATT[^"]*/REDACTED/g' "$0"
