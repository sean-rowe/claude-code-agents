---
description: Pre-deployment validation
allowed-tools: Bash, Read, Grep
---

Run pre-deployment validation checklist:

1. TEST VALIDATION
   - All unit tests passing
   - Integration tests passing
   - E2E tests passing
   - Performance tests meet SLA

2. ENVIRONMENT CHECK
   - Environment variables configured
   - Database migrations ready
   - Service dependencies available
   - SSL certificates valid

3. SECURITY AUDIT
   - Security scan passed
   - No high/critical vulnerabilities
   - Secrets properly managed
   - CORS/CSP headers configured

4. PERFORMANCE BENCHMARKS
   - Load testing completed
   - Response times acceptable
   - Memory usage within limits
   - Database queries optimized

5. ROLLBACK PLAN
   - Rollback procedure documented
   - Database rollback scripts ready
   - Previous version archived
   - Monitoring alerts configured

All checks must pass for deployment approval.
Generate deployment readiness report.