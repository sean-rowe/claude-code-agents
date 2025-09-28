---
description: Generate BDD Gherkin scenarios
argument-hint: <story-id> <feature-name> [scenarios-count]
allowed-tools: Write, Read
---

Generate comprehensive Gherkin scenarios for: $ARGUMENTS

Create feature file with:

1. FEATURE description
2. BACKGROUND (common setup)
3. SCENARIOS including:
   - Happy path flows
   - Error conditions
   - Edge cases
   - Boundary values
   - Security scenarios

Format:
```gherkin
Feature: [Feature Name]
  As a [user type]
  I want [goal]
  So that [business value]

  Background:
    Given [common setup]

  Scenario: [Scenario name]
    Given [context]
    When [action]
    Then [outcome]
    And [additional outcomes]

  Scenario Outline: [Parameterized scenario]
    Given [context with <parameter>]
    When [action with <parameter>]
    Then [outcome with <expected>]

    Examples:
      | parameter | expected |
      | value1    | result1  |
      | value2    | result2  |
```

Requirements:
- Use concrete, realistic data
- No generic "system should work" steps
- All steps must be atomic and testable
- Include data tables where appropriate

Save to features/ directory.