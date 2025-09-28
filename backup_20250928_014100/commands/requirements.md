---
description: Extract and validate requirements from Confluence/Jira
argument-hint: <source-url> [story-id]
allowed-tools: WebFetch, Write
---

Extract and validate requirements from: $ARGUMENTS

Process:
1. Fetch requirements from source URL
2. Parse and analyze for completeness
3. Identify gaps and ambiguities
4. Generate missing acceptance criteria
5. Create traceability matrix

Validation:
- All requirements must be testable
- No ambiguous language (e.g., "should", "may", "possibly")
- Complete coverage of functional areas
- Clear success criteria
- Measurable performance targets

Flag issues:
- Ambiguous requirements
- Untestable criteria
- Missing edge cases
- Incomplete specifications

Output:
- Structured requirements document
- Validation report
- Suggested clarifications
- Test scenarios for each requirement