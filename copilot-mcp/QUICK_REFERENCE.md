# GitHub Copilot Agent Commands - Quick Reference

## Essential Commands

### 🔨 Development
```
/mcp.claude-code-agents.story-worker story:"User login feature"
/mcp.claude-code-agents.code-fixer scope:all
/mcp.claude-code-agents.solid-reviewer target:src/
```

### 🎯 Workflow
```
/mcp.claude-code-agents.story-workflow ticket_id:JIRA-123
/mcp.claude-code-agents.pr-review pr_url:github.com/org/repo/pull/42
```

### 🏗️ Architecture
```
/mcp.claude-code-agents.bdd-orchestrator domain:"E-commerce"
/mcp.claude-code-agents.domain-analyzer focus_area:payments
/mcp.claude-code-agents.architecture-refactor pattern:hexagonal module:auth
```

### ✅ Validation
```
/mcp.claude-code-agents.force-truth
/mcp.claude-code-agents.production-orchestrator environment:staging
```

## Command Parameters

### story-worker
- `story` (required): User story or requirement

### code-fixer
- `scope`: all | types | lint | tests | {file_path}

### solid-reviewer
- `target`: File or directory path

### story-workflow
- `ticket_id` (required): JIRA-123, #456, etc.
- `tracker`: jira | github | azure

### pr-review
- `pr_url`: Pull request URL or number

### bdd-orchestrator
- `domain` (required): Business domain name

### domain-analyzer
- `focus_area`: Specific area to analyze

### architecture-refactor
- `pattern`: ddd | hexagonal | clean | onion
- `module`: Specific module to refactor

### production-orchestrator
- `environment`: development | staging | production

### force-truth
- No parameters (runs strict validation)

## Common Workflows

### New Feature (TDD)
```bash
1. /mcp.claude-code-agents.story-worker story:"Feature description"
2. /mcp.claude-code-agents.code-fixer scope:all
3. /mcp.claude-code-agents.solid-reviewer target:src/
4. /mcp.claude-code-agents.force-truth
```

### Fix Technical Debt
```bash
1. /mcp.claude-code-agents.code-fixer scope:all
2. /mcp.claude-code-agents.solid-reviewer target:.
3. /mcp.claude-code-agents.force-truth
```

### Domain Refactoring
```bash
1. /mcp.claude-code-agents.domain-analyzer
2. /mcp.claude-code-agents.bdd-orchestrator domain:"Your Domain"
3. /mcp.claude-code-agents.architecture-refactor pattern:ddd
```

### Complete Story Cycle
```bash
1. /mcp.claude-code-agents.story-workflow ticket_id:JIRA-123
2. (Auto: branch, implement, test, PR)
3. /mcp.claude-code-agents.pr-review
```

### Production Readiness
```bash
1. /mcp.claude-code-agents.production-orchestrator
2. /mcp.claude-code-agents.force-truth
```

## Keyboard Shortcuts (VS Code)

Add to `keybindings.json`:
```json
[
  {
    "key": "ctrl+shift+t",
    "command": "github.copilot.chat.open",
    "args": "/mcp.claude-code-agents.story-worker"
  },
  {
    "key": "ctrl+shift+f",
    "command": "github.copilot.chat.open",
    "args": "/mcp.claude-code-agents.code-fixer scope:all"
  },
  {
    "key": "ctrl+shift+s",
    "command": "github.copilot.chat.open",
    "args": "/mcp.claude-code-agents.solid-reviewer"
  },
  {
    "key": "ctrl+shift+v",
    "command": "github.copilot.chat.open",
    "args": "/mcp.claude-code-agents.force-truth"
  }
]
```

## Tips

1. **Always start with story-worker** for new features
2. **Run code-fixer regularly** to maintain zero debt
3. **Use force-truth before commits** to catch issues
4. **Chain agents** for complete workflows
5. **Set strict mode** for production code

## Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| MCP-001 | Server not running | Check Node.js installation |
| MCP-002 | Agent not found | Update MCP configuration |
| MCP-003 | Invalid parameters | Check command syntax |
| MCP-004 | Timeout | Increase timeout in config |
| MCP-005 | Permission denied | Check file permissions |

## Get Help

- Type `/mcp.claude-code-agents.` and wait for autocomplete
- Check agent descriptions in Copilot chat
- View logs: `Copilot: View Logs` in command palette