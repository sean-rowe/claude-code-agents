# JIRA Setup Command

MANDATORY setup command that creates JIRA project and configures .env file for all agents.

## Usage
```
/jira-setup
```

This command MUST be run before any development work begins!

## What This Command Does

1. **Installs Required Tools**
   - ACLI (JIRA CLI) if not installed
   - GitHub CLI if not installed
   - Configures both tools

2. **Creates JIRA Project**
   - Detects repository name
   - Creates project with appropriate key
   - Sets up project structure

3. **Configures .env File**
   - Creates .env with JIRA_PROJECT_KEY
   - Adds JIRA connection details
   - Adds GitHub repository info
   - Updates .gitignore

4. **Links JIRA and GitHub**
   - Ensures both are connected
   - Sets up integration

## Why This is MANDATORY

**ALL agents require JIRA to work properly:**
- `story-creator` - Creates stories in JIRA
- `story-implementer` - Updates JIRA during development
- `bdd-manager` - Links tests to JIRA stories
- `production-orchestrator` - Tracks sprint progress
- `code-reviewer` - Updates review status in JIRA

**Without JIRA setup:**
- ❌ No story tracking
- ❌ No progress updates
- ❌ No sprint management
- ❌ No traceability
- ❌ No audit trail

## Command Implementation

```javascript
async function jiraSetup() {
  await Task({
    subagent_type: "general-purpose",
    description: "JIRA setup",
    prompt: `Use jira-setup agent to:

    THIS IS MANDATORY - DO NOT SKIP ANY STEPS!

    1. INSTALL TOOLS:
       - Check for ACLI, install if missing
       - Check for gh CLI, install if missing
       - Configure both tools

    2. CHECK OR CREATE .env:
       - Look for existing .env file
       - Check for JIRA_PROJECT_KEY
       - If missing, continue to step 3

    3. CREATE JIRA PROJECT:
       - Get repository name from git or directory
       - Generate project key (uppercase, alphanumeric)
       - Create project in JIRA
       - Create initial epics and components

    4. UPDATE .env FILE:
       - Add JIRA_PROJECT_KEY
       - Add JIRA_PROJECT_ID
       - Add JIRA_URL
       - Add GitHub repository info
       - Update .gitignore to exclude .env

    5. VERIFY GITHUB:
       - Check if repository exists
       - Create if missing
       - Add remote origin

    6. LINK JIRA AND GITHUB:
       - Update JIRA project with GitHub URL
       - Configure automation rules

    7. FINAL VERIFICATION:
       - Test JIRA connection
       - Test GitHub connection
       - Verify .env is complete
       - Show success message

    Output should show:
    - JIRA Project Key
    - JIRA URL
    - GitHub repository URL
    - Confirmation that setup is complete`
  });
}
```

## .env File Format

After running `/jira-setup`, your .env will contain:

```bash
# JIRA Configuration (MANDATORY - DO NOT REMOVE)
JIRA_PROJECT_KEY="MYAPP"
JIRA_PROJECT_ID="10234"
JIRA_URL="https://yourcompany.atlassian.net"
JIRA_USER="user@company.com"

# GitHub Configuration
GITHUB_REPO="https://github.com/username/myapp.git"
GITHUB_OWNER="username"
GITHUB_REPO_NAME="myapp"
```

## Manual Setup (If Needed)

If the command fails, manually:

1. **Install ACLI**
```bash
npm install -g @atlassian/acli
acli configure
# Enter JIRA URL, email, and API token
```

2. **Install GitHub CLI**
```bash
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Authenticate
gh auth login
```

3. **Create .env manually**
```bash
echo 'JIRA_PROJECT_KEY="PROJ"' >> .env
echo 'JIRA_URL="https://company.atlassian.net"' >> .env
echo ".env" >> .gitignore
```

## Verification

After setup, verify with:

```bash
# Check JIRA
acli jira project view $(grep JIRA_PROJECT_KEY .env | cut -d'"' -f2)

# Check GitHub
gh repo view

# Check .env
cat .env | grep JIRA_PROJECT_KEY
```

## Project Structure Created

The command creates this structure in JIRA:

```
Project: MYAPP
├── Components/
│   ├── Backend
│   ├── Frontend
│   ├── Database
│   ├── DevOps
│   ├── Testing
│   └── Documentation
└── Epics/
    ├── Initial Setup
    ├── Core Features
    ├── Testing
    ├── Documentation
    └── DevOps
```

## Next Steps

After successful setup:

1. `/bdd-setup` - Set up BDD framework
2. `/story-breakdown` - Create stories from Gherkin
3. `/dev-review-loop PROJ-1` - Start development

## Troubleshooting

**"ACLI not found"**
- Run: `npm install -g @atlassian/acli`

**"Cannot connect to JIRA"**
- Run: `acli configure`
- Get API token from: https://id.atlassian.com/manage/api-tokens

**"GitHub not authenticated"**
- Run: `gh auth login`

**"Project already exists"**
- Check existing project: `acli jira project list`
- Use existing key in .env

## Important Notes

⚠️ **This setup is MANDATORY**
⚠️ **All other agents will fail without it**
⚠️ **Run this FIRST in any new project**
⚠️ **Keep .env in .gitignore for security**