---
description: Deep verification including mutation testing
allowed-tools: Bash, Read, Grep, Edit
---

Perform deep verification of code quality:

1. MUTATION TESTING mindset:
   - Could tests pass with wrong implementation?
   - Are assertions actually testing the right things?
   - Would tests catch regressions?

2. CODE COVERAGE analysis:
   - Line coverage
   - Branch coverage
   - Edge cases covered
   - Error paths tested

3. QUALITY checks:
   - Cyclomatic complexity
   - Code duplication
   - Dead code detection
   - Unnecessary dependencies

4. SECURITY audit:
   - Input validation
   - SQL injection risks
   - XSS vulnerabilities
   - Hardcoded secrets

5. PERFORMANCE review:
   - N+1 queries
   - Unnecessary loops
   - Memory leaks
   - Inefficient algorithms

Report all findings with specific file:line references.
Provide actionable fixes for each issue found.