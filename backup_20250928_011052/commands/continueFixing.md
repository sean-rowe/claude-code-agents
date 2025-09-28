---
description: Continue fixing from where autoFixAll left off
allowed-tools: TodoWrite, Grep, Read, Edit, MultiEdit, Bash
---

## CONTINUE PREVIOUS FIX SESSION

This command picks up where `/autoFixAll` left off if it stopped prematurely.

### IMMEDIATE ACTION:

1. **CHECK REMAINING WORK:**
   - Run /auditFake to find remaining issues
   - Check git status for uncommitted fixes
   - Review any existing todo list

2. **RESUME THE PLAN:**
```markdown
## 📋 RESUMING FIX PLAN

### Previously Completed: [Show what was done]
- [✅] Fixed items from last session...

### Still To Fix: [Show what remains]
- [ ] **file:line** - Issue → Fix
- [ ] Continue with all remaining items...
```

3. **CONTINUE FIXING:**
   - Start with the first unchecked item
   - Work through ENTIRE list
   - Don't stop until ZERO issues remain

4. **VERIFICATION:**
   - After all items fixed, run full audit
   - If new issues found, fix those too
   - Only stop when audit is completely clean

## IMPORTANT:
- This is a CONTINUATION, not a new session
- Complete ALL remaining work
- Don't re-fix already completed items
- Keep going until done

Start immediately where the previous session ended.