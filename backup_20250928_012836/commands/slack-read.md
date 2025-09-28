# Slack Read Command

Reads Slack channel messages to understand project context and history.

## Usage
```
/slack-read [options]
```

Options:
- `/slack-read` - Read recent messages
- `/slack-read PROJ-123` - Get context for specific story
- `/slack-read errors` - Get error reports
- `/slack-read summary` - Generate context summary
- `/slack-read decisions` - Extract decisions made
- `/slack-read actions` - Find action items

## What This Command Does

1. **Reads Message History**
   - Fetches recent channel messages
   - Provides chronological context
   - Shows who said what and when

2. **Extracts Key Information**
   - Decisions made
   - Problems encountered
   - Action items assigned
   - Active stories discussed

3. **Provides Context**
   - What work is in progress
   - What issues exist
   - What was recently completed
   - Who is working on what

## Command Implementation

```javascript
async function slackRead(option) {
  await Task({
    subagent_type: "general-purpose",
    description: "Read Slack",
    prompt: `Use slack-reader agent to:

    ${!option ? `
    1. READ RECENT MESSAGES:
       - Get last 100 messages from project channel
       - Show in chronological order
       - Include timestamps and users
    ` : ''}

    ${option && option.match(/PROJ-/) ? `
    1. GET STORY CONTEXT for ${option}:
       - Search for all mentions of ${option}
       - Extract decisions about this story
       - Find problems discussed
       - Show action items
       - Identify who is involved
    ` : ''}

    ${option === 'errors' ? `
    1. GET ERROR REPORTS:
       - Find all error messages in last 48 hours
       - Group by type (build, test, deploy)
       - Show error patterns
       - Identify recurring issues
    ` : ''}

    ${option === 'summary' ? `
    1. GENERATE CONTEXT SUMMARY:
       - Analyze last 200 messages
       - Extract active stories
       - List recent decisions
       - Show current issues
       - Identify action items
       - Show team activity
    ` : ''}

    ${option === 'decisions' ? `
    1. EXTRACT DECISIONS:
       - Find messages with decision keywords
       - Show what was decided
       - Include who made decision
       - Show when it was made
    ` : ''}

    ${option === 'actions' ? `
    1. FIND ACTION ITEMS:
       - Search for TODOs
       - Find assigned tasks
       - Show who owns what
       - Include deadlines if mentioned
    ` : ''}

    Output the results in a clear, organized format.
    Include timestamps and users for all messages.`
  });
}
```

## Example Outputs

### Recent Messages
```
📖 Last 50 messages from #myproject

[2024-01-15 14:30] @john: Starting work on PROJ-123
[2024-01-15 14:35] @bot: 🚀 Agent Starting: story-implementer
[2024-01-15 14:45] @sarah: Can we use Redis for caching?
[2024-01-15 14:46] @mike: +1 for Redis, it's perfect for this
[2024-01-15 14:47] @john: Agreed, I'll implement with Redis
[2024-01-15 15:20] @bot: ✅ Tests passing, PR #456 created
[2024-01-15 15:22] @sarah: Reviewing PR now
```

### Story Context
```
📋 Context for PROJ-123: User Authentication

First mentioned: 2024-01-15 09:30
Last updated: 2024-01-15 15:45
Participants: @john, @sarah, @mike

=== Decisions ===
- Use Redis for session storage
- Implement JWT tokens
- 2FA optional for now

=== Issues ===
- Memory leak in auth service (fixed)
- Test failures in CI (investigating)

=== Action Items ===
- @john: Fix remaining test
- @sarah: Review PR #456
- @mike: Update documentation
```

### Error Report
```
❌ Error Report (Last 48 hours)

=== Summary ===
Build errors: 3
Test failures: 7
Deploy issues: 1
Crashes: 0

=== Recent Errors ===
[2024-01-15 12:30] Build failed: missing dependency
[2024-01-15 13:15] Test failed: timeout in auth.test.js
[2024-01-15 14:00] Deploy failed: wrong credentials

=== Patterns ===
- Most errors during: 12:00-14:00
- Common cause: dependency issues
- Affected components: auth, database
```

### Context Summary
```
📊 Context Summary for #myproject
Generated: 2024-01-15 16:00

== Active Stories ==
- PROJ-123: Authentication (in progress)
- PROJ-124: Database migration (blocked)
- PROJ-125: API refactor (completed)

== Recent Decisions ==
- Use Redis for caching (approved)
- Migrate to PostgreSQL (decided)
- Implement rate limiting (agreed)

== Current Issues ==
- Test failures in CI
- Memory leak in auth service
- Slow query performance

== Pending Actions ==
- Fix auth tests (@john)
- Review PR #456 (@sarah)
- Deploy to staging (@mike)

== Team Activity ==
- @john: 45 messages (most active)
- @sarah: 23 messages
- @mike: 18 messages
```

## Using Context in Development

Before starting work, always:

```bash
# 1. Read recent context
/slack-read

# 2. Check story-specific context
/slack-read PROJ-123

# 3. Check for recent errors
/slack-read errors

# 4. Get summary if needed
/slack-read summary
```

This ensures you:
- Understand current state
- Know about decisions made
- Avoid repeating errors
- Follow team discussions

## Integration with Agents

All agents should:
1. Read Slack context before starting
2. Use context to inform decisions
3. Avoid issues others encountered
4. Follow decisions already made

## Advanced Searches

You can also search for specific terms:

```bash
# Search for specific text
/slack-search "database migration"

# Find mentions of a user
/slack-search "@john"

# Look for specific errors
/slack-search "TypeError"
```

## Important Notes

✅ **Always check context before starting work**
✅ **Review recent errors to avoid repeating**
✅ **Follow decisions already made**
✅ **Check who is working on what**

## Troubleshooting

**"No messages found"**
- Check channel name in .env
- Verify bot has channel access
- Ensure bot token is valid

**"Authentication failed"**
- Re-run `/slack-setup`
- Check SLACK_BOT_TOKEN in .env
- Verify app permissions

**"Channel not found"**
- Ensure channel exists
- Bot must be invited to channel
- Check SLACK_CHANNEL in .env