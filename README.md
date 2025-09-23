# Claude Code Agents

Production-ready Claude Code agents for Domain-Driven Design (DDD), Behavior-Driven Development (BDD), and complete agile workflow automation.

## 🚀 Features

- **Complete Agile Workflow**: From story retrieval to merged PR
- **Auto-detects Tools**: JIRA (acli), GitHub (gh), Azure DevOps (az)
- **DDD Architecture**: Automatic refactoring to Domain-Driven Design
- **BDD Testing**: Gherkin scenarios with Cucumber/SpecFlow/behave
- **PR Review Automation**: Auto-fixes review comments
- **Production Pipeline**: Security, performance, accessibility checks
- **Truth Verification**: No placeholder code or false completion claims

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/sean-rowe/claude-code-agents.git

# Copy to Claude configuration
cp -r claude-code-agents/* ~/.claude/

# Or use specific components
cp -r claude-code-agents/agents ~/.claude/
cp -r claude-code-agents/commands ~/.claude/
```

## 🤖 Available Agents

### Core Development Agents

| Agent | Description | Key Features |
|-------|-------------|--------------|
| `production-orchestrator` | Complete production pipeline | Sprint management, CI/CD, monitoring |
| `story-workflow` | Story lifecycle management | Auto-detects tracker, creates branches, PRs |
| `pr-review` | PR review automation | Auto-fixes tests, docs, types, errors |
| `code-fixer` | Fix ALL code issues | Handles 1400+ errors without stopping |
| `solid-reviewer` | SOLID principles enforcer | Clean code, <20 line functions |

### DDD/BDD Agents

| Agent | Description | Key Features |
|-------|-------------|--------------|
| `domain-analyzer` | Extract domain models | Creates ubiquitous language |
| `architecture-refactor` | Refactor to DDD | Entities, value objects, repositories |
| `bdd-orchestrator` | BDD transformation | Complete DDD with BDD tests |
| `story-worker` | Story implementation | TDD with acceptance criteria |
| `tdd-agent` | Strict TDD enforcement | Red-Green-Refactor cycle |

## 📝 Key Commands

### `/work-on-story [STORY-ID]`
Complete workflow from ticket to merged PR:
```bash
/work-on-story PROJ-123
```
- Retrieves story from JIRA/GitHub/Azure
- Creates feature branch
- Implements with TDD
- Creates and monitors PR
- Auto-fixes review comments
- Merges when approved

### `/production-orchestrator`
Full production pipeline with all quality gates:
```bash
/production-orchestrator sprint 15
```
- Sprint management
- Security scanning (OWASP)
- Performance testing (k6)
- Accessibility (WCAG 2.1)
- CI/CD pipeline generation
- Observability setup

### `/ddd-orchestrator`
Transform codebase to Domain-Driven Design:
```bash
/ddd-orchestrator
```
- Analyzes domains
- Creates ubiquitous language
- Refactors to DDD architecture
- Implements BDD tests

### `/orchestrator`
Main orchestrator with automatic tool detection:
```bash
/orchestrator
```
- Detects work to be done
- Dispatches appropriate agents
- Ensures quality standards
- Runs `/forceTruth` at end

## 🔧 Tool Detection

Automatically detects and uses:

| Tool | Purpose | Commands Used |
|------|---------|---------------|
| `acli` | JIRA integration | `acli jira issue get/transition/comment` |
| `gh` | GitHub integration | `gh issue/pr create/view/merge` |
| `az` | Azure DevOps | `az boards/repos work-item/pr` |

## 🏗️ Architecture

### Agent Structure
```
agents/
├── production-orchestrator-agent.json
├── story-workflow-agent.json
├── pr-review-agent.json
├── code-fixer-agent.json
├── domain-analyzer-agent.json
├── architecture-refactor-agent.json
└── ...

commands/
├── work-on-story.md
├── production-orchestrator.md
├── ddd-orchestrator.md
├── orchestrator.md
└── ...
```

### Configuration
```json
// .mcp.json - MCP server configuration
{
  "agents": {
    "production-orchestrator": {
      "command": "claude-agent",
      "args": ["--agent", "production-orchestrator"],
      "configPath": "~/.claude/agents/production-orchestrator-agent.json"
    }
    // ...
  }
}
```

## 🎯 Anti-Patterns Prevented

These agents prevent common issues:

- ❌ **No placeholder code**: `// TODO: implement later`
- ❌ **No type cheating**: `type UnknownType = any`
- ❌ **No fake tests**: `expect(true).toBe(true)`
- ❌ **No console.log**: In production code
- ❌ **No magic values**: Numbers/strings without constants
- ❌ **No stopping**: "Too many issues to handle"
- ❌ **No excuses**: "This needs extensive refactoring"

## 📊 Production Quality Gates

Every story must pass:

| Gate | Requirement | Enforced By |
|------|-------------|-------------|
| Tests | >90% coverage | `story-worker` |
| Security | 0 high/critical | `production-orchestrator` |
| Performance | <500ms p95 | `production-orchestrator` |
| Accessibility | WCAG 2.1 AA | `production-orchestrator` |
| Types | 0 errors | `code-fixer` |
| Documentation | 100% public API | `solid-reviewer` |

## 🔄 Workflow Example

```bash
# Start working on a story
/work-on-story PROJ-123

# Output:
📋 Detected JIRA (using acli)
📖 Retrieved story: "Add user authentication"
🌿 Created branch: feature/PROJ-123-add-user-authentication
✅ Updated JIRA to "In Progress"
🧪 Writing BDD tests...
💻 Implementing feature...
✅ All tests passing
🔄 Created PR #456
🔗 Linked PR to JIRA
👀 Monitoring reviews...
🔧 Auto-fixing review comments...
✅ PR approved and merged
✅ JIRA updated to "Done"
```

## 🚦 CI/CD Pipeline Generation

Automatically generates pipelines for:
- GitHub Actions
- GitLab CI
- Jenkins
- Azure Pipelines

Example generated pipeline includes:
- Linting & type checking
- Unit & integration tests
- Security scanning
- Performance testing
- Accessibility testing
- Blue-green deployment
- Automatic rollback

## 📈 Sprint Management

```bash
/production-orchestrator sprint 15

# Provides:
- Story prioritization
- Velocity tracking
- Burndown charts
- Automatic ticket updates
- Sprint reports
```

## 🔒 Security Features

- OWASP dependency scanning
- SQL injection prevention
- XSS protection testing
- Secret scanning
- GDPR/CCPA compliance checks
- Input validation verification

## 📚 Documentation

All agents automatically generate:
- API documentation (OpenAPI/Swagger)
- Architecture diagrams (C4 model)
- Database schemas
- Deployment guides
- Changelog from commits

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your agent/command
4. Test thoroughly
5. Submit a PR

## 📄 License

MIT

## 🙏 Acknowledgments

Built with Claude Code and Anthropic's AI assistance.

---

**Remember**: These agents enforce TRUTH. They will report exactly what was done, not what they claim was done. No placeholder code, no false completions.

🤖 Generated with [Claude Code](https://claude.ai/code)