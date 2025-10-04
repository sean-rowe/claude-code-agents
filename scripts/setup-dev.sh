#!/bin/bash
#
# Development Environment Setup Script
# Installs pre-commit hooks and validates setup
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Claude Code Agents - Development Setup          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Check Python
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v python3 &>/dev/null; then
  echo -e "${RED}✗ Python 3 not found${NC}"
  echo "  Install: https://www.python.org/downloads/"
  exit 1
fi
echo -e "${GREEN}✓ Python 3 found:${NC} $(python3 --version)"

# Check pip
if ! command -v pip3 &>/dev/null && ! command -v pip &>/dev/null; then
  echo -e "${RED}✗ pip not found${NC}"
  echo "  Install: python3 -m ensurepip --upgrade"
  exit 1
fi
echo -e "${GREEN}✓ pip found${NC}"

# Install pre-commit
echo ""
echo -e "${BLUE}Installing pre-commit...${NC}"

if command -v pipx &>/dev/null; then
  echo "  Using pipx (recommended)"
  pipx install pre-commit
elif command -v brew &>/dev/null; then
  echo "  Using Homebrew"
  brew install pre-commit
else
  echo "  Using pip"
  pip3 install --user pre-commit
fi

# Verify installation
if ! command -v pre-commit &>/dev/null; then
  echo -e "${RED}✗ pre-commit installation failed${NC}"
  echo "  Try: pip3 install --user pre-commit"
  echo "  Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
  exit 1
fi

echo -e "${GREEN}✓ pre-commit installed:${NC} $(pre-commit --version)"

# Install hooks
echo ""
echo -e "${BLUE}Installing git hooks...${NC}"

pre-commit install
pre-commit install --hook-type commit-msg

echo -e "${GREEN}✓ Git hooks installed${NC}"

# Install hook dependencies
echo ""
echo -e "${BLUE}Installing hook dependencies (this may take a minute)...${NC}"

pre-commit install --install-hooks

echo -e "${GREEN}✓ Hook dependencies installed${NC}"

# Run initial validation
echo ""
echo -e "${BLUE}Running initial validation...${NC}"
echo ""

if pre-commit run --all-files; then
  echo ""
  echo -e "${GREEN}✓ All checks passed!${NC}"
else
  echo ""
  echo -e "${YELLOW}⚠ Some checks failed${NC}"
  echo "  This is normal for first run - hooks auto-fixed some issues"
  echo "  Re-run: ${BLUE}pre-commit run --all-files${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Development Setup Complete!                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Read ${BLUE}CONTRIBUTING.md${NC} for guidelines"
echo "  2. Create feature branch: ${BLUE}git checkout -b feature/your-feature${NC}"
echo "  3. Make changes and commit - hooks run automatically"
echo "  4. Manually run hooks: ${BLUE}pre-commit run --all-files${NC}"
echo ""
echo "Quick reference:"
echo "  - Run hooks: ${BLUE}pre-commit run${NC}"
echo "  - Run on all files: ${BLUE}pre-commit run --all-files${NC}"
echo "  - Update hooks: ${BLUE}pre-commit autoupdate${NC}"
echo "  - Skip hooks (emergency): ${BLUE}git commit --no-verify${NC}"
echo ""
echo -e "${GREEN}Happy coding!${NC} 🚀"
echo ""
