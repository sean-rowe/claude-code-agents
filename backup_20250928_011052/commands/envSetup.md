---
description: Set up environment configuration securely
argument-hint: <environment>
allowed-tools: Write, Read, Bash
---

Set up environment configuration for: $ARGUMENTS

Create secure environment setup:

1. CREATE .env template:
   - Database connection strings
   - API keys (with placeholders)
   - SMTP configuration
   - Feature flags
   - Service URLs

2. DOCUMENT required variables:
   - Variable name
   - Purpose
   - Example value
   - Security level

3. SET UP secret management:
   - Use environment variables
   - Never commit actual secrets
   - Provide .env.example file

4. VALIDATE configuration:
   - Test database connectivity
   - Verify API endpoints
   - Check SMTP settings
   - Validate all required vars set

5. SECURITY checks:
   - No hardcoded secrets in code
   - .env in .gitignore
   - Secure defaults provided
   - Sensitive data encrypted

Generate:
- .env.example with all variables
- README section for environment setup
- Validation script to check configuration