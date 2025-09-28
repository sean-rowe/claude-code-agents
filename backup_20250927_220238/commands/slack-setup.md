# Slack Setup Command

MANDATORY Slack integration setup for real-time notifications from all agents.

## Usage
```
/slack-setup
```

This command MUST be run along with `/jira-setup` for complete integration!

## What This Command Does

1. **Installs Slack CLI**
   - Downloads and installs Slack CLI
   - Authenticates with workspace
   - Configures permissions

2. **Creates Project Channel**
   - Auto-creates channel based on repo name
   - Sets channel description
   - Invites team members

3. **Configures Webhooks**
   - Creates incoming webhook
   - Sets up bot token
   - Saves to .env file

4. **Tests Integration**
   - Sends test message
   - Verifies read access
   - Confirms notifications work

## Why This is MANDATORY

**ALL agents MUST send Slack notifications:**
- 🚀 When starting any task
- ✅ When completing any task
- ❌ When encountering errors
- 🤝 When returning control to user
- 📋 When updating JIRA
- 🔄 When creating PRs
- 🧪 When running tests
- 📊 With daily summaries

**Without Slack setup:**
- ❌ No real-time updates
- ❌ No error alerts
- ❌ No completion notifications
- ❌ No team visibility
- ❌ No audit trail

## Command Implementation

```javascript
async function slackSetup() {
  await Task({
    subagent_type: "general-purpose",
    description: "Slack setup",
    prompt: `Use slack-notifier agent to:

    THIS IS MANDATORY - ALL AGENTS MUST USE SLACK!

    1. INSTALL SLACK CLI:
       - Check if Slack CLI exists
       - Install if missing
       - Authenticate with workspace

    2. CREATE PROJECT CHANNEL:
       - Get repo name from git
       - Create channel #<repo-name>
       - Set channel topic and description

    3. CONFIGURE WEBHOOK:
       - Create incoming webhook
       - Get bot token for reading
       - Save both to .env

    4. UPDATE .env:
       - Add SLACK_WEBHOOK_URL
       - Add SLACK_BOT_TOKEN
       - Add SLACK_CHANNEL
       - Add SLACK_CHANNEL_ID
       - Set SLACK_NOTIFICATIONS_ENABLED=true

    5. TEST INTEGRATION:
       - Send test notification
       - Read back the message
       - Confirm both work

    6. ENFORCE IN ALL AGENTS:
       - All agents MUST call slackNotify()
       - All handoffs MUST notify
       - All errors MUST alert

    Output should show:
    - Channel created: #<channel-name>
    - Webhook configured
    - Test message sent
    - Integration verified`
  });
}
```

## Manual Setup Steps

If automatic setup fails:

### 1. Create Slack App

Go to https://api.slack.com/apps and create new app:

1. **Basic Information**
   - App Name: `<repo-name>-bot`
   - Workspace: Select your workspace

2. **OAuth & Permissions**
   - Bot Token Scopes:
     - `chat:write`
     - `channels:history`
     - `channels:read`
     - `channels:write`
   - Install to Workspace
   - Copy Bot User OAuth Token

3. **Incoming Webhooks**
   - Activate Incoming Webhooks
   - Add New Webhook to Workspace
   - Select or create channel
   - Copy Webhook URL

### 2. Update .env File

Add these lines to your .env:

```bash
# Slack Configuration (MANDATORY)
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/T00/B00/XXX"
SLACK_BOT_TOKEN="xoxb-your-token"
SLACK_CHANNEL="#project-name"
SLACK_CHANNEL_ID="C1234567890"
SLACK_NOTIFICATIONS_ENABLED=true
SLACK_NOTIFICATION_LEVEL=all
```

### 3. Install Slack CLI

```bash
# macOS/Linux
curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash

# Authenticate
slack login
```

## Notification Format

All agents send structured notifications:

```
🚀 Agent Starting
Agent: story-implementer
Task: Implementing PROJ-123
Started: 14:30:25

✅ Agent Complete
Agent: story-implementer
Duration: 5m 32s
Summary:
- Created feature branch
- Implemented functionality
- All tests passing
- PR #456 created

🤝 CONTROL RETURNED TO USER
Agent: code-reviewer
Reason: Review comments need manual decision
Completed:
- Reviewed 15 files
- Found 3 issues
Remaining:
- Address review feedback
- Re-run tests
```

## Integration with JIRA

When both Slack and JIRA are configured:
- Story updates post to Slack
- PR creation notifies channel
- Test results auto-post
- Errors alert immediately

## Testing the Setup

After running `/slack-setup`, test with:

```bash
# Send test notification
curl -X POST $SLACK_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d '{"text":"✅ Slack integration working!"}'

# Read messages
/slack-read

# Check specific story context
/slack-read PROJ-123
```

## Slack Commands Available

After setup, use these commands:

- `/slack-setup` - Initial configuration
- `/slack-read` - Read channel messages
- `/slack-read [STORY-ID]` - Get story context
- `/slack-summary` - Daily summary
- `/slack-errors` - Recent error reports

## Important Notes

⚠️ **Every agent MUST send notifications**
⚠️ **No work without Slack updates**
⚠️ **All errors MUST alert immediately**
⚠️ **Handoffs MUST notify user**

## Next Steps

1. Run `/jira-setup` if not done
2. Run `/slack-setup` to configure
3. Test with `/slack-read`
4. All agents now send updates!

Your entire team will have real-time visibility into:
- What agents are doing
- When tasks complete
- What errors occur
- When manual intervention is needed