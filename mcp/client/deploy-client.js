#!/usr/bin/env node
/**
 * MCP Deploy Client
 * One-command deployment using Model Context Protocol
 */

const { Client } = require('@modelcontextprotocol/sdk/client/index.js');
const { StdioClientTransport } = require('@modelcontextprotocol/sdk/client/stdio.js');
const readline = require('readline');
const fs = require('fs');
const path = require('path');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(prompt) {
  return new Promise(resolve => rl.question(prompt, resolve));
}

class MCPDeployClient {
  constructor() {
    this.client = new Client(
      {
        name: 'ai-chat-deployer',
        version: '1.0.0'
      },
      {
        capabilities: {}
      }
    );
  }

  async connect() {
    const transport = new StdioClientTransport({
      command: 'node',
      args: [path.join(__dirname, '../servers/vercel-server.js')]
    });
    
    await this.client.connect(transport);
    console.log('✅ Connected to Vercel MCP Server\n');
  }

  async deploy() {
    console.log('╔═══════════════════════════════════════════════════════════╗');
    console.log('║           🚀 AI CHAT - ONE-COMMAND DEPLOY                 ║');
    console.log('╚═══════════════════════════════════════════════════════════╝\n');

    // Get user input
    const openaiKey = await question('🔑 OpenAI API Key (sk-...): ');
    const businessName = await question('🏢 Business Name: ');
    const domain = await question('🌐 Custom Domain (optional, press Enter to skip): ');

    console.log('\n📦 Starting deployment...\n');

    try {
      // Call auto_setup tool
      const result = await this.client.callTool({
        name: 'auto_setup',
        arguments: {
          openaiKey,
          businessName,
          domain: domain || undefined
        }
      });

      console.log(result.content[0].text);
      
      // Save deployment info
      this.saveDeploymentInfo({
        businessName,
        domain,
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      console.error('❌ Deployment failed:', error.message);
      process.exit(1);
    }

    rl.close();
  }

  async status() {
    console.log('📊 Getting project status...\n');

    try {
      const result = await this.client.callTool({
        name: 'project_status',
        arguments: {}
      });

      console.log(result.content[0].text);
    } catch (error) {
      console.error('❌ Failed to get status:', error.message);
    }

    rl.close();
  }

  async addDomain() {
    const domain = await question('🌐 Domain to add: ');

    try {
      const result = await this.client.callTool({
        name: 'vercel_add_domain',
        arguments: { domain }
      });

      console.log(result.content[0].text);
    } catch (error) {
      console.error('❌ Failed to add domain:', error.message);
    }

    rl.close();
  }

  saveDeploymentInfo(info) {
    const deployInfo = {
      ...info,
      deployedAt: new Date().toISOString()
    };
    
    fs.writeFileSync(
      'DEPLOYMENT.json',
      JSON.stringify(deployInfo, null, 2)
    );
    
    console.log('\n💾 Deployment info saved to DEPLOYMENT.json');
  }
}

// CLI
async function main() {
  const client = new MCPDeployClient();
  await client.connect();

  const command = process.argv[2] || 'deploy';

  switch (command) {
    case 'deploy':
      await client.deploy();
      break;
    case 'status':
      await client.status();
      break;
    case 'domain':
      await client.addDomain();
      break;
    default:
      console.log('Usage: node deploy-client.js [deploy|status|domain]');
      process.exit(1);
  }
}

main().catch(console.error);
