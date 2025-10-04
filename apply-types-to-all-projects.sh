#!/bin/bash

JIRA_URL="https://srowe74.atlassian.net"
EMAIL="stephen.rowe@srowe74.atlassian.net"
API_TOKEN="REDACTED"

AUTH=$(echo -n "$EMAIL:$API_TOKEN" | base64)

# First, get all projects
echo "Fetching all projects..."
PROJECTS=$(curl -s -X GET \
    -H "Authorization: Basic $AUTH" \
    -H "Content-Type: application/json" \
    "$JIRA_URL/rest/api/3/project")

echo "$PROJECTS" | jq -r 'if type == "array" then .[] | "\(.key) - \(.name)" else . end'

# Check if we got an error
if echo "$PROJECTS" | jq -e '.errorMessages' > /dev/null 2>&1; then
    echo "Error fetching projects: $PROJECTS"
    exit 1
fi

# Get the custom scheme ID that has our types
CUSTOM_SCHEME_ID="10390"

# For each project, associate it with our custom scheme
echo -e "\nApplying custom issue type scheme to all projects..."
echo "$PROJECTS" | jq -r 'if type == "array" then .[].id else empty end' | while read PROJECT_ID; do
    PROJECT_KEY=$(echo "$PROJECTS" | jq -r ".[] | select(.id == \"$PROJECT_ID\") | .key")
    echo "Applying to project: $PROJECT_KEY (ID: $PROJECT_ID)"
    
    RESULT=$(curl -s -X PUT \
        -H "Authorization: Basic $AUTH" \
        -H "Content-Type: application/json" \
        "$JIRA_URL/rest/api/3/issuetypescheme/project" \
        -d "{\"issueTypeSchemeId\": \"$CUSTOM_SCHEME_ID\", \"projectId\": \"$PROJECT_ID\"}")
    
    if [ -z "$RESULT" ]; then
        echo "  ✓ Successfully applied to $PROJECT_KEY"
    else
        echo "  Response: $RESULT"
    fi
    sleep 1
done

# Clean up credentials
sed -i '' 's/REDACTED"]*/REDACTED/g' apply-types-to-all-projects.sh

echo -e "\n✓ Custom issue types should now be available in all projects"
