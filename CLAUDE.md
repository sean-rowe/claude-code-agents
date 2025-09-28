## Development Best Practices

- Always write the tSQLt tests first before writing a procedure
- Never put placeholder comments or code of any sort in the codebase. Always provide a complete implementation that makes the tests pass. Never modify a test beyond fixing syntax errors or writing more tests to cover gherkin or requirements that were missed. Tests are the law
- Never write inline sql. Always write stored procedures that make the tSQLt tests pass
- Always double check the Goland mcp for issues with a file you are working on. you must fix all errors and all warnings
- Never say you have successfully done anything until what you wrote builds and the tests pass
- If I mention that i found placeholder text you must check the entire file for other placeholder text rather than just fixing what i told you
- Don't hard code things like smtphost, smtpuser and password. put those in an .env file
- It doesn't matter how important or unimportant you think an error is, it needs to be fixed. Don't tell me that an error is just 'this' or 'that'. It is an error. Don't stop fixing the errors until they are all fixed and the test passes
- Always run the tests when running the build. the tests are more important than the build. if the build fails, the tests will fail, so just run the tests

## Slash Commands Available

I respond to these slash commands for development workflow:

### Recovery Commands (Fix Existing Code)
- `/auditFake` - Scan entire codebase for placeholder/fake code
- `/fixAll` - Automatically fix all detected issues
- `/proveNotLying` - Demonstrate code works with real execution
- `/recovery` - Complete project recovery from broken state

### TDD Commands
- `/testFirst [Component] [Type]` - Create failing tests (Red phase)
- `/implement [StoryID] [Component]` - Implement to pass tests (Green phase)
- `/validateImpl [Component]` - Validate no fake code exists
- `/commitTdd [red|green|refactor]` - TDD-aware git commits

### Verification Commands
- `/deepVerify` - Deep verification including mutation testing
- `/forceTruth` - Enable strict mode (cannot write placeholder code)
- `/proveAuthenticity` - Prove code is production-ready
- `/fixFakeImpl` - Fix all fake implementations
- `/fixTestLies` - Fix fake tests with real assertions

### Story & Requirements
- `/story [ID] [Title]` - Create user story with acceptance criteria
- `/gherkin [StoryID] [Feature]` - Generate BDD scenarios
- `/requirements [StoryID]` - Extract and validate requirements

### Quick Workflows
- `/initProject [Name] [Type]` - Initialize complete project
- `/storyComplete [StoryID]` - Run full story workflow
- `/auditQuality` - Comprehensive quality audit

When any slash command is used, I will:
1. Acknowledge the command
2. Execute all validations
3. Show real output (not mocked)
4. Fix any issues found
5. Verify the fixes work