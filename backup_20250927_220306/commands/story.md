---
description: Create user story with acceptance criteria
argument-hint: <story-id> <title> [description]
allowed-tools: Write
---

Create a comprehensive user story for: $ARGUMENTS

Generate:
1. USER STORY format:
   As a [type of user]
   I want [goal/desire]
   So that [benefit/value]

2. ACCEPTANCE CRITERIA (Given-When-Then):
   - At least 5 concrete, testable criteria
   - Cover happy path and edge cases
   - Include performance requirements
   - Define error handling expectations

3. TECHNICAL REQUIREMENTS:
   - API endpoints needed
   - Database changes required
   - Security considerations
   - Performance targets

4. TEST SCENARIOS:
   - Positive test cases
   - Negative test cases
   - Boundary conditions
   - Integration points

5. DEFINITION OF DONE:
   - All acceptance criteria met
   - Unit tests written and passing
   - Integration tests complete
   - No placeholder code
   - Documentation updated

Anti-fake checks:
- No 'TODO' or 'TBD' in acceptance criteria
- All scenarios must have concrete examples
- Business rules must be specific and measurable

Create story document in stories/ directory.