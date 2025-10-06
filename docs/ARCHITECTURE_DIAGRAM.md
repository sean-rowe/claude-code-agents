# Pipeline Architecture Diagram

## High-Level Architecture

```mermaid
graph TB
    User[User] -->|Executes| Pipeline[pipeline.sh]
    Pipeline -->|Reads| Config[Configuration<br/>.pipelinerc<br/>env vars]
    Pipeline -->|Manages| State[State File<br/>.pipeline/state.json]
    Pipeline -->|Creates/Updates| JIRA[JIRA<br/>via acli]
    Pipeline -->|Creates| Git[Git Branches<br/>Commits<br/>PRs]
    Pipeline -->|Generates| Code[Code & Tests]

    style Pipeline fill:#4a9eff
    style State fill:#ffd700
    style JIRA fill:#0052cc
    style Git fill:#f05032
    style Code fill:#28a745
```

## Pipeline Stages Flow

```mermaid
flowchart LR
    Requirements[1. Requirements<br/>Define product needs] -->
    Gherkin[2. Gherkin<br/>Write BDD scenarios] -->
    Stories[3. Stories<br/>Generate user stories] -->
    Work[4. Work<br/>Implement & test] -->
    Complete[5. Complete<br/>Review & merge]

    style Requirements fill:#e1f5fe
    style Gherkin fill:#b3e5fc
    style Stories fill:#81d4fa
    style Work fill:#4fc3f7
    style Complete fill:#29b6f6
```

## Detailed Work Stage Flow

```mermaid
sequenceDiagram
    participant U as User
    participant P as Pipeline
    participant G as Git
    participant C as Code Gen
    participant T as Tests
    participant J as JIRA

    U->>P: pipeline.sh work STORY-1
    P->>G: Detect default branch
    G-->>P: main/master/develop
    P->>G: Checkout default branch
    P->>G: Create feature/STORY-1
    P->>C: Generate test file
    C-->>P: test_story_1.py
    P->>C: Generate implementation
    C-->>P: story_1.py
    P->>T: Run tests
    T-->>P: Pass/Fail
    alt Tests Pass
        P->>G: Commit changes
        P->>G: Push to remote
        P->>J: Update story status
        P->>U: Success
    else Tests Fail
        P->>U: Error + logs
    end
```

## State Management

```mermaid
stateDiagram-v2
    [*] --> Requirements: pipeline.sh requirements
    Requirements --> Gherkin: pipeline.sh gherkin
    Gherkin --> Stories: pipeline.sh stories
    Stories --> Work: pipeline.sh work STORY-ID
    Work --> Work: Next story
    Work --> Complete: All stories done
    Complete --> [*]: Merge & close

    note right of Requirements
        Creates .pipeline/requirements.md
        Initializes state.json
    end note

    note right of Gherkin
        Generates .feature files
        Updates state
    end note

    note right of Stories
        Creates story tasks
        Syncs with JIRA
    end note

    note right of Work
        TDD cycle:
        1. Generate tests
        2. Implement code
        3. Verify tests pass
        4. Commit & push
    end note
```

## Configuration Priority

```mermaid
graph TD
    CLI[Command-Line Flags] -->|Highest| Merge[Final Config]
    Env[Environment Variables] --> Merge
    Project[Project .pipelinerc] --> Merge
    Global[Global ~/.claude/.pipelinerc] --> Merge
    Defaults[Default Values] -->|Lowest| Merge

    Merge --> Pipeline[Pipeline Execution]

    style CLI fill:#ff6b6b
    style Env fill:#ffd93d
    style Project fill:#6bcf7f
    style Global fill:#4d96ff
    style Defaults fill:#95a5a6
    style Merge fill:#e056fd
```

## Language Detection Flow

```mermaid
flowchart TD
    Start[Detect Language] --> CheckGo{go.mod<br/>exists?}
    CheckGo -->|Yes| Go[Language: Go<br/>Tests: *_test.go<br/>Framework: testing]
    CheckGo -->|No| CheckPy{requirements.txt or<br/>pyproject.toml exists?}
    CheckPy -->|Yes| Python[Language: Python<br/>Tests: test_*.py<br/>Framework: pytest]
    CheckPy -->|No| CheckJS{package.json<br/>exists?}
    CheckJS -->|Yes| JS[Language: JavaScript<br/>Tests: *.test.js<br/>Framework: Jest]
    CheckJS -->|No| CheckTS{tsconfig.json<br/>exists?}
    CheckTS -->|Yes| TS[Language: TypeScript<br/>Tests: *.test.ts<br/>Framework: Jest]
    CheckTS -->|No| Bash[Language: Bash<br/>Tests: *_test.sh<br/>Framework: Custom]

    style Go fill:#00add8
    style Python fill:#3776ab
    style JS fill:#f7df1e
    style TS fill:#3178c6
    style Bash fill:#4eaa25
```

## Error Handling Flow

```mermaid
flowchart TD
    Operation[Execute Operation] -->|Success| Log[Log Success]
    Operation -->|Failure| Retry{Retry<br/>Possible?}
    Retry -->|Yes| Count{Attempts <<br/>MAX_RETRIES?}
    Count -->|Yes| Wait[Wait RETRY_DELAY seconds]
    Wait --> Operation
    Count -->|No| LogError[Log Error]
    Retry -->|No| LogError
    LogError --> Backup[Create State Backup]
    Backup --> Report[Report Error to User]

    Log --> Continue[Continue Execution]

    style Operation fill:#3498db
    style Log fill:#2ecc71
    style LogError fill:#e74c3c
    style Backup fill:#f39c12
```

## Git Workflow

```mermaid
gitGraph
    commit id: "Initial commit"
    branch develop
    checkout develop
    commit id: "Setup project"

    branch feature/STORY-1
    checkout feature/STORY-1
    commit id: "Add tests for STORY-1"
    commit id: "Implement STORY-1"

    checkout develop
    merge feature/STORY-1 tag: "PR merged"

    branch feature/STORY-2
    checkout feature/STORY-2
    commit id: "Add tests for STORY-2"
    commit id: "Implement STORY-2"

    checkout develop
    merge feature/STORY-2 tag: "PR merged"

    checkout main
    merge develop tag: "Release v1.0"
```

## File Structure

```
project/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── question.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       └── release.yml
├── .pipeline/
│   ├── state.json           # Current pipeline state
│   ├── requirements.md      # Product requirements
│   ├── features/            # Gherkin .feature files
│   ├── exports/             # JIRA export files
│   ├── backups/             # State backups
│   └── errors.log           # Error logs
├── src/                     # Implementation code
├── tests/                   # Test files
├── pipeline.sh              # Main pipeline script
├── .pipelinerc.example      # Example configuration
├── .pipelinerc              # Project config (gitignored)
└── README.md                # Documentation
```

## Component Interactions

```mermaid
graph TB
    subgraph "External Services"
        JIRA[JIRA API]
        GitHub[GitHub API]
    end

    subgraph "Pipeline Core"
        Main[pipeline.sh]
        Config[Configuration Loader]
        State[State Manager]
        Lock[Lock Manager]
    end

    subgraph "Stage Handlers"
        Req[Requirements Stage]
        Gher[Gherkin Stage]
        Story[Stories Stage]
        Work[Work Stage]
        Comp[Complete Stage]
    end

    subgraph "Utilities"
        Valid[Validation]
        Log[Logging]
        Retry[Retry Logic]
        Backup[Backup Manager]
    end

    Main --> Config
    Main --> State
    Main --> Lock
    Main --> Req
    Main --> Gher
    Main --> Story
    Main --> Work
    Main --> Comp

    Work --> Valid
    Work --> Log
    Work --> Retry
    State --> Backup

    Work --> JIRA
    Work --> GitHub

    style Main fill:#4a9eff
    style JIRA fill:#0052cc
    style GitHub fill:#181717
```

## Data Flow

```mermaid
flowchart LR
    Input[User Input] --> Validate[Validation<br/>& Sanitization]
    Validate --> State[Update State]
    State --> Process[Process Stage]
    Process --> External[External APIs<br/>JIRA/GitHub]
    Process --> Files[Generate Files<br/>Tests/Code]
    External --> StateUpdate[Update State]
    Files --> StateUpdate
    StateUpdate --> Output[User Output]

    style Input fill:#e1f5fe
    style Validate fill:#b3e5fc
    style State fill:#ffd700
    style Process fill:#4fc3f7
    style External fill:#0052cc
    style Files fill:#28a745
```

---

These diagrams illustrate the complete architecture of the Claude Code Agents Pipeline, showing how components interact, data flows, and the execution lifecycle of different stages.
