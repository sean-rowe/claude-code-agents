# JetBrains Rider Setup for Claude Code Agents MCP

## Installation Methods for Rider

### Method 1: Global User Configuration (Recommended)

1. **Install the MCP server globally:**
```bash
# Clone or navigate to the repository
cd ~/projects/claude-code-agents/copilot-mcp

# Install dependencies
npm install

# Create a global link
npm link

# Or install globally directly
npm install -g .
```

2. **Configure Rider's Copilot settings:**

Go to **Settings/Preferences** → **GitHub Copilot** → **Advanced** → **MCP Servers**

Add this configuration:
```json
{
  "claude-code-agents": {
    "command": "node",
    "args": ["/Users/srowe/projects/claude-code-agents/copilot-mcp/index.js"]
  }
}
```

Or if installed globally:
```json
{
  "claude-code-agents": {
    "command": "claude-code-agents-mcp"
  }
}
```

### Method 2: Project-Specific Configuration

1. **Copy MCP files to your project:**
```bash
# In your project root
cp -r ~/projects/claude-code-agents/copilot-mcp .claude-agents-mcp
cd .claude-agents-mcp
npm install
```

2. **Create `.idea/copilot-mcp.json` in your project:**
```json
{
  "mcpServers": {
    "claude-code-agents": {
      "command": "node",
      "args": ["${PROJECT_DIR}/.claude-agents-mcp/index.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

### Method 3: Using NPX (No Installation)

Create `.idea/copilot-mcp.json` in your project:
```json
{
  "mcpServers": {
    "claude-code-agents": {
      "command": "npx",
      "args": [
        "-y",
        "claude-code-agents-copilot-mcp@latest"
      ]
    }
  }
}
```

## Rider Configuration Files

### Option A: User-Level Configuration
**Location:** `~/.config/JetBrains/Rider2024.3/copilot-mcp.json`

```json
{
  "mcpServers": {
    "claude-code-agents": {
      "command": "node",
      "args": ["/Users/srowe/projects/claude-code-agents/copilot-mcp/index.js"],
      "env": {
        "NODE_ENV": "production",
        "MCP_DEBUG": "false"
      }
    }
  }
}
```

### Option B: Project-Level Configuration
**Location:** `{YourProject}/.idea/copilot-mcp.json`

```json
{
  "mcpServers": {
    "claude-code-agents": {
      "command": "node",
      "args": ["${PROJECT_DIR}/../claude-code-agents/copilot-mcp/index.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

## Quick Setup Script

Save this as `setup-rider.sh`:

```bash
#!/bin/bash

# Claude Code Agents MCP Setup for Rider
echo "Setting up Claude Code Agents for JetBrains Rider..."

# Get Rider config directory
RIDER_VERSION=$(ls ~/.config/JetBrains/ | grep -E "^Rider" | sort -V | tail -n1)
RIDER_CONFIG_DIR="$HOME/.config/JetBrains/$RIDER_VERSION"

# Create config directory if it doesn't exist
mkdir -p "$RIDER_CONFIG_DIR"

# Path to this script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create the MCP configuration
cat > "$RIDER_CONFIG_DIR/copilot-mcp.json" << EOF
{
  "mcpServers": {
    "claude-code-agents": {
      "command": "node",
      "args": ["$SCRIPT_DIR/index.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF

# Install dependencies
echo "Installing dependencies..."
cd "$SCRIPT_DIR"
npm install

echo "✅ Setup complete!"
echo "📍 Configuration saved to: $RIDER_CONFIG_DIR/copilot-mcp.json"
echo "🔄 Please restart Rider for changes to take effect"
```

## Verifying Installation

1. **Restart Rider**

2. **Open GitHub Copilot Chat** (Alt+\)

3. **Type:** `/mcp.` and you should see autocomplete with:
   - `/mcp.claude-code-agents.story-worker`
   - `/mcp.claude-code-agents.code-fixer`
   - `/mcp.claude-code-agents.solid-reviewer`
   - etc.

4. **Test a command:**
```
/mcp.claude-code-agents.force-truth
```

## Troubleshooting Rider

### MCP Commands Not Showing

1. **Check Rider version** (requires 2024.2+):
   - Help → About

2. **Check Copilot is enabled:**
   - Settings → GitHub Copilot → Ensure enabled

3. **Check logs:**
   - Help → Show Log in Finder/Explorer
   - Look for `idea.log`

4. **Verify Node.js path:**
```bash
which node
# Add full path to command in config
```

### Permission Errors on macOS

```bash
# Grant execution permission
chmod +x /Users/srowe/projects/claude-code-agents/copilot-mcp/index.js

# If using macOS Ventura+, may need to allow in Security settings
```

### Configuration Not Loading

1. **Clear Rider caches:**
   - File → Invalidate Caches and Restart

2. **Check JSON syntax:**
```bash
# Validate JSON
python3 -m json.tool < ~/.config/JetBrains/Rider*/copilot-mcp.json
```

## Platform-Specific Paths

### macOS
- User config: `~/.config/JetBrains/Rider{version}/copilot-mcp.json`
- Alternative: `~/Library/Application Support/JetBrains/Rider{version}/copilot-mcp.json`

### Windows
- User config: `%APPDATA%\JetBrains\Rider{version}\copilot-mcp.json`
- Alternative: `%LOCALAPPDATA%\JetBrains\Rider{version}\copilot-mcp.json`

### Linux
- User config: `~/.config/JetBrains/Rider{version}/copilot-mcp.json`
- Alternative: `~/.local/share/JetBrains/Rider{version}/copilot-mcp.json`

## Using Agents in Rider

Once configured, use in Copilot Chat:

```
// Fix all issues in current file
/mcp.claude-code-agents.code-fixer scope:current

// Implement a story
/mcp.claude-code-agents.story-worker story:"Add user authentication"

// Review for SOLID principles
/mcp.claude-code-agents.solid-reviewer target:src/

// Validate code truthfulness
/mcp.claude-code-agents.force-truth
```

## Tips for Rider Users

1. **Use Rider's AI Assistant** alongside Copilot for best results
2. **Configure keyboard shortcuts** in Settings → Keymap
3. **Enable Copilot completions** in editor for inline suggestions
4. **Use split view** to see agent output alongside code

## Need Help?

- Check Rider logs: `Help → Show Log`
- Verify MCP is enabled in your Copilot subscription
- Ensure Node.js 18+ is installed: `node --version`
- Test MCP server directly: `node /path/to/index.js`