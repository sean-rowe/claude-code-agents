#!/bin/bash
# Pipeline State Manager
# Manages state for pipeline execution in .pipeline directory

set -euo pipefail

# Directory and file paths
PIPELINE_DIR=".pipeline"
STATE_FILE="$PIPELINE_DIR/state.json"
BACKUP_DIR="$PIPELINE_DIR/backups"
LOCK_FILE="$PIPELINE_DIR/.lock"
SCHEMA_FILE=".pipeline-schema.json"
STATE_HISTORY_FILE="$PIPELINE_DIR/state-history.log"

# Configuration constants
readonly LOCK_TIMEOUT_SECONDS=30
readonly STALE_LOCK_AGE_SECONDS=300
readonly BACKUP_RETENTION_COUNT=10

# Ensure pipeline directory exists
ensure_pipeline_dir() {
    if [ ! -d "$PIPELINE_DIR" ]; then
        mkdir -p "$PIPELINE_DIR"
        mkdir -p "$BACKUP_DIR"
        echo "✓ Created $PIPELINE_DIR directory for pipeline state"
    fi

    # Ensure backup directory exists
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi

    # Always ensure .gitignore is updated (even if directory already exists)
    if [ -f .gitignore ]; then
        if ! grep -q "^\.pipeline" .gitignore; then
            echo ".pipeline/" >> .gitignore
            echo "✓ Added .pipeline to .gitignore"
        fi
    fi
}

# Acquire lock for concurrent run protection
acquire_lock() {
    local max_wait=$LOCK_TIMEOUT_SECONDS
    local waited=0
    local lock_dir="${LOCK_FILE}.lock"

    # Verify lock directory ownership if it exists (security check)
    if [ -d "$lock_dir" ]; then
        local lock_owner=$(stat -f %u "$lock_dir" 2>/dev/null || stat -c %u "$lock_dir" 2>/dev/null)
        if [ -n "$lock_owner" ] && [ "$lock_owner" != "$(id -u)" ]; then
            echo "❌ Lock directory owned by different user (uid: $lock_owner) - potential attack" >&2
            echo "   Lock path: $lock_dir" >&2
            return 1
        fi
    fi

    # Use atomic mkdir operation to acquire lock (prevents TOCTOU race)
    while ! mkdir "$lock_dir" 2>/dev/null; do
        if [ $waited -ge $max_wait ]; then
            # Check if lock is stale (older than configured age)
            if [ -d "$lock_dir" ]; then
                local lock_age=$(($(date +%s) - $(stat -f %m "$lock_dir" 2>/dev/null || stat -c %Y "$lock_dir" 2>/dev/null)))
                if [ $lock_age -gt $STALE_LOCK_AGE_SECONDS ]; then
                    echo "⚠ Removing stale lock (${lock_age}s old)"
                    rm -rf "$lock_dir"
                    # Try one more time after removing stale lock
                    if mkdir "$lock_dir" 2>/dev/null; then
                        chmod 700 "$lock_dir"
                        echo "$$" > "$lock_dir/pid"
                        return 0
                    fi
                fi
            fi
            echo "❌ Pipeline locked by another process. Try again later."
            return 1
        fi
        echo "⏳ Waiting for lock... ($waited/$max_wait)"
        sleep 1
        waited=$((waited + 1))
    done

    # Lock acquired atomically - set restrictive permissions and store PID
    chmod 700 "$lock_dir"
    echo "$$" > "$lock_dir/pid"
    return 0
}

# Release lock
release_lock() {
    local lock_dir="${LOCK_FILE}.lock"

    if [ -d "$lock_dir" ]; then
        # Verify we own the lock before releasing
        if [ -f "$lock_dir/pid" ]; then
            local lock_pid=$(cat "$lock_dir/pid")
            if [ "$lock_pid" = "$$" ]; then
                rm -rf "$lock_dir"
            fi
        else
            # No PID file - safe to remove our own lock
            rm -rf "$lock_dir"
        fi
    fi
}

# Validate state.json against schema
validate_state() {
    local state_file="${1:-$STATE_FILE}"

    if [ ! -f "$state_file" ]; then
        echo "❌ State file not found: $state_file"
        return 1
    fi

    # Check if file is valid JSON
    if ! jq empty "$state_file" 2>/dev/null; then
        echo "❌ State file is not valid JSON"
        return 1
    fi

    # Validate against schema if available
    if [ -f "$SCHEMA_FILE" ] && command -v ajv &>/dev/null; then
        if ajv validate -s "$SCHEMA_FILE" -d "$state_file" 2>/dev/null; then
            return 0
        else
            echo "⚠ State file does not match schema"
            return 1
        fi
    fi

    # Basic validation without schema
    local required_fields=("stage" "projectKey" "featureStories" "ruleStories" "tasks")
    for field in "${required_fields[@]}"; do
        if ! jq -e ".$field" "$state_file" >/dev/null 2>&1; then
            echo "❌ Missing required field: $field"
            return 1
        fi
    done

    return 0
}

# Create backup of current state
backup_state() {
    ensure_pipeline_dir

    if [ ! -f "$STATE_FILE" ]; then
        echo "⚠ No state file to backup"
        return 1
    fi

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/state_${timestamp}.json"
    local temp_backup="$backup_file.tmp"

    # Atomic write: write to temp file then rename
    cp "$STATE_FILE" "$temp_backup"
    mv "$temp_backup" "$backup_file"
    echo "✓ State backed up to $backup_file"

    # Log backup creation
    log_state_change "BACKUP_CREATED" "Backup: $(basename "$backup_file")"

    # Keep only configured number of backups
    local retention_line=$((BACKUP_RETENTION_COUNT + 1))
    ls -t "$BACKUP_DIR"/state_*.json 2>/dev/null | tail -n +$retention_line | xargs rm -f 2>/dev/null || true

    return 0
}

# Restore state from backup
restore_state() {
    local backup_file="$1"

    ensure_pipeline_dir

    if [ -z "$backup_file" ]; then
        # Find most recent backup
        backup_file=$(ls -t "$BACKUP_DIR"/state_*.json 2>/dev/null | head -n 1)
        if [ -z "$backup_file" ]; then
            echo "❌ No backup files found"
            return 1
        fi
    fi

    if [ ! -f "$backup_file" ]; then
        echo "❌ Backup file not found: $backup_file"
        return 1
    fi

    # Validate backup before restoring
    if validate_state "$backup_file"; then
        # Backup current state before overwriting (safety measure)
        if [ -f "$STATE_FILE" ]; then
            local pre_restore_backup="$BACKUP_DIR/pre_restore_$(date +%Y%m%d_%H%M%S).json"
            local temp_backup="$pre_restore_backup.tmp"
            cp "$STATE_FILE" "$temp_backup"
            mv "$temp_backup" "$pre_restore_backup"
            echo "✓ Current state backed up to $(basename "$pre_restore_backup")"
        fi

        # Restore using atomic write
        local temp_restore="$STATE_FILE.tmp"
        cp "$backup_file" "$temp_restore"
        mv "$temp_restore" "$STATE_FILE"
        echo "✓ State restored from $(basename "$backup_file")"

        # Log restore operation
        log_state_change "STATE_RESTORED" "From: $(basename "$backup_file")"

        return 0
    else
        echo "❌ Backup file is corrupt, cannot restore"
        return 1
    fi
}

# List available backups
list_backups() {
    ensure_pipeline_dir

    if [ ! -d "$BACKUP_DIR" ]; then
        echo "No backups found"
        return 0
    fi

    local backups=$(ls -t "$BACKUP_DIR"/state_*.json 2>/dev/null)
    if [ -z "$backups" ]; then
        echo "No backups found"
        return 0
    fi

    echo "==================================="
    echo "AVAILABLE BACKUPS"
    echo "==================================="
    echo "$backups" | while read -r backup; do
        local timestamp=$(basename "$backup" | sed 's/state_\(.*\)\.json/\1/')
        local size=$(wc -c < "$backup" | tr -d ' ')
        echo "  $timestamp (${size} bytes)"
    done
    echo "==================================="
}

# Log state change to history
log_state_change() {
    local action="$1"
    local details="${2:-}"

    ensure_pipeline_dir

    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "[$timestamp] $action${details:+: $details}" >> "$STATE_HISTORY_FILE"
}

# Detect and recover from corruption
detect_and_recover() {
    ensure_pipeline_dir

    if [ ! -f "$STATE_FILE" ]; then
        echo "⚠ No state file found, initializing new state"
        init_state
        return 0
    fi

    # Try to validate current state
    if validate_state; then
        echo "✓ State file is valid"
        return 0
    fi

    echo "❌ State file is corrupt!"
    echo ""
    echo "Attempting automatic recovery..."

    # Try to restore from most recent backup
    if restore_state; then
        echo "✓ Successfully recovered from backup"
        log_state_change "AUTO_RECOVERY" "Restored from backup due to corruption"
        return 0
    fi

    echo "❌ Could not recover from backup"
    echo ""
    echo "Manual recovery options:"
    echo "  1. Restore from specific backup: ./pipeline-state-manager.sh restore <backup-file>"
    echo "  2. View available backups: ./pipeline-state-manager.sh list-backups"
    echo "  3. Reset and start over: ./pipeline-state-manager.sh reset"

    return 1
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
        # Safe parsing of .env without executing code (prevents shell injection)
        local project_key=$(grep -E "^PROJECT_KEY=" .env 2>/dev/null | head -n 1 | cut -d= -f2- | tr -d '"' | tr -d "'")
        if [ -n "$project_key" ]; then
            echo "$project_key"
        else
            echo "PROJ"
        fi
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

    # Acquire lock before modifying state
    if ! acquire_lock; then
        echo "❌ Failed to acquire lock for state update" >&2
        return 1
    fi

    # Create backup before modification
    backup_state

    # Use jq to update JSON field (safe parameter substitution)
    if command -v jq &>/dev/null; then
        # Use --arg for safe variable substitution (prevents injection)
        jq --arg field "$field" --arg value "$value" '.[$field] = $value' "$STATE_FILE" > "$PIPELINE_DIR/tmp.json"

        # Validate the update succeeded
        if [ $? -eq 0 ] && validate_state "$PIPELINE_DIR/tmp.json"; then
            mv "$PIPELINE_DIR/tmp.json" "$STATE_FILE"
            log_state_change "UPDATE" "Set $field = $value"
        else
            echo "❌ State update failed validation" >&2
            rm -f "$PIPELINE_DIR/tmp.json"
            release_lock
            return 1
        fi
    else
        # Fallback to sed if jq not available (less safe, requires jq)
        echo "❌ jq is required for safe state updates" >&2
        release_lock
        return 1
    fi

    # Release lock after successful update
    release_lock
    return 0
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
      validate)
          validate_state
          echo "✓ State validation complete"
          ;;
      backup)
          backup_state
          ;;
      restore)
          restore_state "${2:-}"
          ;;
      list-backups)
          list_backups
          ;;
      detect-corruption)
          detect_and_recover
          ;;
      lock)
          acquire_lock
          ;;
      unlock)
          release_lock
          ;;
      *)
          echo "Usage: $0 {init|update|get|status|reset|cleanup|error|retry|validate|backup|restore|list-backups|detect-corruption|lock|unlock}"
          echo ""
          echo "Commands:"
          echo "  init                  - Initialize state file"
          echo "  update <field> <value> - Update state field"
          echo "  get <field>           - Get state field value"
          echo "  status                - Show current status"
          echo "  reset                 - Reset state to initial"
          echo "  cleanup               - Complete pipeline and clean up"
          echo "  error <msg>           - Record error state"
          echo "  retry                 - Retry from error"
          echo "  validate              - Validate state.json against schema"
          echo "  backup                - Create backup of current state"
          echo "  restore [file]        - Restore from backup (latest if no file specified)"
          echo "  list-backups          - List available backups"
          echo "  detect-corruption     - Detect and auto-recover from corrupted state"
          echo "  lock                  - Acquire pipeline lock"
          echo "  unlock                - Release pipeline lock"
          ;;
  esac
fi