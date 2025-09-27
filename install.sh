#!/bin/bash

# Claude Code Agents Installation Script
# https://github.com/sean-rowe/claude-code-agents

set -e

CLAUDE_DIR="$HOME/.claude"
REPO_URL="https://github.com/sean-rowe/claude-code-agents.git"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       Claude Code Agents - Installation Script          ║${NC}"
echo -e "${BLUE}║          Production-Ready DDD, BDD, Agile Agents        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print colored messages
print_step() {
    echo -e "${GREEN}➤${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "git is not installed. Please install git first."
    exit 1
fi

# Create Claude directory if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    print_step "Creating Claude configuration directory..."
    mkdir -p "$CLAUDE_DIR"
    print_success "Created $CLAUDE_DIR"
else
    print_step "Claude directory already exists at $CLAUDE_DIR"
fi

# Backup existing files if they exist
if [ -d "$CLAUDE_DIR/agents" ] || [ -d "$CLAUDE_DIR/commands" ]; then
    BACKUP_DIR="$CLAUDE_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    print_warning "Existing agents/commands found. Creating backup..."
    mkdir -p "$BACKUP_DIR"

    [ -d "$CLAUDE_DIR/agents" ] && cp -r "$CLAUDE_DIR/agents" "$BACKUP_DIR/"
    [ -d "$CLAUDE_DIR/commands" ] && cp -r "$CLAUDE_DIR/commands" "$BACKUP_DIR/"
    [ -f "$CLAUDE_DIR/.mcp.json" ] && cp "$CLAUDE_DIR/.mcp.json" "$BACKUP_DIR/"
    [ -f "$CLAUDE_DIR/config.json" ] && cp "$CLAUDE_DIR/config.json" "$BACKUP_DIR/"

    print_success "Backup created at $BACKUP_DIR"
fi

# Clone or update the repository
TEMP_DIR="/tmp/claude-code-agents-$(date +%s)"
print_step "Cloning Claude Code Agents repository..."
git clone --quiet "$REPO_URL" "$TEMP_DIR"
print_success "Repository cloned"

# Copy files to Claude directory
print_step "Installing agents..."
cp -r "$TEMP_DIR/agents" "$CLAUDE_DIR/"
print_success "Installed $(ls -1 $TEMP_DIR/agents/*.json | wc -l) agents"

print_step "Installing commands..."
cp -r "$TEMP_DIR/commands" "$CLAUDE_DIR/"
print_success "Installed $(ls -1 $TEMP_DIR/commands/*.md | wc -l) commands"

print_step "Installing configuration files..."
cp "$TEMP_DIR/.mcp.json" "$CLAUDE_DIR/"
[ -f "$TEMP_DIR/config.json" ] && cp "$TEMP_DIR/config.json" "$CLAUDE_DIR/"
[ -f "$TEMP_DIR/README.md" ] && cp "$TEMP_DIR/README.md" "$CLAUDE_DIR/"
print_success "Configuration files installed"

# Clean up temp directory
rm -rf "$TEMP_DIR"

# Check for optional CLI tools
echo ""
print_step "Checking for optional CLI tools..."

check_tool() {
    local tool=$1
    local description=$2
    local install_hint=$3

    if command -v $tool &> /dev/null; then
        print_success "$description detected ($(command -v $tool))"
        return 0
    else
        print_warning "$description not found. Install with: $install_hint"
        return 1
    fi
}

TOOLS_FOUND=0
check_tool "acli" "JIRA CLI (acli)" "npm install -g @atlassian/acli" && ((TOOLS_FOUND++))
check_tool "gh" "GitHub CLI" "brew install gh" && ((TOOLS_FOUND++))
check_tool "az" "Azure DevOps CLI" "brew install azure-cli" && ((TOOLS_FOUND++))
check_tool "glab" "GitLab CLI" "brew install glab" && ((TOOLS_FOUND++))

if [ $TOOLS_FOUND -eq 0 ]; then
    print_warning "No issue tracking CLIs found. Story workflow features will be limited."
    print_warning "Install at least one CLI tool for full functionality."
fi

# Display available agents
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Available Agents:${NC}"
echo ""
for agent in "$CLAUDE_DIR/agents"/*.json; do
    if [ -f "$agent" ]; then
        agent_name=$(basename "$agent" .json | sed 's/-agent$//')
        agent_desc=$(grep -m1 '"description"' "$agent" | sed 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        printf "  ${YELLOW}%-25s${NC} %s\n" "$agent_name" "$agent_desc"
    fi
done

# Display key commands
echo ""
echo -e "${GREEN}Key Commands:${NC}"
echo ""
echo "  ${YELLOW}/work-on-story [ID]${NC}      Complete workflow from ticket to merged PR"
echo "  ${YELLOW}/production-orchestrator${NC}  Full production pipeline with quality gates"
echo "  ${YELLOW}/ddd-orchestrator${NC}         Transform codebase to Domain-Driven Design"
echo "  ${YELLOW}/orchestrator${NC}             Main orchestrator with auto-detection"
echo "  ${YELLOW}/forceTruth${NC}               Verify no placeholder code exists"
echo "  ${YELLOW}/autoFixAll${NC}               Fix all issues without stopping"

# Final instructions
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✨ Installation Complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Open Claude Code"
echo "2. Try: ${YELLOW}/orchestrator${NC} to start with automatic detection"
echo "3. Or: ${YELLOW}/work-on-story STORY-123${NC} to work on a specific story"
echo ""
echo "Documentation: ${BLUE}https://github.com/sean-rowe/claude-code-agents${NC}"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"