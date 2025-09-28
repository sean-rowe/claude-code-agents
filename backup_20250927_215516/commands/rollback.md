---
description: Safe rollback procedures
argument-hint: <version> <reason>
allowed-tools: Bash, Read, Write
---

Execute safe rollback to version: $ARGUMENTS

Rollback procedure:

1. BACKUP current state:
   - Database snapshot
   - Configuration backup
   - Log preservation
   - User session data

2. EXECUTE rollback:
   - Switch to previous version
   - Run database rollback scripts
   - Restore configuration
   - Clear caches

3. VALIDATE system health:
   - Run smoke tests
   - Check critical endpoints
   - Verify database integrity
   - Monitor error rates

4. UPDATE monitoring:
   - Set rollback alerts
   - Track performance metrics
   - Monitor user impact
   - Check system resources

5. DOCUMENT incident:
   - Rollback reason
   - Timeline of events
   - Impact assessment
   - Lessons learned

Generate rollback report with all actions taken.