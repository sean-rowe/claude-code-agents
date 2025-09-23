# Claude Code Agents for GitHub Copilot

Professional development agents integrated with GitHub Copilot via MCP (Model Context Protocol).

## Features

Transform your GitHub Copilot into a professional development powerhouse with these specialized agents:

### Core Development Agents

| Agent | Command | Description |
|-------|---------|-------------|
| **Story Worker** | `/mcp.claude-code-agents.story-worker` | Implements complete user stories with strict TDD |
| **Code Fixer** | `/mcp.claude-code-agents.code-fixer` | Fixes ALL issues - types, lint, tests (zero tolerance) |
| **SOLID Reviewer** | `/mcp.claude-code-agents.solid-reviewer` | Enforces SOLID principles and clean architecture |
| **Force Truth** | `/mcp.claude-code-agents.force-truth` | Strict validation - reports TRUTH about code state |

### Architecture Agents

| Agent | Command | Description |
|-------|---------|-------------|
| **BDD Orchestrator** | `/mcp.claude-code-agents.bdd-orchestrator` | Transforms codebase to DDD with BDD |
| **Domain Analyzer** | `/mcp.claude-code-agents.domain-analyzer` | Extracts business domains and ubiquitous language |
| **Architecture Refactor** | `/mcp.claude-code-agents.architecture-refactor` | Refactors to clean architecture patterns |

### Workflow Agents

| Agent | Command | Description |
|-------|---------|-------------|
| **Story Workflow** | `/mcp.claude-code-agents.story-workflow` | Complete workflow from ticket to PR |
| **PR Review** | `/mcp.claude-code-agents.pr-review` | Comprehensive PR review with actionable feedback |
| **Production Orchestrator** | `/mcp.claude-code-agents.production-orchestrator` | Ensures production-quality with CI/CD |

## Installation

### Prerequisites

- GitHub Copilot Business or Enterprise subscription
- VS Code, JetBrains IDE, Visual Studio, or Xcode
- Node.js 18+ (for local MCP server)

### Method 1: Local MCP Server (Recommended)

1. Clone this repository:
```bash
git clone https://github.com/yourusername/claude-code-agents.git
cd claude-code-agents/copilot-mcp
```

2. Install dependencies:
```bash
npm install
```

3. Configure your IDE:

#### VS Code
Copy the `.vscode/mcp.json` to your project:
```bash
cp .vscode/mcp.json /path/to/your/project/.vscode/
```

#### JetBrains IDEs (IntelliJ, WebStorm, etc.)
Add to `.idea/copilot-mcp.xml`:
```xml
<component name="CopilotMCP">
  <mcpServers>
    <server name="claude-code-agents">
      <command>node</command>
      <args>/path/to/claude-code-agents/copilot-mcp/index.js</args>
    </server>
  </mcpServers>
</component>
```

### Method 2: NPX (No Installation)

Add to your project's `.vscode/mcp.json`:
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

### Method 3: Docker

```dockerfile
FROM node:20-slim
WORKDIR /app
COPY copilot-mcp /app
RUN npm install
CMD ["node", "index.js"]
```

Then in `.vscode/mcp.json`:
```json
{
  "mcpServers": {
    "claude-code-agents": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "claude-code-agents-mcp:latest"
      ]
    }
  }
}
```

## Usage Examples

### 1. Implement a User Story with TDD

```
/mcp.claude-code-agents.story-worker story:"As a user, I want to login with OAuth so that I can access my account securely"
```

This will:
1. Extract requirements
2. Generate BDD scenarios
3. Write failing tests (RED)
4. Implement minimal code (GREEN)
5. Refactor (REFACTOR)
6. Ensure SOLID principles
7. Document everything

### 2. Fix All Issues in Codebase

```
/mcp.claude-code-agents.code-fixer scope:all
```

Fixes:
- All TypeScript type errors
- All ESLint violations
- All test failures
- Magic numbers/strings
- TODO comments

### 3. Review Code for SOLID Principles

```
/mcp.claude-code-agents.solid-reviewer target:src/services
```

Will:
- Identify SOLID violations
- Refactor to proper patterns
- Ensure clean architecture
- Maintain test coverage

### 4. Complete Story Workflow

```
/mcp.claude-code-agents.story-workflow ticket_id:JIRA-123 tracker:jira
```

Automates:
1. Fetch story from JIRA
2. Create feature branch
3. Implement with TDD
4. Create pull request
5. Link PR to ticket
6. Update ticket status

### 5. Transform to Domain-Driven Design

```
/mcp.claude-code-agents.bdd-orchestrator domain:"E-commerce Platform"
```

Performs:
1. Domain analysis
2. Create ubiquitous language
3. Define bounded contexts
4. Implement with BDD
5. Full DDD transformation

### 6. Strict Code Validation

```
/mcp.claude-code-agents.force-truth
```

Reports TRUTH about:
- Placeholder code
- TODO comments
- Fake implementations
- Test quality
- Security issues

## Configuration

### Custom Settings

Create `mcp-config.json` in your project root:

```json
{
  "claude-code-agents": {
    "strictMode": true,
    "autoFix": true,
    "testFramework": "jest",
    "linter": "eslint",
    "coverage": {
      "threshold": 90,
      "enforced": true
    },
    "solid": {
      "enforced": true,
      "maxComplexity": 10,
      "maxLineLength": 100
    }
  }
}
```

### Environment Variables

```bash
# Enable debug logging
MCP_DEBUG=true

# Set test framework
TEST_FRAMEWORK=jest

# Set coverage threshold
MIN_COVERAGE=90

# Enable strict mode
STRICT_MODE=true
```

## Agent Capabilities

### Story Worker (TDD Expert)
- Extracts requirements from any story format
- Generates comprehensive BDD scenarios
- Strict RED-GREEN-REFACTOR cycle
- Functions < 20 lines enforced
- Classes < 200 lines enforced
- No 'any' types, console.logs, or TODOs

### Code Fixer (Zero Tolerance)
- Fixes 1400+ issues without stopping
- Never creates type aliases hiding 'any'
- Replaces all magic values
- Creates proper types from usage
- Continues until ALL issues resolved

### SOLID Reviewer
- Single Responsibility enforcement
- Open/Closed principle validation
- Liskov Substitution checking
- Interface Segregation analysis
- Dependency Inversion refactoring
- Cyclomatic complexity < 10

### BDD Orchestrator
- Complete DDD transformation
- Ubiquitous language extraction
- Bounded context mapping
- Entity/Value Object modeling
- Domain event implementation
- Repository pattern application

### Production Orchestrator
- CI/CD pipeline setup
- Security scanning integration
- Performance benchmarking
- GDPR/CCPA compliance
- Observability (logs, metrics, traces)
- Kubernetes deployment configs

### Force Truth
- NO sugar-coating or excuses
- Detects ALL placeholder code
- Finds fake test implementations
- Reports security vulnerabilities
- Shows exact file:line locations
- TRUE state of codebase

## Workflow Integration

### GitHub Actions

```yaml
name: Claude Code Agents Check
on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install -g claude-code-agents-cli
      - run: claude-agents force-truth
      - run: claude-agents code-fixer --scope=all
      - run: claude-agents solid-reviewer --strict
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run force-truth validation
npx claude-code-agents force-truth

# Fix all issues
npx claude-code-agents code-fixer --auto-fix

# Check SOLID principles
npx claude-code-agents solid-reviewer --fail-on-violation
```

## Best Practices

### 1. Start with Story Worker
Always begin features with the story-worker agent to ensure TDD from the start.

### 2. Regular Code Fixing
Run code-fixer after every major change to maintain zero technical debt.

### 3. SOLID Review Before PRs
Always run solid-reviewer before creating pull requests.

### 4. Force Truth in CI/CD
Include force-truth in your CI pipeline to catch placeholder code.

### 5. Domain-First Development
Use domain-analyzer before major features to maintain DDD alignment.

## Troubleshooting

### MCP Server Not Starting

```bash
# Check Node version
node --version  # Should be 18+

# Test MCP server directly
node copilot-mcp/index.js

# Check logs
MCP_DEBUG=true node copilot-mcp/index.js
```

### Agents Not Appearing in Copilot

1. Verify MCP is enabled in your Copilot settings
2. Check `.vscode/mcp.json` is in the correct location
3. Restart your IDE
4. Check Copilot logs: `Copilot: View Logs`

### Permission Issues

```bash
# Make index.js executable
chmod +x copilot-mcp/index.js

# Fix npm permissions
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH
```

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/claude-code-agents/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/claude-code-agents/discussions)
- **Documentation**: [Full Docs](https://docs.claude-code-agents.dev)

## Contributing

We welcome contributions! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

MIT License - See [LICENSE](../LICENSE) for details.

## Acknowledgments

Built on top of:
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io)
- [GitHub Copilot](https://github.com/features/copilot)
- Claude AI by Anthropic

---

**Remember**: These agents have ZERO tolerance for technical debt. They will fix everything, enforce best practices, and report the TRUTH about your code. No excuses. No compromises. Production-quality or nothing.