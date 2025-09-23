---
description: Validate implementation has no fake code
argument-hint: [component?]
allowed-tools: Grep, Read, Bash
---

Comprehensively validate the implementation of: $ARGUMENTS

Validation checks:
1. Scan for placeholder text (TODO, FIXME, HACK, XXX)
2. Verify all TODOs are resolved
3. Check test coverage
4. Validate error handling
5. Run security scan for hardcoded credentials
6. Ensure no fake test assertions

Search for:
- Empty implementations
- NotImplementedException
- Console.WriteLine/print debugging
- Hardcoded passwords, keys, secrets
- Magic numbers without constants
- Empty catch blocks
- Assert.Pass() or trivial assertions

Report:
- Any issues found with file:line references
- Test coverage percentage
- Security vulnerabilities
- Suggested improvements

IMPORTANT: This validation must be thorough - no fake code is acceptable!