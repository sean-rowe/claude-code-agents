---
description: Automated code review with quality gates
argument-hint: [pull-request] [component]
allowed-tools: Bash, Read, Grep
---

Perform comprehensive code review for: $ARGUMENTS

Review checklist:
1. STATIC ANALYSIS
   - Run linters
   - Check code complexity
   - Identify code smells
   - Find duplicated code

2. STANDARDS CHECK
   - Naming conventions
   - Code formatting
   - Documentation completeness
   - Comment quality

3. TESTING
   - Test coverage > 80%
   - Test quality assessment
   - Mock usage appropriate
   - Edge cases covered

4. SECURITY
   - Input validation
   - SQL injection risks
   - XSS vulnerabilities
   - Hardcoded secrets

5. PERFORMANCE
   - Algorithm efficiency
   - Database query optimization
   - Memory usage
   - Caching opportunities

Quality gates (ALL must pass):
- Zero compilation errors/warnings
- Test coverage > 80%
- No placeholder code
- All tests passing
- No security vulnerabilities

Provide actionable feedback for each issue.