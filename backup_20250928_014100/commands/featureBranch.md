---
description: Create feature branch with proper naming
argument-hint: <story-id> <feature-name>
allowed-tools: Bash(git checkout:*), Bash(git branch:*), Bash(git push:*)
---

Create feature branch for: $ARGUMENTS

## Current status
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`

Branch naming convention:
- feature/[story-id]-[feature-name]
- Example: feature/PROJ-123-user-authentication

Steps:
1. Ensure working directory is clean
2. Switch to main/master branch
3. Pull latest changes
4. Create feature branch
5. Push to remote with upstream tracking

Set up:
- Branch protection rules
- Link to story/ticket
- Initial commit structure

Validate branch name follows team conventions.