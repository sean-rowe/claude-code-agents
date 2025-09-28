---
description: Synchronize with Jira tickets
argument-hint: <project-key> [story-id]
allowed-tools: WebFetch, Write
---

Sync with Jira for: $ARGUMENTS

Synchronization tasks:

1. FETCH from Jira:
   - Story details
   - Acceptance criteria
   - Comments/updates
   - Attachments
   - Status changes

2. UPDATE local docs:
   - Requirements files
   - Story documentation
   - Test scenarios
   - Progress tracking

3. SYNC progress:
   - Update ticket status
   - Add implementation notes
   - Link commits
   - Update time tracking

4. VALIDATE sync:
   - Ensure consistency
   - Check for conflicts
   - Verify all fields mapped

Generate sync report showing all changes.