#!/bin/bash
# Pipeline State Manager
# Manages state for pipeline execution

STATE_FILE="pipeline-state.json"

# Initialize state if not exists
init_state() {
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
    "nextAction": "Run '/pipeline requirements' to start"
}
EOF
        echo "✓ Pipeline state initialized"
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

    if [ ! -f "$STATE_FILE" ]; then
        init_state
    fi

    # Use jq to update JSON field
    if command -v jq &>/dev/null; then
        jq ".$field = \"$value\"" "$STATE_FILE" > tmp.json && mv tmp.json "$STATE_FILE"
    else
        # Fallback to sed if jq not available
        sed -i.bak "s/\"$field\": \"[^\"]*\"/\"$field\": \"$value\"/" "$STATE_FILE"
    fi
}

# Get state field
get_state() {
    local field=$1

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
            ;;
    esac

    echo "==================================="
}

# Reset state
reset_state() {
    rm -f "$STATE_FILE"
    init_state
    echo "✓ Pipeline state reset"
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

# Main command handler
case "$1" in
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
    *)
        echo "Usage: $0 {init|update|get|status|reset}"
        echo ""
        echo "Commands:"
        echo "  init           - Initialize state file"
        echo "  update <field> <value> - Update state field"
        echo "  get <field>    - Get state field value"
        echo "  status         - Show current status"
        echo "  reset          - Reset state to initial"
        ;;
esac