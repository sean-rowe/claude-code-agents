# BDD Setup Command

Complete BDD management - analyzes existing Gherkin, creates optimized scenarios with reusable steps, and generates step definitions.

## Usage
```
/bdd-setup [feature-name]
```

Examples:
- `/bdd-setup authentication` - Set up BDD for authentication feature
- `/bdd-setup` - Analyze all features and optimize BDD

## What This Command Does

1. **Analyzes Existing Gherkin**
   - Reads all `.feature` files
   - Identifies ambiguous steps
   - Finds reusability opportunities
   - Detects missing coverage

2. **Reads Requirements**
   - Scans all `*.md` files for requirements
   - Identifies testable statements
   - Maps requirements to scenarios

3. **Optimizes Steps**
   - Converts hardcoded values to parameters
   - Creates reusable step definitions
   - Uses Scenario Outlines with Examples tables

4. **Generates Step Definitions**
   - Detects BDD framework (Cucumber, Behave, etc.)
   - Creates parameterized step definitions
   - Stubs missing implementations

5. **Runs BDD Tests**
   - Verifies infrastructure setup
   - Runs dry-run to check parsing
   - Executes tests and reports results

## Command Implementation

```javascript
async function bddSetup(featureName) {
  await Task({
    subagent_type: "general-purpose",
    description: "Complete BDD setup",
    prompt: `Use bdd-manager agent to:

1. DISCOVERY PHASE:
   - Read ALL .feature files in the project
   - Read ALL requirements in *.md files
   - Analyze existing Gherkin for improvements

2. ANALYSIS PHASE:
   - Identify missing test coverage from requirements
   - Find ambiguous steps that could be merged
   - Detect hardcoded values that should be parameters
   - Calculate reusability metrics

3. OPTIMIZATION PHASE:
   - Convert scenarios to use Scenario Outlines
   - Create parameterized steps with <variables>
   - Add Examples tables for data-driven testing
   - Merge similar steps into reusable ones

4. GENERATION PHASE:
   - Detect the BDD framework being used
   - Generate step definition files
   - Create stubs for all missing steps
   - Include proper imports and setup

5. VERIFICATION PHASE:
   - Run BDD tests with --dry-run first
   - Execute actual tests
   - Report passing/failing/pending
   - Show coverage metrics

${featureName ? `Focus on feature: ${featureName}` : 'Process all features'}

Output:
- Optimized .feature files
- Complete step definitions
- Test execution report
- Coverage analysis`
  });
}
```

## Example Optimization

### Before (Poor Reusability)
```gherkin
Scenario: Admin login
  Given the admin user "admin@example.com" exists
  When the admin logs in with password "Admin123!"
  Then the admin should see the admin dashboard

Scenario: User login
  Given the regular user "user@example.com" exists
  When the user logs in with password "User123!"
  Then the user should see the user dashboard
```

### After (Optimized)
```gherkin
Scenario Outline: User login by role
  Given a user with email "<email>" and role "<role>" exists
  When the user logs in with password "<password>"
  Then the user should see the "<dashboard>" dashboard

  Examples:
    | email              | role  | password  | dashboard |
    | admin@example.com  | admin | Admin123! | admin     |
    | user@example.com   | user  | User123!  | user      |
```

## Generated Step Definitions

```javascript
// Reusable parameterized steps
Given('a user with email {string} and role {string} exists', async function(email, role) {
  this.testUser = await createTestUser({ email, role });
  expect(this.testUser).to.not.be.null;
});

When('the user logs in with password {string}', async function(password) {
  this.response = await this.client.post('/login', {
    email: this.testUser.email,
    password: password
  });
});

Then('the user should see the {string} dashboard', async function(dashboardType) {
  expect(this.response.redirectUrl).to.equal(`/${dashboardType}/dashboard`);
  const page = await this.client.get(this.response.redirectUrl);
  expect(page.body).to.include(`${dashboardType} Dashboard`);
});
```

## Coverage Report Output

```
BDD Analysis Report
==================

Coverage Analysis:
- Total Requirements: 45
- Covered by Scenarios: 38 (84%)
- Missing Coverage: 7

Missing Scenarios:
1. Password reset flow
2. Two-factor authentication
3. Session timeout handling

Step Reusability:
- Original Steps: 67
- Optimized Steps: 23
- Reduction: 66%

Ambiguous Steps Fixed:
- "user is logged in" → "the user {string} is logged in"
- "click submit" → "submit the {string} form"

Test Results:
- Framework: Cucumber.js
- Scenarios: 45
- Passing: 38 ✅
- Pending: 7 ⏳
- Runtime: 2.3s
```

## Benefits

1. **Reduces Duplication** - Reusable steps mean less code to maintain
2. **Improves Clarity** - Parameterized steps are more explicit
3. **Enables Data-Driven Testing** - Examples tables test multiple cases
4. **Ensures Coverage** - Maps requirements to scenarios
5. **Validates Setup** - Confirms BDD infrastructure works

## Next Steps

After running `/bdd-setup`, use:
- `/story-breakdown` to create JIRA stories from scenarios
- `/production-orchestrator` to implement the stories
- `/bdd-run` to execute all BDD tests