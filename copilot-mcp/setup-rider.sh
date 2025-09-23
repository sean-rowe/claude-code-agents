#!/bin/bash

# Claude Code Agents MCP Setup for JetBrains Rider
# This script configures Rider to use Claude Code Agents via MCP

set -e

echo "🤖 Claude Code Agents MCP Setup for JetBrains Rider"
echo "=================================================="

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    OS="windows"
fi

echo "Detected OS: $OS"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Find Rider configuration directory based on OS
find_rider_config() {
    local config_dir=""

    if [[ "$OS" == "macos" ]]; then
        # Try new location first
        if ls ~/.config/JetBrains/Rider* 2>/dev/null | head -n1 > /dev/null; then
            config_dir=$(ls -d ~/.config/JetBrains/Rider* 2>/dev/null | sort -V | tail -n1)
        # Try legacy location
        elif ls ~/Library/Application\ Support/JetBrains/Rider* 2>/dev/null | head -n1 > /dev/null; then
            config_dir=$(ls -d ~/Library/Application\ Support/JetBrains/Rider* 2>/dev/null | sort -V | tail -n1)
        fi
    elif [[ "$OS" == "linux" ]]; then
        if ls ~/.config/JetBrains/Rider* 2>/dev/null | head -n1 > /dev/null; then
            config_dir=$(ls -d ~/.config/JetBrains/Rider* 2>/dev/null | sort -V | tail -n1)
        elif ls ~/.local/share/JetBrains/Rider* 2>/dev/null | head -n1 > /dev/null; then
            config_dir=$(ls -d ~/.local/share/JetBrains/Rider* 2>/dev/null | sort -V | tail -n1)
        fi
    elif [[ "$OS" == "windows" ]]; then
        # Windows paths need special handling
        echo "⚠️  Windows detected. Please manually configure Rider."
        echo "Add configuration to: %APPDATA%\\JetBrains\\Rider*\\copilot-mcp.json"
        return 1
    fi

    if [[ -z "$config_dir" ]]; then
        echo "❌ Could not find Rider configuration directory"
        echo "Please ensure Rider is installed and has been run at least once"
        return 1
    fi

    echo "$config_dir"
}

# Check Node.js installation
check_node() {
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is not installed"
        echo "Please install Node.js 18+ from https://nodejs.org"
        exit 1
    fi

    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ $NODE_VERSION -lt 18 ]]; then
        echo "❌ Node.js version must be 18 or higher (found: v$NODE_VERSION)"
        exit 1
    fi

    echo "✅ Node.js $(node -v) found"
}

# Install dependencies
install_dependencies() {
    echo "📦 Installing dependencies..."
    cd "$SCRIPT_DIR"

    if [[ -f "package.json" ]]; then
        npm install --silent
        echo "✅ Dependencies installed"
    else
        echo "❌ package.json not found in $SCRIPT_DIR"
        exit 1
    fi
}

# Create MCP configuration
create_config() {
    local config_dir="$1"
    local config_file="$config_dir/copilot-mcp.json"

    echo "📝 Creating MCP configuration..."

    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"

    # Get absolute path to index.js
    local index_path="$SCRIPT_DIR/index.js"

    # Create configuration
    cat > "$config_file" << EOF
{
  "mcpServers": {
    "claude-code-agents": {
      "command": "node",
      "args": ["$index_path"],
      "env": {
        "NODE_ENV": "production",
        "MCP_DEBUG": "false"
      }
    }
  }
}
EOF

    echo "✅ Configuration saved to: $config_file"
}

# Main setup
main() {
    echo ""
    echo "🔍 Checking prerequisites..."
    check_node

    echo ""
    echo "🔍 Finding Rider configuration directory..."
    RIDER_CONFIG=$(find_rider_config)

    if [[ $? -ne 0 ]]; then
        echo ""
        echo "📋 Manual Configuration Required"
        echo "================================"
        echo "1. Create copilot-mcp.json in your Rider config directory"
        echo "2. Add this configuration:"
        echo ""
        echo '{'
        echo '  "mcpServers": {'
        echo '    "claude-code-agents": {'
        echo '      "command": "node",'
        echo "      \"args\": [\"$SCRIPT_DIR/index.js\"],"
        echo '      "env": {'
        echo '        "NODE_ENV": "production"'
        echo '      }'
        echo '    }'
        echo '  }'
        echo '}'
        echo ""
        exit 1
    fi

    echo "Found: $RIDER_CONFIG"

    echo ""
    install_dependencies

    echo ""
    create_config "$RIDER_CONFIG"

    # Make index.js executable
    chmod +x "$SCRIPT_DIR/index.js"

    echo ""
    echo "✅ Setup Complete!"
    echo "=================="
    echo ""
    echo "📋 Next Steps:"
    echo "1. Restart JetBrains Rider"
    echo "2. Open GitHub Copilot Chat (Alt+\\)"
    echo "3. Type /mcp. to see available commands"
    echo ""
    echo "Available commands:"
    echo "  /mcp.claude-code-agents.story-worker"
    echo "  /mcp.claude-code-agents.code-fixer"
    echo "  /mcp.claude-code-agents.solid-reviewer"
    echo "  /mcp.claude-code-agents.force-truth"
    echo "  ... and more!"
    echo ""
    echo "📚 See QUICK_REFERENCE.md for all commands"
    echo ""
}

# Run main setup
main