---
description: Pre-push validation checks
allowed-tools: Bash, Grep, Read
---

Run comprehensive pre-push validation:

1. TEST SUITE
   - Run all unit tests
   - Run integration tests
   - Verify test coverage meets threshold

2. CODE QUALITY
   - Check for placeholder code (TODO, FIXME, etc.)
   - Run linters
   - Check for compilation warnings
   - Validate formatting

3. SECURITY SCAN
   - Check for hardcoded credentials
   - Scan for known vulnerabilities
   - Validate input sanitization

4. COMMIT VALIDATION
   - Verify commit messages follow convention
   - Check for large files
   - Validate no sensitive data

5. DOCUMENTATION
   - Ensure README is updated
   - Check API documentation
   - Verify changelog entry

ALL checks must pass before push is allowed.
If any check fails, provide specific fix instructions.