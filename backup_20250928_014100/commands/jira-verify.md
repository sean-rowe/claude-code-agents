---
name: jira-verify
description: Systematically verify ALL Gherkin features are properly mapped to JIRA stories
type: agent
agent_name: jira-verify
---

# /jira-verify

SYSTEMATICALLY verifies that EVERY Gherkin feature, rule, and scenario has a corresponding JIRA item. NO SHORTCUTS.

## What It Does

1. **Complete Inventory**: Parses EVERY .feature file
2. **Systematic Check**: Verifies EACH expected item exists
3. **Detailed Reporting**: Creates comprehensive report of findings
4. **No Assumptions**: Checks everything explicitly

## Verification Process

1. Build complete inventory of Gherkin features
2. Get complete inventory from JIRA
3. Compare SYSTEMATICALLY - no fuzzy matching
4. Report EVERY discrepancy
5. Generate detailed markdown report

## What It Verifies

- ✅ Every Feature has a Story
- ✅ Every Scenario has a Subtask
- ✅ Every Rule is in acceptance criteria
- ✅ Parent-child relationships correct
- ✅ No orphaned items
- ✅ No duplicates

## Usage

```
/jira-verify
```

## Output

Creates `jira-verification-report.md` with:
- Summary table of expected vs actual
- List of all missing stories
- List of all missing subtasks
- List of missing rules in descriptions
- Recommended actions to fix

## Example Output

```
📊 GHERKIN INVENTORY COMPLETE
Total Features expected: 2
Total Rules expected: 3
Total Scenarios expected: 5

📊 JIRA INVENTORY
Stories in JIRA: 2
Subtasks in JIRA: 3

⚠️ VERIFICATION FOUND ISSUES
Missing subtasks: 2

Recommended actions:
1. Review the report: jira-verification-report.md
2. Run /jira-fix to fix structural issues
3. Run /jira-setup to create missing items
4. Run /jira-verify again to confirm
```

## When to Use

- After running /jira-setup to ensure completeness
- Before sprint planning to verify all scenarios tracked
- After modifying Gherkin files
- To audit JIRA-Gherkin alignment

## Guarantees

- Will find EVERY missing story
- Will find EVERY missing subtask
- Will find EVERY missing rule
- NO assumptions or guessing
- Complete transparency in reporting