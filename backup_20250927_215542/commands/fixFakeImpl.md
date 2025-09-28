---
description: Fix all fake implementations
allowed-tools: Grep, Read, Edit, MultiEdit
---

Find and fix ALL fake implementations:

1. SEARCH for fake patterns:
   - NotImplementedException
   - Empty method bodies
   - Return null/default
   - Pass-through methods
   - Stub implementations
   - Comments with "just" or "for now"

2. IDENTIFY real behavior:
   - What should method do?
   - What are the requirements?
   - What tests expect?
   - What documentation says?

3. IMPLEMENT properly:
   - Full business logic
   - Error handling
   - Validation
   - Logging
   - Performance considerations

4. VERIFY implementation:
   - Tests pass
   - Integration works
   - No placeholders remain

Fix every fake implementation found.
No exceptions, no shortcuts.