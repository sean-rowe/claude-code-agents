# Installation Guide

## Quick Install

### Option 1: npm (Recommended)

```bash
npm install -g @claude/pipeline
```

### Option 2: Homebrew (macOS/Linux)

```bash
brew tap anthropics/claude
brew install claude-pipeline
```

### Option 3: Manual Installation

```bash
git clone https://github.com/anthropics/claude-code-agents.git
cd claude-code-agents
chmod +x pipeline.sh
ln -s "$(pwd)/pipeline.sh" /usr/local/bin/claude-pipeline
```

---

## System Requirements

### Required

- **Operating System:** macOS 10.15+ or Linux (Ubuntu 18.04+, Debian 10+, CentOS 7+)
- **Bash:** Version 4.0 or higher
- **Disk Space:** ~50 MB

### Recommended

- **git:** Version 2.0+ (for version control integration)
- **jq:** Version 1.5+ (for JSON state management)
- **Node.js:** Version 14+ (for JavaScript code generation)
- **Python:** Version 3.7+ (for Python code generation)
- **Go:** Version 1.16+ (for Go code generation)

### Optional

- **acli:** For JIRA integration ([Installation guide](https://bobswift.atlassian.net/wiki/spaces/ACLI/overview))

---

## Installation Methods

### npm Installation (Global)

#### Prerequisites
```bash
# Install Node.js if not already installed
# macOS:
brew install node

# Linux (Ubuntu/Debian):
sudo apt-get install nodejs npm

# Linux (CentOS/RHEL):
sudo yum install nodejs npm
```

#### Install
```bash
npm install -g @claude/pipeline
```

#### Verify Installation
```bash
claude-pipeline --version
# Should output: Claude Pipeline v1.0.0
```

#### Usage
```bash
claude-pipeline requirements "Build authentication system"
claude-pipeline gherkin
claude-pipeline stories
```

---

### Homebrew Installation

#### Prerequisites
```bash
# Install Homebrew if not already installed
# macOS/Linux:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Install
```bash
# Add tap (first time only)
brew tap anthropics/claude

# Install formula
brew install claude-pipeline
```

#### Verify Installation
```bash
claude-pipeline --version
```

#### Update
```bash
brew upgrade claude-pipeline
```

---

### Manual Installation

#### Clone Repository
```bash
git clone https://github.com/anthropics/claude-code-agents.git
cd claude-code-agents
```

#### Make Executable
```bash
chmod +x pipeline.sh
chmod +x pipeline-state-manager.sh
```

#### Add to PATH

**Option A: Symlink to /usr/local/bin**
```bash
sudo ln -s "$(pwd)/pipeline.sh" /usr/local/bin/claude-pipeline
```

**Option B: Add to PATH in shell profile**
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/claude-code-agents"
alias claude-pipeline="bash /path/to/claude-code-agents/pipeline.sh"
```

#### Verify Installation
```bash
claude-pipeline --help
```

---

## Post-Installation Setup

### Install Recommended Dependencies

#### macOS
```bash
brew install jq git
```

#### Ubuntu/Debian
```bash
sudo apt-get install jq git
```

#### CentOS/RHEL
```bash
sudo yum install jq git
```

### Configure JIRA Integration (Optional)

If you plan to use JIRA integration:

1. Install acli:
   ```bash
   # Follow instructions at:
   # https://bobswift.atlassian.net/wiki/spaces/ACLI/overview
   ```

2. Configure JIRA credentials:
   ```bash
   acli jira --server https://your-company.atlassian.net --user your-email@company.com --password your-api-token
   ```

---

## Verification

### Run Test Suite
```bash
# If installed via npm
cd $(npm root -g)/@claude/pipeline
bash tests/run_all_tests.sh

# If installed manually
cd /path/to/claude-code-agents
bash tests/run_all_tests.sh
```

### Create Test Project
```bash
mkdir test-pipeline && cd test-pipeline
git init

# Initialize JavaScript project
npm init -y

# Run pipeline
claude-pipeline requirements "Simple calculator with add/subtract"
claude-pipeline gherkin
claude-pipeline --dry-run stories  # Test dry-run mode
```

---

## Updating

### npm
```bash
npm update -g @claude/pipeline
```

### Homebrew
```bash
brew upgrade claude-pipeline
```

### Manual
```bash
cd /path/to/claude-code-agents
git pull origin main
```

---

## Uninstallation

### npm
```bash
npm uninstall -g @claude/pipeline
```

### Homebrew
```bash
brew uninstall claude-pipeline
```

### Manual
```bash
# Remove symlink
sudo rm /usr/local/bin/claude-pipeline

# Remove repository
rm -rf /path/to/claude-code-agents
```

---

## Troubleshooting

### Command Not Found After Installation

**npm installation:**
```bash
# Check npm global bin directory
npm config get prefix

# Add to PATH if needed
export PATH="$PATH:$(npm config get prefix)/bin"
```

**Homebrew installation:**
```bash
# Verify Homebrew bin is in PATH
echo $PATH | grep "/usr/local/bin"

# If not, add to shell profile:
export PATH="/usr/local/bin:$PATH"
```

### Permission Errors

**macOS/Linux:**
```bash
# If you see "Permission denied"
chmod +x $(which claude-pipeline)

# For npm global installs without sudo
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH
```

### Bash Version Too Old

```bash
# Check bash version
bash --version

# Upgrade bash (macOS)
brew install bash

# Upgrade bash (Ubuntu/Debian)
sudo apt-get install --only-upgrade bash

# Upgrade bash (CentOS/RHEL)
sudo yum update bash
```

### Missing Dependencies

```bash
# Check for required commands
command -v bash && echo "✓ bash installed" || echo "✗ bash missing"
command -v git && echo "✓ git installed" || echo "✗ git missing (recommended)"
command -v jq && echo "✓ jq installed" || echo "✗ jq missing (recommended)"
```

---

## Platform-Specific Notes

### macOS

- Bash 3.2 (default on macOS) works but Bash 4.0+ is recommended
- Install newer bash: `brew install bash`
- May need to add `/usr/local/bin/bash` to `/etc/shells`

### Linux

- Most distributions include Bash 4.0+
- Ensure `/usr/local/bin` is in PATH
- SELinux may require: `sudo setenforce 0` (temporary) or proper context

### WSL (Windows Subsystem for Linux)

- Fully supported on WSL2
- Follow Linux installation instructions
- Ensure git is configured with proper line endings:
  ```bash
  git config --global core.autocrlf input
  ```

---

## Next Steps

After installation, see:

- [Quick Start Guide](docs/PIPELINE_QUICK_START.md)
- [README](README.md)
- [Examples](docs/)

For issues or questions:

- GitHub Issues: https://github.com/anthropics/claude-code-agents/issues
- Documentation: https://github.com/anthropics/claude-code-agents/docs

---

**Version:** 1.0.0
**Last Updated:** 2025-10-04
