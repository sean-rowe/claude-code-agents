#!/bin/bash
# Uninstallation script for Claude Pipeline

set -e

echo "========================================"
echo "Claude Pipeline - Uninstallation"
echo "========================================"
echo ""

# If installed via npm
if command -v npm &> /dev/null; then
    if npm list -g @claude/pipeline &> /dev/null; then
        echo "Uninstalling npm package..."
        npm uninstall -g @claude/pipeline
        echo "✓ npm package uninstalled"
    fi
fi

# If installed via Homebrew
if command -v brew &> /dev/null; then
    if brew list claude-pipeline &> /dev/null 2>&1; then
        echo "Uninstalling Homebrew formula..."
        brew uninstall claude-pipeline
        echo "✓ Homebrew formula uninstalled"
    fi
fi

echo ""
echo "Uninstallation complete!"
echo ""
echo "To reinstall:"
echo "  npm install -g @claude/pipeline"
echo "  or"
echo "  brew install claude-pipeline"
