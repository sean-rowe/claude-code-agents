#!/bin/bash
# Pipeline State Manager
# Manages state for pipeline execution in .pipeline directory

set -euo pipefail

PIPELINE_DIR=".pipeline"
STATE_FILE="$PIPELINE_DIR/state.json"

# Ensure pipeline directory exists
ensure_pipeline_dir() {
    if [ ! -d "$PIPELINE_DIR" ]; then
        mkdir -p "$PIPELINE_DIR"
        echo "✓ Created $PIPELINE_DIR directory for pipeline state"
    fi

    # Always ensure .gitignore is updated (even if directory already exists)
    if [ -f .gitignore ]; then
        if ! grep -q "^\.pipeline" .gitignore; then
            echo ".pipeline/" >> .gitignore
            echo "✓ Added .pipeline to .gitignore"
        fi
    fi
}

# Initialize state if not exists
init_state() {
    ensure_pipeline_dir

    if [ ! -f "$STATE_FILE" ]; then
        cat > "$STATE_FILE" <<EOF
{
    "stage": "ready",
    "projectKey": "$(get_project_key)",
    "epicId": null,
    "featureStories": [],
    "ruleStories": [],
    "tasks": [],
    "currentStory": null,
    "branch": null,
    "pr": null,
    "step": 0,
    "totalSteps": 0,
    "lastAction": "Initialized",
    "nextAction": "Run '/pipeline requirements' to start",
    "startTime": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
        echo "✓ Pipeline state initialized in $STATE_FILE"
    fi
}

# Get project key from .env or generate
get_project_key() {
    if [ -f .env ]; then
        source .env
        echo "${PROJECT_KEY:-PROJ}"
    else
        echo "PROJ"
    fi
}

# Update state field
update_state() {
    local field=$1
    local value=$2

    ensure_pipeline_dir
    if [ ! -f "$STATE_FILE" ]; then
        init_state
    fi

    # Use jq to update JSON field
    if command -v jq &>/dev/null; then
        jq ".$field = \"$value\"" "$STATE_FILE" > "$PIPELINE_DIR/tmp.json" && mv "$PIPELINE_DIR/tmp.json" "$STATE_FILE"
    else
        # Fallback to sed if jq not available
        sed -i.bak "s/\"$field\": \"[^\"]*\"/\"$field\": \"$value\"/" "$STATE_FILE"
        rm -f "$STATE_FILE.bak"
    fi
}

# Get state field
get_state() {
    local field=$1

    ensure_pipeline_dir
    if [ ! -f "$STATE_FILE" ]; then
        init_state
    fi

    if command -v jq &>/dev/null; then
        jq -r ".$field" "$STATE_FILE"
    else
        grep "\"$field\"" "$STATE_FILE" | sed 's/.*: "\([^"]*\)".*/\1/'
    fi
}

# Show current status
show_status() {
    ensure_pipeline_dir
    if [ ! -f "$STATE_FILE" ]; then
        init_state
    fi

    echo "==================================="
    echo "PIPELINE STATUS"
    echo "==================================="
    echo ""

    local stage=$(get_state "stage")
    local step=$(get_state "step")
    local total=$(get_state "totalSteps")
    local current=$(get_state "currentStory")
    local next=$(get_state "nextAction")

    echo "Stage: $stage"
    if [ "$step" -gt 0 ]; then
        echo "Progress: Step $step of $total"
    fi
    if [ -n "$current" ] && [ "$current" != "null" ]; then
        echo "Current Story: $current"
    fi
    echo "Next Action: $next"
    echo ""

    # Show available commands based on stage
    case "$stage" in
        "ready")
            echo "Available: /pipeline requirements \"Your initiative\""
            ;;
        "requirements")
            echo "Available: /pipeline gherkin"
            ;;
        "gherkin")
            echo "Available: /pipeline stories"
            ;;
        "stories")
            echo "Available: /pipeline work [STORY-ID]"
            ;;
        "work")
            echo "Available: /pipeline complete $current"
            ;;
        "complete")
            echo "Available: /pipeline work [NEXT-STORY-ID]"
            echo "         or: /pipeline cleanup (to finish and clean up)"
            ;;
    esac

    echo "==================================="
}

# Reset state
reset_state() {
    if [ -d "$PIPELINE_DIR" ]; then
        rm -rf "$PIPELINE_DIR"
        echo "✓ Pipeline state reset - removed $PIPELINE_DIR directory"
    else
        echo "No pipeline state to reset"
    fi
}

# Cleanup pipeline directory (called when pipeline is complete)
cleanup_pipeline() {
    local stage=$(get_state "stage")

    # Save summary before cleanup
    if [ -f "$STATE_FILE" ]; then
        echo "==================================="
        echo "PIPELINE SUMMARY"
        echo "==================================="
        echo "Project: $(get_state projectKey)"
        echo "Epic: $(get_state epicId)"
        echo "Stories: $(get_state featureStories)"
        echo "Start Time: $(get_state startTime)"
        echo "End Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        echo "==================================="
    fi

    # Remove pipeline directory
    if [ -d "$PIPELINE_DIR" ]; then
        rm -rf "$PIPELINE_DIR"
        echo "✓ Pipeline complete - cleaned up $PIPELINE_DIR directory"
    fi
}

# Error recovery
recover_from_error() {
    local error_stage=$(get_state "stage")
    local error_step=$(get_state "step")
    local error_details="$1"

    echo "❌ Error detected at $error_stage step $error_step"
    echo "Details: $error_details"
    echo ""
    echo "Recovery options:"
    echo "  /pipeline retry    - Retry current step"
    echo "  /pipeline skip     - Skip to next step"
    echo "  /pipeline reset    - Start over"
    echo "  /pipeline status   - Check current state"

    update_state "error" "true"
    update_state "errorDetails" "$error_details"
    update_state "errorStage" "$error_stage"
    update_state "errorStep" "$error_step"
}

# Retry from error
retry_from_error() {
    local error_stage=$(get_state "errorStage")
    local error_step=$(get_state "errorStep")

    if [ -n "$error_stage" ] && [ "$error_stage" != "null" ]; then
        echo "✓ Retrying $error_stage step $error_step"
        update_state "error" "false"
        update_state "errorDetails" ""
        echo "Resume with: /pipeline resume"
    else
        echo "No error state to retry from"
    fi
}

# Main command handler (only run if executed directly, not when sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  case "${1:-}" in
      init)
          init_state
          ;;
      update)
          update_state "$2" "$3"
          ;;
      get)
          get_state "$2"
          ;;
      status)
          show_status
          ;;
      reset)
          reset_state
          ;;
      cleanup)
          cleanup_pipeline
          ;;
      error)
          recover_from_error "${2:-}"
          ;;
      retry)
          retry_from_error
          ;;
      *)
          echo "Usage: $0 {init|update|get|status|reset|cleanup|error|retry}"
          echo ""
          echo "Commands:"
          echo "  init           - Initialize state file"
          echo "  update <field> <value> - Update state field"
          echo "  get <field>    - Get state field value"
          echo "  status         - Show current status"
          echo "  reset          - Reset state to initial"
          echo "  cleanup        - Complete pipeline and clean up"
          echo "  error <msg>    - Record error state"
          echo "  retry          - Retry from error"
          ;;
  esac
fi