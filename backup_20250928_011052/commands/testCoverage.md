---
description: Analyze and improve test coverage
argument-hint: [component] [target-percentage]
allowed-tools: Bash, Read, Write, Grep
---

Analyze test coverage for: $ARGUMENTS

Coverage analysis:
1. Run coverage tool for the project
2. Identify untested code paths
3. Find missing edge cases
4. Detect untested error handlers
5. Report coverage metrics

Generate missing tests for:
- Uncovered lines
- Untested branches
- Missing error scenarios
- Boundary conditions
- Integration points

Report format:
- Current coverage: X%
- Target coverage: Y% (default 80%)
- Uncovered files list
- Critical gaps identified
- Generated test suggestions

Create tests to reach target coverage.