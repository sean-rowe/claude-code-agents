#!/bin/bash

echo "======================================"
echo "JIRA TEMPLATE DIAGNOSTICS"
echo "======================================"
echo ""

# Check available templates
echo "1. Checking available JIRA project templates..."
echo "-----------------------------------"
acli jira template list 2>/dev/null
if [ $? -ne 0 ]; then
    echo "ERROR: Cannot list templates. Trying alternative command..."
    acli jira project template list 2>/dev/null
fi

echo ""
echo "2. Checking if Scrum template exists..."
echo "-----------------------------------"
acli jira template list 2>/dev/null | grep -i scrum
if [ $? -ne 0 ]; then
    echo "No Scrum template found in list"
fi

echo ""
echo "3. Attempting to create test project with common templates..."
echo "-----------------------------------"

# Try different template variations
TEMPLATES=(
    "com.pyxis.greenhopper.jira:gh-simplified-scrum-classic"
    "com.pyxis.greenhopper.jira:gh-scrum-template"
    "com.atlassian.jira-core-project-templates:jira-core-simplified-scrum"
    "com.atlassian.jira-software-application:jira-software-scrum"
)

for template in "${TEMPLATES[@]}"; do
    echo ""
    echo "Testing template: $template"
    acli jira project create \
        --project "TEST$(date +%s)" \
        --name "Test Scrum Project" \
        --lead "admin" \
        --template "$template" \
        --simulate 2>&1 | head -5
done

echo ""
echo "4. Checking what happens without template parameter..."
echo "-----------------------------------"
echo "Creating project without template to see default issue types:"
TEST_KEY="TEST$(date +%s)"
acli jira project create \
    --project "$TEST_KEY" \
    --name "Test Default Project" \
    --lead "admin" 2>&1 | head -10

# If it succeeded, check issue types
if [ $? -eq 0 ]; then
    echo ""
    echo "Checking issue types in default project:"
    acli jira issuetype list --project "$TEST_KEY" --outputFormat 999

    # Clean up
    acli jira project delete --project "$TEST_KEY" --force 2>/dev/null
fi

echo ""
echo "5. Alternative: Create project then add issue types..."
echo "-----------------------------------"
echo "This approach creates a basic project then adds Epic/Story types:"
cat << 'EOF'
# Step 1: Create basic project
acli jira project create \
    --project "PROJ" \
    --name "Project Name" \
    --lead "admin"

# Step 2: Add Epic issue type to project
acli jira issuetype add \
    --project "PROJ" \
    --type "Epic" \
    --description "Epic for tracking large features"

# Step 3: Add Story issue type to project
acli jira issuetype add \
    --project "PROJ" \
    --type "Story" \
    --description "User story"
EOF

echo ""
echo "6. Checking JIRA version and capabilities..."
echo "-----------------------------------"
acli jira info 2>&1 | grep -E "(Version|Build|Server)" | head -5

echo ""
echo "======================================"
echo "DIAGNOSIS COMPLETE"
echo "======================================"
echo ""
echo "Based on results above, we can determine:"
echo "1. Which templates are actually available"
echo "2. What the correct template key is"
echo "3. Whether we need to use an alternative approach"