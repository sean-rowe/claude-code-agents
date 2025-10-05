#!/usr/bin/env bash

# Claude Pipeline Uninstall Script
# Removes all traces of Claude Pipeline from the system

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Detection flags
NPM_INSTALLED=false
HOMEBREW_INSTALLED=false
MANUAL_INSTALLED=false

# Installation locations (only set if commands exist)
if command -v npm &>/dev/null; then
  readonly NPM_GLOBAL_PATH="$(npm root -g 2>/dev/null)/@claude/pipeline"
  readonly NPM_BIN_PATH="$(npm bin -g 2>/dev/null)/claude-pipeline"
else
  readonly NPM_GLOBAL_PATH=""
  readonly NPM_BIN_PATH=""
fi

if command -v brew &>/dev/null; then
  readonly HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null)"
else
  readonly HOMEBREW_PREFIX=""
fi

readonly MANUAL_BIN_LOCATIONS=(
  "/usr/local/bin/claude-pipeline"
  "$HOME/.local/bin/claude-pipeline"
  "$HOME/bin/claude-pipeline"
)

# Print colored output
print_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if npm installation exists (SRP: single detection method)
is_npm_installed() {
  command -v npm &>/dev/null && npm list -g @claude/pipeline &>/dev/null 2>&1
}

# Check if Homebrew installation exists (SRP: single detection method)
is_homebrew_installed() {
  command -v brew &>/dev/null && brew list claude-pipeline &>/dev/null 2>&1
}

# Check if manual installation exists (SRP: single detection method)
is_manual_installed() {
  for bin_path in "${MANUAL_BIN_LOCATIONS[@]}"; do
    if [ -L "$bin_path" ] || [ -f "$bin_path" ]; then
      # Check if it's actually claude-pipeline by reading file content (safe - no execution)
      if head -n 20 "$bin_path" 2>/dev/null | grep -q "Claude Pipeline\|pipeline.sh"; then
        return 0
      fi
    fi
  done
  return 1
}

# Detect all installation methods and set flags
detect_installations() {
  print_info "Detecting Claude Pipeline installations..."

  # Check each installation type using dedicated functions
  if is_npm_installed; then
    NPM_INSTALLED=true
    print_info "Found npm installation"
  fi

  if is_homebrew_installed; then
    HOMEBREW_INSTALLED=true
    print_info "Found Homebrew installation"
  fi

  if is_manual_installed; then
    MANUAL_INSTALLED=true
    print_info "Found manual installation"
  fi

  # Summary
  if ! $NPM_INSTALLED && ! $HOMEBREW_INSTALLED && ! $MANUAL_INSTALLED; then
    print_warn "No Claude Pipeline installation detected"
    return 1
  fi

  return 0
}

# Uninstall npm version
uninstall_npm() {
  if ! $NPM_INSTALLED; then
    return 0
  fi

  print_info "Uninstalling npm package..."

  if npm uninstall -g @claude/pipeline; then
    print_success "npm package uninstalled"
  else
    print_error "Failed to uninstall npm package"
    return 1
  fi
}

# Uninstall Homebrew version
uninstall_homebrew() {
  if ! $HOMEBREW_INSTALLED; then
    return 0
  fi

  print_info "Uninstalling Homebrew formula..."

  if brew uninstall claude-pipeline; then
    print_success "Homebrew formula uninstalled"
  else
    print_error "Failed to uninstall Homebrew formula"
    return 1
  fi
}

# Uninstall manual installation
uninstall_manual() {
  if ! $MANUAL_INSTALLED; then
    return 0
  fi

  print_info "Removing manual installation..."

  for bin_path in "${MANUAL_BIN_LOCATIONS[@]}"; do
    # Atomic check and validation - avoid TOCTOU
    if [ -L "$bin_path" ]; then
      # Handle symlinks - verify target before removal
      if readlink "$bin_path" | grep -q "pipeline.sh"; then
        print_info "Removing symlink: $bin_path"
        if rm -f "$bin_path"; then
          print_success "Removed $bin_path"
        else
          print_error "Failed to remove $bin_path (may need sudo)"
        fi
      fi
    elif [ -f "$bin_path" ] && [ ! -L "$bin_path" ]; then
      # Regular file - verify content without execution (safe)
      if head -n 20 "$bin_path" 2>/dev/null | grep -q "Claude Pipeline\|pipeline.sh"; then
        print_info "Removing file: $bin_path"
        if rm -f "$bin_path"; then
          print_success "Removed $bin_path"
        else
          print_error "Failed to remove $bin_path (may need sudo)"
        fi
      fi
    fi
  done
}

# Clean up user data
cleanup_user_data() {
  print_info "Checking for user data..."

  # Check for .pipeline directories (validate it's actually Claude Pipeline data)
  if [ -d ".pipeline" ]; then
    # Validate this is Claude Pipeline data before offering deletion
    local is_claude_pipeline=false

    if [ -f ".pipeline/state.json" ]; then
      # Check if state.json contains Claude Pipeline markers
      if grep -q '"stage"\|"projectKey"\|"stories"' ".pipeline/state.json" 2>/dev/null; then
        is_claude_pipeline=true
      fi
    fi

    if [ "$is_claude_pipeline" = true ]; then
      print_warn "Found Claude Pipeline data directory: .pipeline"
      read -p "Remove .pipeline directory? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf .pipeline
        print_success "Removed .pipeline directory"
      else
        print_info "Kept .pipeline directory"
      fi
    else
      print_info "Found .pipeline directory (not Claude Pipeline data - skipping)"
    fi
  fi

  # Check for global config (if any)
  if [ -f "$HOME/.claude-pipeline.conf" ]; then
    print_warn "Found global configuration file"
    read -p "Remove $HOME/.claude-pipeline.conf? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -f "$HOME/.claude-pipeline.conf"
      print_success "Removed configuration file"
    else
      print_info "Kept configuration file"
    fi
  fi
}

# Verify uninstallation
verify_uninstall() {
  print_info "Verifying uninstallation..."

  if command -v claude-pipeline &>/dev/null; then
    print_error "claude-pipeline command still exists"
    print_info "Location: $(which claude-pipeline)"
    return 1
  fi

  print_success "Claude Pipeline completely removed"
  return 0
}

# Main uninstall flow
main() {
  echo "======================================"
  echo "  Claude Pipeline Uninstaller"
  echo "======================================"
  echo

  # Detect installations
  if ! detect_installations; then
    echo
    print_info "Nothing to uninstall. Exiting."
    exit 0
  fi

  echo
  print_warn "This will remove Claude Pipeline from your system."
  read -p "Continue with uninstallation? (y/N): " -n 1 -r
  echo

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Uninstallation cancelled"
    exit 0
  fi

  echo

  # Uninstall based on method
  uninstall_npm
  uninstall_homebrew
  uninstall_manual

  echo

  # Clean up user data (optional)
  cleanup_user_data

  echo

  # Verify
  if verify_uninstall; then
    echo
    print_success "✓ Uninstallation complete!"
    echo
    print_info "Thank you for using Claude Pipeline."
    print_info "Feedback: https://github.com/anthropics/claude-code-agents/issues"
  else
    echo
    print_error "✗ Uninstallation incomplete"
    print_info "Manual cleanup may be required"
    exit 1
  fi
}

# Run main function
main "$@"
