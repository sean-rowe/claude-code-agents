#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load MCP configuration
const config = JSON.parse(readFileSync(join(__dirname, 'mcp-server.json'), 'utf8'));

// Create MCP server
const server = new Server(
  {
    name: config.name,
    version: config.version,
  },
  {
    capabilities: {
      prompts: {},
      resources: {},
      tools: {},
    },
  }
);

// Register all prompts from configuration
Object.entries(config.prompts).forEach(([key, prompt]) => {
  server.setRequestHandler(`prompts/${key}`, async (request) => {
    const args = request.arguments || {};
    let processedPrompt = prompt.prompt;

    // Replace template variables
    prompt.arguments?.forEach(arg => {
      const value = args[arg.name] || arg.default || '';
      processedPrompt = processedPrompt.replace(new RegExp(`{{${arg.name}}}`, 'g'), value);
    });

    return {
      description: prompt.description,
      messages: [
        {
          role: 'user',
          content: {
            type: 'text',
            text: processedPrompt
          }
        }
      ]
    };
  });
});

// List available prompts
server.setRequestHandler('prompts/list', async () => {
  return {
    prompts: Object.entries(config.prompts).map(([key, prompt]) => ({
      name: key,
      description: prompt.description,
      arguments: prompt.arguments?.map(arg => ({
        name: arg.name,
        description: arg.description,
        required: arg.required || false,
      })) || []
    }))
  };
});

// Register resources if defined
if (config.resources) {
  Object.entries(config.resources).forEach(([key, resource]) => {
    server.setRequestHandler(`resources/${key}`, async () => {
      return {
        contents: [{
          uri: resource.uri,
          mimeType: resource.mimeType || 'text/plain',
          text: `Resource: ${resource.name}\n${resource.description}`
        }]
      };
    });
  });

  server.setRequestHandler('resources/list', async () => {
    return {
      resources: Object.entries(config.resources).map(([key, resource]) => ({
        uri: resource.uri,
        name: resource.name,
        description: resource.description,
        mimeType: resource.mimeType || 'text/plain'
      }))
    };
  });
}

// Register tools if defined
if (config.tools) {
  Object.entries(config.tools).forEach(([key, tool]) => {
    server.setRequestHandler(`tools/${key}`, async (request) => {
      // Tool implementation would go here
      return {
        content: [{
          type: 'text',
          text: `Executing tool: ${key} with args: ${JSON.stringify(request.arguments)}`
        }]
      };
    });
  });

  server.setRequestHandler('tools/list', async () => {
    return {
      tools: Object.entries(config.tools).map(([key, tool]) => ({
        name: key,
        description: tool.description,
        inputSchema: tool.inputSchema
      }))
    };
  });
}

// Start the server
const transport = new StdioServerTransport();
await server.connect(transport);

console.error(`MCP Server "${config.name}" v${config.version} running`);
console.error(`Available prompts: ${Object.keys(config.prompts).join(', ')}`);