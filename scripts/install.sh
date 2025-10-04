#!/bin/bash
# Installation script for Claude Pipeline

set -e

echo "========================================"
echo "Claude Pipeline - Installation"
echo "========================================"
echo ""

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Linux*)     PLATFORM="linux";;
    Darwin*)    PLATFORM="macos";;
    *)          PLATFORM="unknown";;
esac

if [ "$PLATFORM" = "unknown" ]; then
    echo "Error: Unsupported operating system: $OS"
    echo "Claude Pipeline supports macOS and Linux only."
    exit 1
fi

echo "Platform detected: $PLATFORM"
echo ""

# Check for bash
if ! command -v bash &> /dev/null; then
    echo "Error: bash is required but not found."
    exit 1
fi

BASH_VERSION=$(bash --version | head -n1)
echo "✓ Found bash: $BASH_VERSION"

# Check for git (recommended)
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo "✓ Found git: $GIT_VERSION"
else
    echo "⚠ git not found (recommended for full functionality)"
fi

# Check for jq (recommended)
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version)
    echo "✓ Found jq: $JQ_VERSION"
else
    echo "⚠ jq not found (recommended for state management)"
    echo "  Install: brew install jq (macOS) or apt install jq (Linux)"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  claude-pipeline --help              Show help"
echo "  claude-pipeline requirements \"...\"  Start a new pipeline"
echo ""
echo "For more information, see: docs/PIPELINE_QUICK_START.md"
