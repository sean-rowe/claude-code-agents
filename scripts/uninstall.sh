#!/usr/bin/env bash
# Uninstall script for Claude Pipeline
# Safely removes all Claude Pipeline files and configuration

set -euo pipefail

echo "========================================"
echo "Claude Pipeline - Uninstaller"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detection flags
FOUND_NPM=false
FOUND_HOMEBREW=false
FOUND_MANUAL=false

# Detect installation method
echo "Detecting installation method..."
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
read -p "Proceed with uninstall? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Uninstall cancelled."
  exit 0
fi

echo ""
echo "Uninstalling Claude Pipeline..."
echo ""

# Uninstall npm global package
if [ "$FOUND_NPM" = true ]; then
  echo "Removing npm global package..."
  if npm uninstall -g @claude/pipeline; then
    echo -e "${GREEN}✓${NC} npm package removed"
  else
    echo -e "${RED}✗${NC} Failed to remove npm package"
  fi
  echo ""
fi

# Uninstall Homebrew package
if [ "$FOUND_HOMEBREW" = true ]; then
  echo "Removing Homebrew package..."
  if brew uninstall claude-pipeline; then
    echo -e "${GREEN}✓${NC} Homebrew package removed"
  else
    echo -e "${RED}✗${NC} Failed to remove Homebrew package"
  fi
  echo ""
fi

# Remove manual installation
if [ "$FOUND_MANUAL" = true ]; then
  echo "Removing manual installation..."

  # Remove from /usr/local/bin
  if [ -x "/usr/local/bin/claude-pipeline" ]; then
    sudo rm -f "/usr/local/bin/claude-pipeline" && \
      echo -e "${GREEN}✓${NC} Removed /usr/local/bin/claude-pipeline"
  fi

  # Remove from ~/.local/bin
  if [ -x "$HOME/.local/bin/claude-pipeline" ]; then
    rm -f "$HOME/.local/bin/claude-pipeline" && \
      echo -e "${GREEN}✓${NC} Removed ~/.local/bin/claude-pipeline"
  fi

  # Remove from ~/bin
  if [ -x "$HOME/bin/claude-pipeline" ]; then
    rm -f "$HOME/bin/claude-pipeline" && \
      echo -e "${GREEN}✓${NC} Removed ~/bin/claude-pipeline"
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
  read -p "Remove configuration directory? (y/N) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if rm -rf "$HOME/.claude"; then
      echo -e "${GREEN}✓${NC} Removed ~/.claude directory"
    else
      echo -e "${RED}✗${NC} Failed to remove ~/.claude directory"
    fi
  else
    echo "Kept ~/.claude directory"
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
read -p "Search for .pipeline directories in current directory? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Searching for .pipeline directories in current directory..."
  PIPELINE_DIRS=$(find . -maxdepth 2 -type d -name ".pipeline" 2>/dev/null || true)

  if [ -z "$PIPELINE_DIRS" ]; then
    echo "No .pipeline directories found in current directory"
  else
    echo "Found .pipeline directories:"
    echo ""

    # Check for active work
    HAS_ACTIVE_WORK=false
    while read -r dir; do
      if [ -f "$dir/state.json" ]; then
        # Extract stage from state.json to detect active work
        STAGE=$(jq -r '.stage // "unknown"' "$dir/state.json" 2>/dev/null || echo "unknown")
        if [ "$STAGE" != "complete" ] && [ "$STAGE" != "unknown" ]; then
          echo -e "  ${YELLOW}⚠${NC}  $dir (active work detected: stage=$STAGE)"
          HAS_ACTIVE_WORK=true
        else
          echo "  • $dir"
        fi
      else
        echo "  • $dir"
      fi
    done <<< "$PIPELINE_DIRS"

    echo ""
    if [ "$HAS_ACTIVE_WORK" = true ]; then
      echo -e "${YELLOW}WARNING: Some directories have active work in progress!${NC}"
      echo "Removing these directories will lose your current pipeline state."
      echo ""
    fi

    read -p "Remove these directories? (y/N) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "$PIPELINE_DIRS" | while read -r dir; do
        if rm -rf "$dir"; then
          echo -e "${GREEN}✓${NC} Removed $dir"
        else
          echo -e "${RED}✗${NC} Failed to remove $dir"
        fi
      done
    else
      echo "Kept .pipeline directories"
    fi
  fi
else
  echo "Skipped .pipeline directory cleanup (remove manually with: rm -rf .pipeline)"
fi

echo ""
echo "========================================"
echo -e "${GREEN}Claude Pipeline Uninstall Complete${NC}"
echo "========================================"
echo ""
echo "Verification:"

# Verify removal
if command -v claude-pipeline &>/dev/null; then
  echo -e "${RED}✗${NC} claude-pipeline command still available (may be in PATH cache)"
  echo "   Run: hash -r  # to clear command hash"
else
  echo -e "${GREEN}✓${NC} claude-pipeline command removed"
fi

echo ""
echo "Thank you for using Claude Pipeline!"
echo ""
echo "Feedback and issues: https://github.com/anthropics/claude-code-agents/issues"
echo ""
