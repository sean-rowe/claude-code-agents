#!/bin/bash

# Claude Code Agents Quick Start
# Gets you up and running in seconds

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Claude Code Agents Quick Start${NC}"
echo "==================================="
echo ""

# Step 1: Check installation
echo -e "${GREEN}[1/4] Checking installation...${NC}"
if [ -d "$HOME/.claude/agents" ] && [ -d "$HOME/.claude/commands" ]; then
    echo "✓ Agents installed"
else
    echo "Installing agents..."
    ./install.sh
fi

# Step 2: Initialize state
echo -e "${GREEN}[2/4] Initializing pipeline state...${NC}"
if [ -f pipeline-state.json ]; then
    echo "✓ State already exists"
else
    ./pipeline-state-manager.sh init
    echo "✓ State initialized"
fi

# Step 3: Detect project type
echo -e "${GREEN}[3/4] Detecting project type...${NC}"
if [ -f package.json ]; then
    echo "✓ Node.js project detected"
    PROJECT_TYPE="node"
elif [ -f go.mod ]; then
    echo "✓ Go project detected"
    PROJECT_TYPE="go"
elif [ -f requirements.txt ] || [ -f pyproject.toml ]; then
    echo "✓ Python project detected"
    PROJECT_TYPE="python"
elif [ -f Makefile ]; then
    echo "✓ Makefile project detected"
    PROJECT_TYPE="make"
else
    echo "✓ Generic project"
    PROJECT_TYPE="generic"
fi

# Step 4: Setup tracking
echo -e "${GREEN}[4/4] Setting up project tracking...${NC}"
if [ -f .env ] && grep -q "PROJECT_KEY" .env; then
    source .env
    echo "✓ Project already configured: $PROJECT_KEY"
else
    PROJECT_KEY=$(basename "$PWD" | tr '[:lower:]' '[:upper:]' | tr -cd '[:alnum:]' | cut -c1-10)
    echo "PROJECT_KEY=$PROJECT_KEY" > .env
    echo "✓ Project configured: $PROJECT_KEY"
fi

# Check for tracking tools
if command -v acli &>/dev/null; then
    echo "✓ Using JIRA for tracking"
    TRACKER="jira"
elif command -v gh &>/dev/null; then
    echo "✓ Using GitHub Issues for tracking"
    TRACKER="github"
else
    echo "✓ Using manual tracking"
    TRACKER="manual"
fi

# Summary
echo ""
echo -e "${BLUE}==================================="
echo "✨ Quick Start Complete!"
echo "===================================${NC}"
echo ""
echo "Project: $PROJECT_KEY"
echo "Type: $PROJECT_TYPE"
echo "Tracker: $TRACKER"
echo ""
echo -e "${YELLOW}Ready to start! Try these commands:${NC}"
echo ""
echo "  /health                          # Check system health"
echo "  /pipeline requirements \"Feature\" # Start new feature"
echo "  /pipeline status                 # Check current state"
echo "  /implement STORY-1               # Implement a story"
echo ""
echo "For JIRA projects, first run:"
echo "  ./jira-hierarchy-setup.sh $PROJECT_KEY \"$PROJECT_KEY Project\""
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"