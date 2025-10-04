#!/bin/bash
# JIRA Client Library
# Centralized JIRA operations for all scripts

set -euo pipefail

# Configuration
JIRA_URL="${JIRA_URL:-https://srowe74.atlassian.net}"
JIRA_EMAIL="${JIRA_EMAIL:-}"
JIRA_API_TOKEN="${JIRA_API_TOKEN:-}"

# Error handling
error() {
  echo "ERROR: $1" >&2
  exit 1
}

warning() {
  echo "WARNING: $1" >&2
}

info() {
  echo "INFO: $1"
}

# Check if acli is available
has_acli() {
  command -v acli &>/dev/null
}

# Check if REST API credentials are available
has_api_credentials() {
  [ -n "$JIRA_EMAIL" ] && [ -n "$JIRA_API_TOKEN" ]
}

# Get authentication header for REST API
get_auth_header() {
  if ! has_api_credentials; then
    error "JIRA_EMAIL and JIRA_API_TOKEN must be set for REST API calls"
  fi
  echo -n "$JIRA_EMAIL:$JIRA_API_TOKEN" | base64
}

# Make REST API call
api_call() {
  local method=$1
  local endpoint=$2
  local data=${3:-}

  local auth=$(get_auth_header)
  local url="$JIRA_URL/rest/api/3/$endpoint"

  if [ -n "$data" ]; then
    curl -s -X "$method" \
      -H "Authorization: Basic $auth" \
      -H "Content-Type: application/json" \
      "$url" \
      -d "$data"
  else
    curl -s -X "$method" \
      -H "Authorization: Basic $auth" \
      -H "Content-Type: application/json" \
      "$url"
  fi
}

# Check if project exists
project_exists() {
  local project_key=$1

  if has_acli; then
    acli jira project view --key "$project_key" &>/dev/null
    return $?
  else
    local result=$(api_call GET "project/$project_key" 2>/dev/null)
    echo "$result" | grep -q '"key"'
    return $?
  fi
}

# Get all projects
get_projects() {
  if has_acli; then
    acli jira project list
  else
    api_call GET "project"
  fi
}

# Create project (REST API only - acli has limited support)
create_project() {
  local project_key=$1
  local project_name=$2
  local template=${3:-com.pyxis.greenhopper.jira:gh-simplified-scrum-classic}

  local data=$(cat <<EOF
{
  "key": "$project_key",
  "name": "$project_name",
  "projectTypeKey": "software",
  "projectTemplateKey": "$template",
  "leadAccountId": "admin"
}
EOF
)

  api_call POST "project" "$data"
}

# Get issue types for a project
get_issue_types() {
  local project_key=$1

  if has_acli; then
    acli jira issueType list --project "$project_key" 2>/dev/null || true
  else
    api_call GET "project/$project_key/statuses"
  fi
}

# Create issue type (requires admin - REST API only)
create_issue_type() {
  local name=$1
  local description=$2
  local hierarchy_level=${3:-0}

  local data=$(cat <<EOF
{
  "name": "$name",
  "description": "$description",
  "type": "standard",
  "hierarchyLevel": $hierarchy_level
}
EOF
)

  api_call POST "issuetype" "$data"
}

# Create epic
create_epic() {
  local project_key=$1
  local summary=$2
  local description=${3:-}

  if has_acli; then
    acli jira workitem create \
      --type "Epic" \
      --project "$project_key" \
      --summary "$summary" \
      --description "$description"
  else
    local data=$(cat <<EOF
{
  "fields": {
    "project": {"key": "$project_key"},
    "issuetype": {"name": "Epic"},
    "summary": "$summary",
    "description": "$description"
  }
}
EOF
)
    api_call POST "issue" "$data"
  fi
}

# Create story
create_story() {
  local project_key=$1
  local summary=$2
  local description=${3:-}
  local parent_key=${4:-}

  if has_acli; then
    if [ -n "$parent_key" ]; then
      acli jira workitem create \
        --type "Story" \
        --project "$project_key" \
        --summary "$summary" \
        --description "$description" \
        --parent "$parent_key"
    else
      acli jira workitem create \
        --type "Story" \
        --project "$project_key" \
        --summary "$summary" \
        --description "$description"
    fi
  else
    local parent_field=""
    if [ -n "$parent_key" ]; then
      parent_field=", \"parent\": {\"key\": \"$parent_key\"}"
    fi

    local data=$(cat <<EOF
{
  "fields": {
    "project": {"key": "$project_key"},
    "issuetype": {"name": "Story"},
    "summary": "$summary",
    "description": "$description"$parent_field
  }
}
EOF
)
    api_call POST "issue" "$data"
  fi
}

# Get issue details
get_issue() {
  local issue_key=$1

  if has_acli; then
    acli jira issue view --key "$issue_key"
  else
    api_call GET "issue/$issue_key"
  fi
}

# Update issue status
update_issue_status() {
  local issue_key=$1
  local status=$2

  if has_acli; then
    acli jira issue transition --key "$issue_key" --status "$status"
  else
    # Get available transitions
    local transitions=$(api_call GET "issue/$issue_key/transitions")
    local transition_id=$(echo "$transitions" | jq -r ".transitions[] | select(.name == \"$status\") | .id")

    if [ -n "$transition_id" ]; then
      local data=$(cat <<EOF
{
  "transition": {"id": "$transition_id"}
}
EOF
)
      api_call POST "issue/$issue_key/transitions" "$data"
    else
      warning "Status '$status' not available for $issue_key"
    fi
  fi
}

# Verify project has required issue types
verify_project_issue_types() {
  local project_key=$1
  shift
  local required_types=("$@")

  local issue_types=$(get_issue_types "$project_key")
  local missing_types=()

  for type in "${required_types[@]}"; do
    if ! echo "$issue_types" | grep -qi "$type"; then
      missing_types+=("$type")
    fi
  done

  if [ ${#missing_types[@]} -gt 0 ]; then
    error "Project $project_key is missing issue types: ${missing_types[*]}"
  fi

  info "Project $project_key has all required issue types: ${required_types[*]}"
}

# Create hierarchy: Feature -> Epic -> Rule -> Scenario
create_custom_hierarchy() {
  local project_key=$1
  local feature_summary=$2

  info "Creating custom hierarchy in $project_key"

  # Create Feature (if custom type exists)
  local feature_result=$(create_epic "$project_key" "$feature_summary" "Top-level feature")
  local feature_key=$(echo "$feature_result" | grep -oE '[A-Z]+-[0-9]+' | head -1)

  if [ -z "$feature_key" ]; then
    error "Failed to create feature"
  fi

  info "Created Feature: $feature_key"

  # Create Epic under Feature
  local epic_result=$(create_story "$project_key" "Epic: Implementation" "Epic description" "$feature_key")
  local epic_key=$(echo "$epic_result" | grep -oE '[A-Z]+-[0-9]+' | head -1)

  if [ -z "$epic_key" ]; then
    warning "Failed to create epic under feature"
  else
    info "Created Epic: $epic_key"
  fi

  echo "$feature_key,$epic_key"
}

# Export to CSV
export_hierarchy_to_csv() {
  local epic_key=$1
  local story_keys=$2
  local output_file=${3:-.pipeline/exports/jira_import.csv}

  mkdir -p "$(dirname "$output_file")"

  cat > "$output_file" <<EOF
Issue Type,Key,Summary,Parent,Status
Epic,$epic_key,Initiative Epic,,To Do
EOF

  IFS=',' read -ra STORIES <<< "$story_keys"
  for story in "${STORIES[@]}"; do
    echo "Story,$story,Story under epic,$epic_key,To Do" >> "$output_file"
  done

  info "Exported hierarchy to $output_file"
}

# Diagnostic: Check JIRA connection
diagnose_connection() {
  info "Diagnosing JIRA connection..."

  if has_acli; then
    info "✓ acli is installed"
    if acli jira auth status &>/dev/null; then
      info "✓ acli is authenticated"
    else
      warning "acli is not authenticated - run 'acli jira auth login'"
    fi
  else
    warning "acli is not installed"
  fi

  if has_api_credentials; then
    info "✓ API credentials are configured"
    local test_result=$(api_call GET "myself" 2>&1)
    if echo "$test_result" | grep -q '"accountId"'; then
      info "✓ API connection successful"
    else
      warning "API connection failed: $test_result"
    fi
  else
    warning "API credentials not configured (set JIRA_EMAIL and JIRA_API_TOKEN)"
  fi
}
