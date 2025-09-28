// Test Template for {{STORY_ID}}
// Generated from Gherkin scenarios

describe('{{FEATURE_NAME}}', () => {
  describe('{{RULE_1}}', () => {
    test('{{SCENARIO_1}}', () => {
      // Given: {{GIVEN_1}}
      const setup = setupTest();

      // When: {{WHEN_1}}
      const result = performAction(setup);

      // Then: {{THEN_1}}
      expect(result).toBe({{EXPECTED_1}});
    });

    test('{{SCENARIO_2}}', () => {
      // Given: {{GIVEN_2}}
      const setup = setupTestWithCondition();

      // When: {{WHEN_2}}
      const result = performDifferentAction(setup);

      // Then: {{THEN_2}}
      expect(result).toBe({{EXPECTED_2}});
    });
  });

  describe('{{RULE_2}}', () => {
    test('should handle edge case', () => {
      // Given: {{GIVEN_EDGE}}
      const edgeCase = createEdgeCase();

      // When: {{WHEN_EDGE}}
      const result = handleEdgeCase(edgeCase);

      // Then: {{THEN_EDGE}}
      expect(result).not.toThrow();
      expect(result).toBeDefined();
    });

    test('should handle error case', () => {
      // Given: {{GIVEN_ERROR}}
      const errorSetup = createErrorCondition();

      // When/Then: {{WHEN_ERROR}}
      expect(() => performRiskyAction(errorSetup))
        .toThrow('{{ERROR_MESSAGE}}');
    });
  });
});

// Test helpers
function setupTest() {
  return {
    // Test setup
  };
}

function performAction(setup) {
  // Implementation to test
  throw new Error('Not implemented - write test first!');
}