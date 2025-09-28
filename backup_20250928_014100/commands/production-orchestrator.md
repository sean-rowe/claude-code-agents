# Production Orchestrator Command

Complete orchestration for production-quality code in agile environments with all quality gates.

## Usage
```
/production-orchestrator [sprint|story|deploy|audit]
```

Options:
- `/production-orchestrator` - Full production pipeline
- `/production-orchestrator sprint SPRINT-15` - Process entire sprint
- `/production-orchestrator story STORY-123` - Single story with all checks
- `/production-orchestrator deploy` - Deploy with all validations
- `/production-orchestrator audit` - Full security/compliance audit

## What This Command Does

Delivers TRUE production-quality code with:

**Sprint Management**
- Story prioritization and dependency tracking
- Velocity calculation and burndown
- Automated JIRA/GitHub updates

**Development Quality**
- BDD test-driven development
- DDD architecture with SOLID principles
- API contract generation (OpenAPI)
- Database migration management

**Security & Compliance**
- OWASP vulnerability scanning
- GDPR/CCPA compliance checks
- Input validation and sanitization
- Authentication/authorization testing

**Performance & Reliability**
- Load testing with k6/JMeter
- Database query optimization
- Response time SLA validation
- Memory profiling

**Observability**
- Structured logging setup
- Distributed tracing (OpenTelemetry)
- Custom metrics and KPIs
- Error tracking (Sentry)

**CI/CD Pipeline**
- Automated quality gates
- Blue-green deployments
- Rollback mechanisms
- Environment promotion

## Complete Production Flow

```javascript
async function orchestrateProduction() {
  // PHASE 0: Sprint Planning
  const sprint = await Task({
    subagent_type: "general-purpose",
    description: "Sprint planning",
    prompt: `
      - Identify current sprint stories
      - Calculate story points
      - Check dependencies
      - Update issue tracker
    `
  });

  // PHASE 1: Environment Setup
  await setupEnvironments();
  await configureDatabases();
  await createMigrations();

  // PHASE 2: Development Loop
  for (const story of sprint.stories) {
    // BDD Development
    await writeBDDScenarios(story);
    await implementWithDDD(story);

    // API Documentation
    await generateOpenAPISpec(story);
    await createAPIContractTests(story);

    // Database
    await createMigrations(story);
    await optimizeQueries(story);
  }

  // PHASE 3: Security Validation
  await Task({
    subagent_type: "general-purpose",
    description: "Security audit",
    prompt: `
      Run complete security scan:
      - OWASP dependency check
      - SQL injection testing
      - XSS vulnerability scan
      - Authentication testing
      - Secret scanning
      - GDPR compliance check
    `
  });

  // PHASE 4: Performance Testing
  await Task({
    subagent_type: "general-purpose",
    description: "Performance validation",
    prompt: `
      Execute performance tests:
      - Load testing (100 concurrent users)
      - Response time < 500ms p95
      - Memory leak detection
      - Database query optimization
      - CDN configuration
    `
  });

  // PHASE 5: Accessibility
  await Task({
    subagent_type: "general-purpose",
    description: "Accessibility audit",
    prompt: `
      Validate WCAG 2.1 AA compliance:
      - Run axe-core tests
      - Check keyboard navigation
      - Validate ARIA labels
      - Test screen reader compatibility
      - Check color contrast ratios
    `
  });

  // PHASE 6: Observability Setup
  await Task({
    subagent_type: "general-purpose",
    description: "Configure monitoring",
    prompt: `
      Set up production observability:
      - Structured logging (Winston/Pino)
      - OpenTelemetry tracing
      - Custom business metrics
      - Health check endpoints
      - Sentry error tracking
      - PagerDuty alerts
    `
  });

  // PHASE 7: CI/CD Pipeline
  await Task({
    subagent_type: "general-purpose",
    description: "Pipeline creation",
    prompt: `
      Generate CI/CD pipeline:
      - GitHub Actions/GitLab CI
      - Quality gates (coverage > 90%)
      - Security scanning stage
      - Performance testing stage
      - Blue-green deployment
      - Automatic rollback on failure
    `
  });

  // PHASE 8: Documentation
  await generateDocumentation();
  await createRunbooks();
  await updateChangelog();

  // PHASE 9: Deployment
  await deployToStaging();
  await runSmokeTests();
  await deployToProduction();

  // PHASE 10: Final Truth
  await executeForceTruth();
}
```

## Quality Gates

Every story must pass:

| Gate | Requirement | Tool |
|------|-------------|------|
| Unit Tests | > 90% coverage | Jest/Mocha |
| Integration Tests | All passing | Supertest |
| BDD Tests | All scenarios | Cucumber |
| Security | Zero high/critical | Snyk/OWASP |
| Performance | < 500ms p95 | k6 |
| Accessibility | WCAG 2.1 AA | axe-core |
| Type Safety | Zero errors | TypeScript |
| Linting | Zero violations | ESLint |
| API Docs | 100% coverage | OpenAPI |

## Sprint Reporting

```markdown
## Sprint 15 Report
**Completed**: 8/10 stories (34/40 points)
**Velocity**: 34 points
**Quality Metrics**:
- Test Coverage: 94%
- Security Issues: 0 critical, 0 high
- Performance: p95 < 450ms ✅
- Accessibility: WCAG 2.1 AA ✅
- API Documentation: 100% ✅

**Deployments**:
- Staging: 5 deployments, 0 rollbacks
- Production: 2 deployments, 0 incidents

**Technical Debt**:
- Reduced by 15%
- Zero new debt introduced
```

## Database Migration Example

```typescript
// Generated migration
export class AddSessionsTable_1699123456789 {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'sessions',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            default: 'uuid_generate_v4()'
          },
          {
            name: 'student_id',
            type: 'uuid',
            isNullable: false
          },
          {
            name: 'scheduled_at',
            type: 'timestamp',
            isNullable: false
          }
        ],
        foreignKeys: [
          {
            columnNames: ['student_id'],
            referencedTableName: 'students',
            referencedColumnNames: ['id']
          }
        ],
        indices: [
          {
            columnNames: ['scheduled_at', 'status']
          }
        ]
      })
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('sessions');
  }
}
```

## CI/CD Pipeline Generated

```yaml
name: Production Pipeline
on:
  push:
    branches: [main, develop]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Quality Checks
        run: |
          npm run lint
          npm run typecheck
          npm run test:unit
          npm run test:integration
          npm run test:bdd

      - name: Security Scan
        run: |
          npm audit
          snyk test
          semgrep --config=auto

      - name: Performance Test
        run: npm run test:performance

      - name: Accessibility Test
        run: npm run test:accessibility

      - name: Coverage Check
        run: |
          npm run test:coverage
          if [ $(cat coverage/coverage-summary.json | jq '.total.lines.pct') -lt 90 ]; then
            echo "Coverage below 90%"
            exit 1
          fi

  deploy-staging:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Staging
        run: |
          kubectl apply -f k8s/staging/
          kubectl rollout status deployment/api

      - name: Smoke Tests
        run: npm run test:smoke:staging

  deploy-production:
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Blue-Green Deploy
        run: |
          ./scripts/blue-green-deploy.sh

      - name: Health Check
        run: |
          ./scripts/health-check.sh

      - name: Rollback if Failed
        if: failure()
        run: |
          ./scripts/rollback.sh
```

## Observability Configuration

```typescript
// Structured logging
import winston from 'winston';

const logger = winston.createLogger({
  format: winston.format.json(),
  defaultMeta: {
    service: 'therapy-api',
    environment: process.env.NODE_ENV
  },
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// OpenTelemetry
import { NodeSDK } from '@opentelemetry/sdk-node';
import { Resource } from '@opentelemetry/resources';

const sdk = new NodeSDK({
  resource: new Resource({
    'service.name': 'therapy-api',
    'service.version': process.env.VERSION
  }),
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
    new PrismaInstrumentation()
  ]
});

// Health checks
app.get('/health', (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    checks: {
      database: await checkDatabase(),
      redis: await checkRedis(),
      external_apis: await checkExternalAPIs()
    }
  };
  res.json(health);
});
```

## Final Truth Verification

As the LAST step, executes `/forceTruth` to verify:
- ✅ NO placeholder code
- ✅ NO TODO comments
- ✅ NO fake implementations
- ✅ ALL security scans passed
- ✅ ALL performance benchmarks met
- ✅ ALL accessibility tests passed
- ✅ 100% API documentation
- ✅ Database migrations tested
- ✅ CI/CD pipeline working
- ✅ Observability configured

Reports the TRUTH about production readiness!

## Success Criteria

Production deployment requires:
- Sprint stories: 100% complete
- Test coverage: > 90%
- Security vulnerabilities: 0 high/critical
- API documentation: 100%
- Database migrations: Tested and reversible
- Performance SLAs: All met
- Accessibility: WCAG 2.1 AA
- CI/CD pipeline: All stages passing
- Monitoring: Configured and tested
- Rollback plan: Documented and tested

This delivers TRUE production-quality code!