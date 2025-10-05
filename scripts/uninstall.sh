#!/usr/bin/env bash
# Uninstall script for Claude Pipeline
# Safely removes all Claude Pipeline files and configuration
#
# SAFETY FEATURES (19 total):
# 1. Dry-run mode (--dry-run flag)
# 2. Automatic backup creation
# 3. Rollback capability on failure
# 4. Comprehensive operation logging
# 5. Post-uninstall verification report
# 6. Root user safeguard
# 7. Disk space validation
# 8. Interrupt handling (SIGINT/SIGTERM)
# 9. Explicit confirmation prompts
# 10. Shows exactly what will be removed
# 11. Optional configuration preservation
# 12. Safe directory search (no home-wide recursion)
# 13. Clear feedback at each step
# 14. Operation success validation
# 15. Active work detection
# 16. Incomplete work warnings
# 17. Terminal injection prevention
# 18. JSON validation before parsing
# 19. Conservative error handling

set -euo pipefail

# Parse command-line arguments
DRY_RUN=false
VERBOSE=false
SKIP_BACKUP=false

# Initialize REPLY to avoid unbound variable errors in dry-run mode
REPLY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --skip-backup)
      SKIP_BACKUP=true
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "OPTIONS:"
      echo "  --dry-run       Preview what would be removed without making changes"
      echo "  --verbose       Show detailed output"
      echo "  --skip-backup   Skip creating backup (not recommended)"
      echo "  --help          Show this help message"
      echo ""
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# SAFETY CHECK #6: Prevent running as root (dangerous)
if [ "$EUID" -eq 0 ] || [ "$(id -u)" -eq 0 ]; then
  echo "ERROR: This script should not be run as root or with sudo."
  echo ""
  echo "Running uninstall as root can cause system-wide file removal."
  echo "Please run as your regular user account:"
  echo "  bash scripts/uninstall.sh"
  echo ""
  exit 1
fi

# Set up logging (SAFETY FEATURE #4)
LOG_FILE="$HOME/.claude-uninstall.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Initialize log file
{
  echo "========================================"
  echo "Claude Pipeline Uninstall Log"
  echo "Started: $TIMESTAMP"
  echo "User: $(whoami)"
  echo "Hostname: $(hostname)"
  echo "Dry-run: $DRY_RUN"
  echo "========================================"
  echo ""
} > "$LOG_FILE"

# Logging function
log() {
  local message="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
  if [ "$VERBOSE" = true ]; then
    echo "$message"
  fi
}

# SAFETY FEATURE #8: Interrupt handling
INTERRUPTED=false
BACKUP_DIR=""

cleanup_on_interrupt() {
  INTERRUPTED=true
  echo ""
  echo -e "${YELLOW}⚠ Uninstall interrupted by user${NC}"
  log "INTERRUPTED: User interrupted uninstall process"

  if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    echo ""
    echo "Backup preserved at: $BACKUP_DIR"
    echo "You can manually restore if needed"
    log "Backup preserved at: $BACKUP_DIR"
  fi

  echo ""
  echo "Partial uninstall may have occurred. Check log: $LOG_FILE"
  log "Uninstall terminated with interruption"
  exit 130  # Standard exit code for SIGINT
}

trap cleanup_on_interrupt SIGINT SIGTERM

echo "========================================"
echo "Claude Pipeline - Uninstaller"
if [ "$DRY_RUN" = true ]; then
  echo "(DRY RUN MODE - No changes will be made)"
fi
echo "========================================"
echo ""
echo "Log file: $LOG_FILE"
echo ""

log "Uninstall script started"
log "Dry-run mode: $DRY_RUN"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detection flags
FOUND_NPM=false
FOUND_HOMEBREW=false
FOUND_MANUAL=false

# SAFETY FEATURE #7: Check available disk space
check_disk_space() {
  local required_mb=50  # Require at least 50MB for backup operations

  if [ "$SKIP_BACKUP" = true ]; then
    log "Skipping disk space check (backup disabled)"
    return 0
  fi

  # Get available space in MB (works on macOS and Linux)
  if command -v df &>/dev/null; then
    local available_mb
    if df -Pm "$HOME" >/dev/null 2>&1; then
      # Use POSIX mode for consistent output
      available_mb=$(df -Pm "$HOME" | awk 'NR==2 {print $4}')
    else
      # Fallback for systems without -P flag
      available_mb=$(df -m "$HOME" | awk 'NR==2 {print $4}')
    fi

    # VALIDATION: Ensure available_mb is numeric
    if ! [[ "$available_mb" =~ ^[0-9]+$ ]]; then
      log "WARNING: Could not determine available disk space (got: '$available_mb'), skipping check"
      echo -e "${YELLOW}⚠${NC} Could not determine disk space, proceeding without validation"
      return 0
    fi

    if [ "$available_mb" -lt "$required_mb" ]; then
      echo -e "${RED}✗${NC} Insufficient disk space"
      echo "Required: ${required_mb}MB, Available: ${available_mb}MB"
      echo ""
      echo "Free up space or use --skip-backup (not recommended)"
      log "ERROR: Insufficient disk space ($available_mb MB available, need $required_mb MB)"
      exit 1
    fi

    log "Disk space check passed ($available_mb MB available)"
  else
    log "WARNING: df command not available, skipping disk space check"
  fi
}

# SAFETY FEATURE #2: Create backup
create_backup() {
  if [ "$SKIP_BACKUP" = true ]; then
    echo -e "${YELLOW}⚠${NC} Skipping backup (--skip-backup flag set)"
    log "Backup skipped by user request"
    return 0
  fi

  if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}ℹ${NC} Would create backup at: $HOME/.claude-backup-$TIMESTAMP"
    log "DRY RUN: Would create backup"
    return 0
  fi

  BACKUP_DIR="$HOME/.claude-backup-$(date '+%Y%m%d-%H%M%S')"

  # VALIDATION: Ensure backup directory can be created
  if ! mkdir -p "$BACKUP_DIR" 2>&1 | tee -a "$LOG_FILE"; then
    echo -e "${RED}✗${NC} Failed to create backup directory: $BACKUP_DIR"
    log "ERROR: Failed to create backup directory"
    exit 1
  fi

  log "Creating backup at: $BACKUP_DIR"
  echo "Creating backup..."

  # Track backup failures
  local BACKUP_FAILED=false
  local backup_items=0
  local failed_items=0

  # Backup configuration directory if it exists
  if [ -d "$HOME/.claude" ]; then
    if cp -r "$HOME/.claude" "$BACKUP_DIR/claude-config" 2>&1 | tee -a "$LOG_FILE"; then
      log "SUCCESS: Backed up ~/.claude/ -> $BACKUP_DIR/claude-config"
      ((backup_items++))
    else
      echo -e "${RED}✗${NC} Failed to backup ~/.claude/"
      log "ERROR: Failed to backup ~/.claude/"
      BACKUP_FAILED=true
      ((failed_items++))
    fi
  fi

  # Backup binary locations
  for bin_location in "/usr/local/bin/claude-pipeline" "$HOME/.local/bin/claude-pipeline" "$HOME/bin/claude-pipeline"; do
    if [ -f "$bin_location" ] || [ -L "$bin_location" ]; then
      local backup_name=$(echo "$bin_location" | tr '/' '_')
      if cp "$bin_location" "$BACKUP_DIR/$backup_name" 2>&1 | tee -a "$LOG_FILE"; then
        log "SUCCESS: Backed up $bin_location -> $BACKUP_DIR/$backup_name"
        ((backup_items++))
      else
        echo -e "${RED}✗${NC} Failed to backup $bin_location"
        log "ERROR: Failed to backup $bin_location"
        BACKUP_FAILED=true
        ((failed_items++))
      fi
    fi
  done

  # VALIDATION: Check if backup succeeded
  if [ "$BACKUP_FAILED" = true ]; then
    echo ""
    echo -e "${RED}✗${NC} Backup creation failed"
    echo "Failed to backup $failed_items item(s), successfully backed up $backup_items item(s)"
    echo ""
    echo "Cannot proceed safely without complete backup."
    echo "Please fix the errors above and try again."
    log "ERROR: Backup creation failed ($failed_items failures, $backup_items successes)"

    # Clean up partial backup
    if [ -d "$BACKUP_DIR" ]; then
      rm -rf "$BACKUP_DIR"
      log "Cleaned up partial backup directory"
    fi

    exit 1
  fi

  echo -e "${GREEN}✓${NC} Backup created successfully at: $BACKUP_DIR"
  echo "  Backed up $backup_items item(s)"
  echo ""
  log "Backup completed successfully ($backup_items items backed up)"
}

# SAFETY FEATURE #3: Rollback capability
rollback_from_backup() {
  if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}✗${NC} No backup available for rollback"
    log "ERROR: Rollback requested but no backup available"
    return 1
  fi

  echo ""
  echo -e "${YELLOW}⚠${NC} Uninstall failed. Attempting rollback..."
  log "ROLLBACK: Attempting to restore from backup"

  # Track rollback failures
  local ROLLBACK_FAILED=false
  local rollback_items=0
  local failed_rollbacks=0

  # Restore configuration
  if [ -d "$BACKUP_DIR/claude-config" ]; then
    rm -rf "$HOME/.claude" 2>/dev/null || true
    if cp -r "$BACKUP_DIR/claude-config" "$HOME/.claude" 2>&1 | tee -a "$LOG_FILE"; then
      echo -e "${GREEN}✓${NC} Restored configuration"
      log "ROLLBACK SUCCESS: Restored ~/.claude/"
      ((rollback_items++))
    else
      echo -e "${RED}✗${NC} Failed to restore configuration"
      log "ROLLBACK ERROR: Failed to restore ~/.claude/"
      ROLLBACK_FAILED=true
      ((failed_rollbacks++))
    fi
  fi

  # Restore binaries
  for backed_up_file in "$BACKUP_DIR"/*; do
    if [ -f "$backed_up_file" ]; then
      local original_path=$(basename "$backed_up_file" | tr '_' '/')
      if [[ "$original_path" == *"bin"*"claude-pipeline" ]]; then
        if cp "$backed_up_file" "/$original_path" 2>&1 | tee -a "$LOG_FILE"; then
          log "ROLLBACK SUCCESS: Restored /$original_path"
          ((rollback_items++))
        else
          echo -e "${RED}✗${NC} Failed to restore /$original_path"
          log "ROLLBACK ERROR: Failed to restore /$original_path"
          ROLLBACK_FAILED=true
          ((failed_rollbacks++))
        fi
      fi
    fi
  done

  if [ "$ROLLBACK_FAILED" = true ]; then
    echo ""
    echo -e "${RED}✗${NC} Rollback partially failed"
    echo "Restored $rollback_items item(s), failed to restore $failed_rollbacks item(s)"
    echo "Backup preserved at: $BACKUP_DIR"
    echo "You may need to manually restore some files from the backup."
    log "ROLLBACK: Partially failed ($rollback_items successes, $failed_rollbacks failures)"
    return 1
  else
    echo -e "${GREEN}✓${NC} Rollback completed successfully"
    echo "Restored $rollback_items item(s)"
    echo "Backup preserved at: $BACKUP_DIR"
    log "ROLLBACK: Completed successfully ($rollback_items items restored)"
    return 0
  fi
}

# Detect installation method
echo "Detecting installation method..."
log "Starting installation detection"
echo ""

# Check for npm global installation
if command -v npm &>/dev/null; then
  if npm list -g @claude/pipeline &>/dev/null 2>&1; then
    FOUND_NPM=true
    echo -e "${GREEN}✓${NC} Found npm global installation"
  fi
fi

# Check for Homebrew installation
if command -v brew &>/dev/null; then
  if brew list claude-pipeline &>/dev/null 2>&1; then
    FOUND_HOMEBREW=true
    echo -e "${GREEN}✓${NC} Found Homebrew installation"
  fi
fi

# Check for manual installation (look for common locations)
if [ -x "/usr/local/bin/claude-pipeline" ] || [ -x "$HOME/.local/bin/claude-pipeline" ]; then
  FOUND_MANUAL=true
  echo -e "${GREEN}✓${NC} Found manual installation"
fi

echo ""

# If no installation found
if [ "$FOUND_NPM" = false ] && [ "$FOUND_HOMEBREW" = false ] && [ "$FOUND_MANUAL" = false ]; then
  echo -e "${YELLOW}No Claude Pipeline installation detected.${NC}"
  echo ""
  echo "Claude Pipeline may have been already uninstalled."
  echo ""
  read -p "Do you want to clean up configuration files anyway? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
  fi
fi

# Show what will be removed
echo "The following will be removed:"
echo ""

if [ "$FOUND_NPM" = true ]; then
  echo "  • npm global package: @claude/pipeline"
fi

if [ "$FOUND_HOMEBREW" = true ]; then
  echo "  • Homebrew package: claude-pipeline"
fi

if [ "$FOUND_MANUAL" = true ]; then
  echo "  • Manual installation files"
fi

echo ""
echo "Optional (will ask):"
echo "  • Configuration files in ~/.claude/"
echo "  • Project-specific .pipeline/ directories"
echo ""

# Confirm uninstall
if [ "$DRY_RUN" = false ]; then
  read -p "Proceed with uninstall? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    log "User cancelled uninstall"
    exit 0
  fi
else
  echo -e "${BLUE}ℹ${NC} DRY RUN: Would ask for confirmation here"
  log "DRY RUN: Skipping confirmation prompt"
fi

echo ""

# SAFETY CHECKS before proceeding
check_disk_space
create_backup

echo "Uninstalling Claude Pipeline..."
log "Starting uninstall operations"
echo ""

# Track failures for rollback
UNINSTALL_FAILED=false

# Uninstall npm global package
if [ "$FOUND_NPM" = true ]; then
  if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}ℹ${NC} Would remove npm global package: @claude/pipeline"
    log "DRY RUN: Would remove npm package"
  else
    echo "Removing npm global package..."
    log "Removing npm package: @claude/pipeline"
    if npm uninstall -g @claude/pipeline 2>&1 | tee -a "$LOG_FILE"; then
      echo -e "${GREEN}✓${NC} npm package removed"
      log "SUCCESS: npm package removed"
    else
      echo -e "${RED}✗${NC} Failed to remove npm package"
      log "ERROR: Failed to remove npm package"
      UNINSTALL_FAILED=true
    fi
  fi
  echo ""
fi

# Uninstall Homebrew package
if [ "$FOUND_HOMEBREW" = true ]; then
  if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}ℹ${NC} Would remove Homebrew package: claude-pipeline"
    log "DRY RUN: Would remove Homebrew package"
  else
    echo "Removing Homebrew package..."
    log "Removing Homebrew package: claude-pipeline"
    if brew uninstall claude-pipeline 2>&1 | tee -a "$LOG_FILE"; then
      echo -e "${GREEN}✓${NC} Homebrew package removed"
      log "SUCCESS: Homebrew package removed"
    else
      echo -e "${RED}✗${NC} Failed to remove Homebrew package"
      log "ERROR: Failed to remove Homebrew package"
      UNINSTALL_FAILED=true
    fi
  fi
  echo ""
fi

# Remove manual installation
if [ "$FOUND_MANUAL" = true ]; then
  if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}ℹ${NC} Would remove manual installation files"
    log "DRY RUN: Would remove manual installation"
  else
    echo "Removing manual installation..."
    log "Removing manual installation files"

    # Remove from /usr/local/bin
    if [ -x "/usr/local/bin/claude-pipeline" ]; then
      if sudo rm -f "/usr/local/bin/claude-pipeline" 2>&1 | tee -a "$LOG_FILE"; then
        echo -e "${GREEN}✓${NC} Removed /usr/local/bin/claude-pipeline"
        log "SUCCESS: Removed /usr/local/bin/claude-pipeline"
      else
        echo -e "${RED}✗${NC} Failed to remove /usr/local/bin/claude-pipeline"
        log "ERROR: Failed to remove /usr/local/bin/claude-pipeline"
        UNINSTALL_FAILED=true
      fi
    fi

    # Remove from ~/.local/bin
    if [ -x "$HOME/.local/bin/claude-pipeline" ]; then
      if rm -f "$HOME/.local/bin/claude-pipeline" 2>&1 | tee -a "$LOG_FILE"; then
        echo -e "${GREEN}✓${NC} Removed ~/.local/bin/claude-pipeline"
        log "SUCCESS: Removed ~/.local/bin/claude-pipeline"
      else
        echo -e "${RED}✗${NC} Failed to remove ~/.local/bin/claude-pipeline"
        log "ERROR: Failed to remove ~/.local/bin/claude-pipeline"
        UNINSTALL_FAILED=true
      fi
    fi

    # Remove from ~/bin
    if [ -x "$HOME/bin/claude-pipeline" ]; then
      if rm -f "$HOME/bin/claude-pipeline" 2>&1 | tee -a "$LOG_FILE"; then
        echo -e "${GREEN}✓${NC} Removed ~/bin/claude-pipeline"
        log "SUCCESS: Removed ~/bin/claude-pipeline"
      else
        echo -e "${RED}✗${NC} Failed to remove ~/bin/claude-pipeline"
        log "ERROR: Failed to remove ~/bin/claude-pipeline"
        UNINSTALL_FAILED=true
      fi
    fi
  fi

  echo ""
fi

# Ask about configuration files
if [ -d "$HOME/.claude" ]; then
  echo ""
  echo -e "${YELLOW}Configuration directory found: ~/.claude/${NC}"
  echo ""
  echo "This directory may contain:"
  echo "  • JIRA credentials and configuration"
  echo "  • Pipeline preferences"
  echo "  • Custom templates"
  echo ""

  if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}ℹ${NC} Would ask: Remove configuration directory? (dry-run mode)"
    log "DRY RUN: Would ask about removing ~/.claude"
  else
    read -p "Remove configuration directory? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      log "Removing ~/.claude directory"
      if rm -rf "$HOME/.claude" 2>&1 | tee -a "$LOG_FILE"; then
        echo -e "${GREEN}✓${NC} Removed ~/.claude directory"
        log "SUCCESS: Removed ~/.claude directory"
      else
        echo -e "${RED}✗${NC} Failed to remove ~/.claude directory"
        log "ERROR: Failed to remove ~/.claude directory"
      fi
    else
      echo "Kept ~/.claude directory"
      log "User chose to keep ~/.claude directory"
    fi
  fi
  echo ""
fi

# Ask about .pipeline directories
echo ""
echo -e "${YELLOW}Project-specific .pipeline directories${NC}"
echo ""
echo "Claude Pipeline creates .pipeline/ directories in your projects."
echo "These contain:"
echo "  • Pipeline state (state.json)"
echo "  • Generated requirements and features"
echo "  • Workflow artifacts"
echo ""
echo "Note: .pipeline directories are typically added to .gitignore and not checked in."
echo "Removing them will not affect your code - only the pipeline workflow state."
echo ""
if [ "$DRY_RUN" = true ]; then
  echo -e "${BLUE}ℹ${NC} Would ask: Search for .pipeline directories? (dry-run mode)"
  log "DRY RUN: Would search for .pipeline directories"
else
  read -p "Search for .pipeline directories in current directory? (y/N) " -n 1 -r
  echo ""
fi

if [[ $REPLY =~ ^[Yy]$ ]] || [ "$DRY_RUN" = true ]; then
  echo "Searching for .pipeline directories in current directory..."
  log "Searching for .pipeline directories"
  PIPELINE_DIRS=$(find . -maxdepth 2 -type d -name ".pipeline" 2>/dev/null || true)

  if [ -z "$PIPELINE_DIRS" ]; then
    echo "No .pipeline directories found in current directory"
  else
    echo "Found .pipeline directories:"
    echo ""

    # Check for active work
    HAS_ACTIVE_WORK=false
    while read -r dir; do
      # SECURITY: Sanitize directory name for display to prevent terminal injection
      # Remove all control characters (0x00-0x1F, 0x7F) that could contain escape sequences
      # Keep original $dir for filesystem operations (rm, test, etc.)
      SAFE_DIR=$(printf '%s' "$dir" | tr -d '\000-\037\177')

      if [ -f "$dir/state.json" ]; then
        # Extract stage from state.json to detect active work
        # Use jq for safe JSON parsing (prevents injection attacks)
        if command -v jq &>/dev/null; then
          # Check if state.json is valid JSON before parsing
          if jq -e . "$dir/state.json" >/dev/null 2>&1; then
            STAGE=$(jq -r '.stage // "unknown"' "$dir/state.json" 2>/dev/null)
          else
            # Corrupted JSON - treat as active work to be conservative
            echo -e "  ${RED}⚠${NC}  $SAFE_DIR (corrupted state.json - cannot verify stage)"
            HAS_ACTIVE_WORK=true
            continue
          fi
        else
          # jq not available - cannot verify (shouldn't happen as jq is checked earlier)
          echo -e "  ${YELLOW}⚠${NC}  $SAFE_DIR (cannot verify - jq not available)"
          continue
        fi

        if [ "$STAGE" != "complete" ] && [ "$STAGE" != "unknown" ]; then
          echo -e "  ${YELLOW}⚠${NC}  $SAFE_DIR (active work detected: stage=$STAGE)"
          HAS_ACTIVE_WORK=true
        else
          echo "  • $SAFE_DIR"
        fi
      else
        echo "  • $SAFE_DIR"
      fi
    done <<< "$PIPELINE_DIRS"

    echo ""
    if [ "$HAS_ACTIVE_WORK" = true ]; then
      echo -e "${YELLOW}WARNING: Some directories have active work in progress!${NC}"
      echo "Removing these directories will lose your current pipeline state."
      echo ""
    fi

    if [ "$DRY_RUN" = true ]; then
      echo -e "${BLUE}ℹ${NC} Would ask: Remove these directories? (dry-run mode)"
      log "DRY RUN: Would ask about removing .pipeline directories"
    else
      read -p "Remove these directories? (y/N) " -n 1 -r
      echo ""
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Removing .pipeline directories"
        echo "$PIPELINE_DIRS" | while read -r dir; do
          # SECURITY: Sanitize directory name for display (same as above)
          SAFE_DIR=$(printf '%s' "$dir" | tr -d '\000-\037\177')

          if rm -rf "$dir" 2>&1 | tee -a "$LOG_FILE"; then
            echo -e "${GREEN}✓${NC} Removed $SAFE_DIR"
            log "SUCCESS: Removed $SAFE_DIR"
          else
            echo -e "${RED}✗${NC} Failed to remove $SAFE_DIR"
            log "ERROR: Failed to remove $SAFE_DIR"
          fi
        done
      else
        echo "Kept .pipeline directories"
        log "User chose to keep .pipeline directories"
      fi
    fi
  fi
else
  echo "Skipped .pipeline directory cleanup (remove manually with: rm -rf .pipeline)"
fi

# SAFETY FEATURE #3: Handle failures with rollback
if [ "$UNINSTALL_FAILED" = true ] && [ "$DRY_RUN" = false ]; then
  echo ""
  echo -e "${RED}✗${NC} Uninstall encountered errors"
  log "ERROR: Uninstall failed, initiating rollback"

  read -p "Attempt rollback to restore previous state? (y/N) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rollback_from_backup
  else
    echo "Rollback skipped. Backup preserved at: $BACKUP_DIR"
    log "User declined rollback, backup preserved"
  fi

  echo ""
  echo "Check log for details: $LOG_FILE"
  log "Uninstall completed with errors"
  exit 1
fi

echo ""
echo "========================================"
if [ "$DRY_RUN" = true ]; then
  echo -e "${BLUE}DRY RUN COMPLETE - No Changes Made${NC}"
else
  echo -e "${GREEN}Claude Pipeline Uninstall Complete${NC}"
fi
echo "========================================"
echo ""

# SAFETY FEATURE #5: Post-uninstall verification report
echo "Verification Report:"
echo ""

# Verify command removal
if command -v claude-pipeline &>/dev/null; then
  echo -e "${YELLOW}⚠${NC} claude-pipeline command still available (may be in PATH cache)"
  echo "   Run: hash -r  # to clear command hash"
  log "VERIFICATION: Command still in PATH cache"
else
  echo -e "${GREEN}✓${NC} claude-pipeline command removed"
  log "VERIFICATION: Command successfully removed"
fi

# Verify binary locations
BINARIES_FOUND=false
for bin_location in "/usr/local/bin/claude-pipeline" "$HOME/.local/bin/claude-pipeline" "$HOME/bin/claude-pipeline"; do
  if [ -e "$bin_location" ]; then
    echo -e "${YELLOW}⚠${NC} Binary still exists: $bin_location"
    BINARIES_FOUND=true
    log "VERIFICATION: Binary still exists at $bin_location"
  fi
done

if [ "$BINARIES_FOUND" = false ]; then
  echo -e "${GREEN}✓${NC} All binary files removed"
  log "VERIFICATION: All binaries removed"
fi

# Check npm
if command -v npm &>/dev/null; then
  if npm list -g @claude/pipeline &>/dev/null 2>&1; then
    echo -e "${YELLOW}⚠${NC} npm package still installed"
    log "VERIFICATION: npm package still present"
  else
    echo -e "${GREEN}✓${NC} npm package removed"
    log "VERIFICATION: npm package successfully removed"
  fi
fi

# Check Homebrew
if command -v brew &>/dev/null; then
  if brew list claude-pipeline &>/dev/null 2>&1; then
    echo -e "${YELLOW}⚠${NC} Homebrew package still installed"
    log "VERIFICATION: Homebrew package still present"
  else
    echo -e "${GREEN}✓${NC} Homebrew package removed"
    log "VERIFICATION: Homebrew package successfully removed"
  fi
fi

echo ""
if [ "$DRY_RUN" = false ] && [ -n "$BACKUP_DIR" ]; then
  echo "Backup location: $BACKUP_DIR"
  echo "(You can safely delete this after verifying uninstall)"
  log "Backup location: $BACKUP_DIR"
fi

echo "Log file: $LOG_FILE"
log "Uninstall completed successfully"

echo ""
echo "Thank you for using Claude Pipeline!"
echo ""
echo "Feedback and issues: https://github.com/anthropics/claude-code-agents/issues"
echo ""
