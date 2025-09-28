# Claude Code Agents

Simplified agent system for Claude Code with linear pipeline execution and state management.

## Quick Start

```bash
# One-command setup
./quickstart.sh

# Check system health
/health

# Start pipeline
/pipeline requirements "Build your feature"
/pipeline gherkin
/pipeline stories
/pipeline work STORY-ID
/pipeline complete STORY-ID
```

## Architecture

### 5 Core Components

1. **Pipeline Controller** - Manages workflow stages with state
2. **Orchestrator** - Routes requests to appropriate agents
3. **Implementer** - Implements stories with TDD
4. **Reviewer** - Reviews code quality
5. **Deployer** - Handles deployment

### Pipeline Stages

```
requirements → gherkin → stories → work → complete
```

Each stage:
- Shows clear progress (STEP: X of Y)
- Maintains state for resume capability
- Fails fast with clear error messages

## Commands

### Pipeline Commands
- `/pipeline requirements "description"` - Generate requirements
- `/pipeline gherkin` - Create BDD scenarios
- `/pipeline stories` - Create JIRA hierarchy
- `/pipeline work STORY-ID` - Implement story
- `/pipeline complete STORY-ID` - Review and merge
- `/pipeline status` - Check current state

### Simple Commands
- `/setup` - Initial project setup
- `/implement STORY-ID` - Direct implementation
- `/review` - Code review
- `/deploy` - Deploy to production

## State Management

Pipeline state is maintained in `pipeline-state.json`:

```json
{
  "stage": "work",
  "step": 4,
  "totalSteps": 7,
  "currentStory": "PROJ-103",
  "nextAction": "Run tests"
}
```

## Features

- ✅ Linear execution (no confusion)
- ✅ State preservation (resume capability)
- ✅ Error recovery (retry/skip/reset)
- ✅ Rich JIRA descriptions (business value, ROI)
- ✅ Complete TDD workflow with validation
- ✅ PR management with templates
- ✅ Clear progress indicators
- ✅ Health check command
- ✅ Quick start script

## Project Structure

```
claude-code-agents/
├── agents/                    # 5 core agents
│   ├── orchestrator.json
│   ├── implementer.json
│   ├── reviewer.json
│   ├── deployer.json
│   └── pipeline-controller.json
├── commands/                  # Simplified commands
│   ├── pipeline.md
│   ├── setup.md
│   ├── implement.md
│   ├── review.md
│   └── deploy.md
├── pipeline-templates/        # Rich templates
│   ├── requirements.md
│   ├── epic-description.md
│   └── story-description.md
├── jira-hierarchy-setup.sh    # JIRA setup script
├── pipeline-state-manager.sh  # State management
├── install.sh                 # Installation script
└── README.md                  # This file
```

## Improvements from Previous System

| Metric | Before | After |
|--------|--------|-------|
| Agents | 20+ | 5 |
| Commands | 58+ | 8 |
| Code Lines | 7,801 | ~500 |
| Complexity | Nested agents | Linear pipeline |
| State | Lost frequently | Always preserved |

## Installation

```bash
git clone https://github.com/sean-rowe/claude-code-agents.git
cd claude-code-agents
./install.sh
```

## Documentation

- Quick Start: `PIPELINE_QUICK_START.md`
- Templates: `pipeline-templates/`

## License

MIT