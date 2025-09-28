# DDD Orchestrator Command

Transforms your codebase to Domain-Driven Design with BDD-driven development.

## Usage
```
/ddd-orchestrator [phase]
```

Options:
- `/ddd-orchestrator` - Full DDD transformation
- `/ddd-orchestrator analyze` - Domain analysis only
- `/ddd-orchestrator feature [NAME]` - Single feature development
- `/ddd-orchestrator bdd-setup` - Install BDD framework

## What This Command Does

Executes a two-phase DDD transformation:

**Phase 1: Discovery and Architectural Blueprint**
1. Analyzes project to detect technology stack (any language)
2. Domain modeling: Extracts entities, value objects, aggregates from documentation
3. Creates ubiquitous language dictionary
4. Designs SOLID-compliant DDD architecture
5. Installs and configures BDD framework

**Phase 2: Iterative DDD-Aligned Feature Development**
For each feature:
1. Writes Gherkin scenarios using ubiquitous language
2. Refactors code segment to DDD structure
3. Creates entities, repositories, and services
4. Writes BDD step definitions
5. Implements domain logic to pass tests
6. Ensures SOLID principles throughout

## Phase 1: Discovery and Architectural Blueprint

### Step 1: Domain Analysis
```javascript
// Dispatch domain-analyzer agent
await Task({
  subagent_type: "general-purpose",
  description: "Analyze domains",
  prompt: `Use domain-analyzer agent configuration from
    ~/.claude/agents/domain-analyzer-agent.json to:
    - Detect technology stack (any language)
    - Analyze .feature, .md, test files
    - Extract domain entities (Student, Caseload, Session, Billing)
    - Create ubiquitous language dictionary
    - Design DDD architecture for the detected language`
});
```

### Step 2: Architectural Blueprint
Produces language-appropriate structure:

#### TypeScript/JavaScript:
```
src/
├── domain/           # Pure business logic
│   ├── student/
│   │   ├── entities/
│   │   ├── value-objects/
│   │   └── repositories/
│   ├── session/
│   └── billing/
├── application/      # Use cases
└── infrastructure/   # External concerns
```

#### Python:
```
src/
├── domain/
│   ├── student/
│   │   ├── entities.py
│   │   ├── value_objects.py
│   │   └── repositories.py
│   └── session/
└── application/
```

#### Java/C#:
```
src/main/java/
└── com/company/
    ├── domain/
    │   └── student/
    ├── application/
    └── infrastructure/
```

### Step 3: BDD Framework Installation
```javascript
// Based on detected language
switch(language) {
  case 'typescript':
  case 'javascript':
    await bash('npm install --save-dev @cucumber/cucumber');
    break;
  case 'python':
    await bash('pip install behave pytest-bdd');
    break;
  case 'java':
    // Add to pom.xml or build.gradle
    break;
  case 'csharp':
    await bash('dotnet add package SpecFlow');
    break;
  case 'go':
    await bash('go get github.com/cucumber/godog');
    break;
}
```

## Phase 2: Iterative DDD Feature Development

### For Each Feature Loop:
```javascript
for (const feature of domainModel.features) {
  // 1. Write Gherkin in ubiquitous language
  const gherkin = `
    Feature: ${feature.name}
      As a ${feature.actor}
      I want ${feature.goal}
      So that ${feature.benefit}

    Scenario: ${feature.mainScenario}
      Given ${feature.preconditions}
      When ${feature.action}
      Then ${feature.expectedOutcome}
  `;

  // 2. Architectural refactoring
  await Task({
    subagent_type: "general-purpose",
    description: "Refactor to DDD",
    prompt: `Use architecture-refactor agent from
      ~/.claude/agents/architecture-refactor-agent.json to:
      - Create entities with invariants
      - Extract value objects (immutable)
      - Define repository interfaces
      - Create domain services
      - Apply all SOLID principles
      - Maintain language-specific patterns`
  });

  // 3. BDD step definitions
  await writeStepDefinitions(feature, domainModel.language);

  // 4. Test execution (Red-Green-Refactor)
  await runBDDTests(); // Must fail first
  await implementDomainLogic(); // Make pass
  await refactorForCleanCode(); // Improve

  // 5. Validate and commit
  await Task({
    subagent_type: "general-purpose",
    description: "Validate SOLID",
    prompt: `Use solid-reviewer agent to ensure:
      - Single Responsibility
      - Open/Closed
      - Liskov Substitution
      - Interface Segregation
      - Dependency Inversion`
  });

  await commitFeature(feature);
}
```

## Example Domain Entity (Multi-Language)

### TypeScript:
```typescript
export class Session extends Entity<SessionId> {
  private constructor(
    id: SessionId,
    private studentId: StudentId,
    private therapistId: TherapistId,
    private scheduledAt: DateTime,
    private duration: Duration,
    private status: SessionStatus
  ) {
    super(id);
    this.validateInvariants();
  }

  static schedule(props: ScheduleSessionProps): Result<Session> {
    // Factory method with validation
    const session = new Session(...);
    session.addDomainEvent(new SessionScheduledEvent(session));
    return Result.ok(session);
  }

  complete(notes: string): Result<void> {
    if (!this.canComplete()) {
      return Result.fail('Session cannot be completed');
    }
    this.status = SessionStatus.Completed;
    this.addDomainEvent(new SessionCompletedEvent(this, notes));
    return Result.ok();
  }

  private validateInvariants(): void {
    if (this.duration.minutes < 15) {
      throw new DomainError('Session must be at least 15 minutes');
    }
  }
}
```

### Python:
```python
class Session(Entity):
    def __init__(self, session_id: SessionId, student_id: StudentId,
                 therapist_id: TherapistId, scheduled_at: DateTime,
                 duration: Duration, status: SessionStatus):
        super().__init__(session_id)
        self._student_id = student_id
        self._therapist_id = therapist_id
        self._scheduled_at = scheduled_at
        self._duration = duration
        self._status = status
        self._validate_invariants()

    @classmethod
    def schedule(cls, **props) -> 'Session':
        session = cls(...)
        session.add_domain_event(SessionScheduledEvent(session))
        return session

    def complete(self, notes: str) -> None:
        if not self._can_complete():
            raise DomainError('Session cannot be completed')
        self._status = SessionStatus.COMPLETED
        self.add_domain_event(SessionCompletedEvent(self, notes))

    def _validate_invariants(self) -> None:
        if self._duration.minutes < 15:
            raise DomainError('Session must be at least 15 minutes')
```

## Agent Coordination

| Agent | Purpose | When Used |
|-------|---------|-----------|
| `domain-analyzer` | Extract domains & ubiquitous language | Phase 1 start |
| `architecture-refactor` | Transform to DDD structure | Each feature |
| `story-worker` | Implement BDD scenarios | Feature development |
| `solid-reviewer` | Ensure SOLID compliance | After each refactoring |
| `code-fixer` | Fix any issues found | As needed |

## Complete Orchestration Flow

```javascript
async function orchestrateDDD() {
  // PHASE 1: Discovery
  const domainModel = await Task({
    subagent_type: "general-purpose",
    description: "Complete domain analysis",
    prompt: `Use domain-analyzer agent to:
      1. Detect language and stack
      2. Extract all domains
      3. Create ubiquitous language
      4. Generate architectural blueprint`
  });

  // Install BDD framework for detected language
  await installBDDFramework(domainModel.language);

  // Create domain directories
  await createDDDStructure(domainModel);

  // PHASE 2: Feature-by-feature development
  for (const boundedContext of domainModel.boundedContexts) {
    for (const feature of boundedContext.features) {
      // Write Gherkin
      await createGherkinScenarios(feature, domainModel.ubiquitousLanguage);

      // Refactor to DDD
      await Task({
        subagent_type: "general-purpose",
        description: `Refactor ${feature.name} to DDD`,
        prompt: `Use architecture-refactor agent for ${boundedContext.name}`
      });

      // Implement with BDD
      await Task({
        subagent_type: "general-purpose",
        description: "BDD implementation",
        prompt: `Implement ${feature.name} following TDD cycle`
      });

      // Validate
      await validateDomainIntegrity(boundedContext);
      await ensureSOLIDPrinciples(feature);

      // Commit
      await commitProgress(feature);
    }
  }

  // PHASE 3: Final Truth Verification
  await executeForceTruth();

  return generateReport(domainModel);
}
```

## Deliverables

1. **Domain Model Document**
   ```json
   {
     "entities": ["Student", "Session", "Invoice"],
     "valueObjects": ["Email", "Money", "Duration"],
     "aggregates": ["Caseload", "BillingCycle"],
     "events": ["SessionCompleted", "InvoiceGenerated"],
     "boundedContexts": ["StudentManagement", "Scheduling", "Billing"]
   }
   ```

2. **Ubiquitous Language Dictionary**
   ```json
   {
     "Session": "A scheduled therapy meeting between therapist and student",
     "Caseload": "Collection of students assigned to a therapist",
     "Billing": "Process of generating invoices for completed sessions"
   }
   ```

3. **DDD Architecture**
   - Clean, layered structure
   - SOLID-compliant classes
   - Rich domain models
   - Clear separation of concerns

4. **BDD Test Suite**
   - Gherkin scenarios for all features
   - Step definitions using domain code
   - 100% feature coverage

## Success Criteria

- ✅ All business logic in domain layer
- ✅ No anemic domain models
- ✅ All entities have invariants
- ✅ Value objects are immutable
- ✅ Repository interfaces defined
- ✅ SOLID principles throughout
- ✅ BDD tests for all features
- ✅ Ubiquitous language used consistently
- ✅ Clear bounded contexts
- ✅ Domain events for important state changes

## Final Truth Verification

As the LAST step, the orchestrator executes `/forceTruth` which:
- Enables strict mode
- Verifies NO placeholder code exists
- Confirms NO TODO comments remain
- Validates NO fake implementations
- Ensures all code is REAL and WORKING
- Reports any issues found truthfully

If ANY placeholder code is detected:
- The orchestrator will report it
- It will NOT claim success falsely
- It will list exactly what needs fixing

This ensures you get the TRUTH about the codebase state!

This creates a professional-grade, maintainable, domain-driven codebase!