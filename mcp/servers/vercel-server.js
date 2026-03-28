#!/usr/bin/env node
/**
 * Vercel MCP Server
 * Manages Vercel deployments through Model Context Protocol
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require('@modelcontextprotocol/sdk/types.js');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

class VercelMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'vercel-mcp-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupToolHandlers();
    
    // Error handling
    this.server.onerror = (error) => console.error('[MCP Error]', error);
    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  setupToolHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'vercel_deploy',
            description: 'Deploy AI Chat to Vercel production',
            inputSchema: {
              type: 'object',
              properties: {
                environment: {
                  type: 'string',
                  enum: ['production', 'preview'],
                  description: 'Deployment environment'
                },
                openaiKey: {
                  type: 'string',
                  description: 'OpenAI API Key'
                }
              },
              required: ['environment', 'openaiKey']
            }
          },
          {
            name: 'vercel_set_env',
            description: 'Set environment variables in Vercel',
            inputSchema: {
              type: 'object',
              properties: {
                key: {
                  type: 'string',
                  description: 'Environment variable name'
                },
                value: {
                  type: 'string',
                  description: 'Environment variable value'
                }
              },
              required: ['key', 'value']
            }
          },
          {
            name: 'vercel_add_domain',
            description: 'Add custom domain to Vercel project',
            inputSchema: {
              type: 'object',
              properties: {
                domain: {
                  type: 'string',
                  description: 'Domain name (e.g., aichat.io)'
                }
              },
              required: ['domain']
            }
          },
          {
            name: 'vercel_get_logs',
            description: 'Get deployment logs',
            inputSchema: {
              type: 'object',
              properties: {
                deploymentId: {
                  type: 'string',
                  description: 'Deployment ID (optional)'
                }
              }
            }
          },
          {
            name: 'vercel_list_deployments',
            description: 'List all deployments',
            inputSchema: {
              type: 'object',
              properties: {}
            }
          },
          {
            name: 'vercel_promote',
            description: 'Promote preview deployment to production',
            inputSchema: {
              type: 'object',
              properties: {
                deploymentId: {
                  type: 'string',
                  description: 'Deployment ID to promote'
                }
              },
              required: ['deploymentId']
            }
          },
          {
            name: 'project_status',
            description: 'Get complete project status',
            inputSchema: {
              type: 'object',
              properties: {}
            }
          },
          {
            name: 'auto_setup',
            description: 'Complete automated setup - deploy + configure + domain',
            inputSchema: {
              type: 'object',
              properties: {
                openaiKey: {
                  type: 'string',
                  description: 'OpenAI API Key'
                },
                domain: {
                  type: 'string',
                  description: 'Custom domain (optional)'
                },
                businessName: {
                  type: 'string',
                  description: 'Business name for configuration'
                }
              },
              required: ['openaiKey', 'businessName']
            }
          }
        ]
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'vercel_deploy':
            return await this.deploy(args);
          case 'vercel_set_env':
            return await this.setEnv(args);
          case 'vercel_add_domain':
            return await this.addDomain(args);
          case 'vercel_get_logs':
            return await this.getLogs(args);
          case 'vercel_list_deployments':
            return await this.listDeployments();
          case 'vercel_promote':
            return await this.promote(args);
          case 'project_status':
            return await this.getStatus();
          case 'auto_setup':
            return await this.autoSetup(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error.message}`
            }
          ],
          isError: true
        };
      }
    });
  }

  async deploy(args) {
    const { environment, openaiKey } = args;
    
    console.log(`[MCP] Deploying to ${environment}...`);
    
    // Set OpenAI key first
    execSync(`vercel env add OPENAI_API_KEY ${environment} --yes <<< "${openaiKey}"`, {
      stdio: 'inherit'
    });
    
    // Deploy
    const cmd = environment === 'production' 
      ? 'vercel --prod'
      : 'vercel';
    
    const output = execSync(cmd, { encoding: 'utf-8' });
    
    // Extract deployment URL
    const urlMatch = output.match(/https:\/\/[^\s]+\.vercel\.app/);
    const deploymentUrl = urlMatch ? urlMatch[0] : 'unknown';
    
    return {
      content: [
        {
          type: 'text',
          text: `✅ Deployed to ${environment}!\n\nURL: ${deploymentUrl}\n\nDeployment output:\n${output}`
        }
      ]
    };
  }

  async setEnv(args) {
    const { key, value } = args;
    
    execSync(`vercel env add ${key} production --yes <<< "${value}"`, {
      stdio: 'pipe'
    });
    
    return {
      content: [
        {
          type: 'text',
          text: `✅ Environment variable ${key} set successfully`
        }
      ]
    };
  }

  async addDomain(args) {
    const { domain } = args;
    
    const output = execSync(`vercel domains add ${domain}`, {
      encoding: 'utf-8'
    });
    
    return {
      content: [
        {
          type: 'text',
          text: `✅ Domain ${domain} added!\n\nNext steps:\n1. Add CNAME record: ${domain} → cname.vercel-dns.com\n2. Wait for DNS propagation (few minutes)\n3. SSL certificate will be provisioned automatically\n\nOutput:\n${output}`
        }
      ]
    };
  }

  async getLogs(args) {
    const { deploymentId } = args;
    
    const cmd = deploymentId 
      ? `vercel logs ${deploymentId}`
      : 'vercel logs';
    
    const output = execSync(cmd, { encoding: 'utf-8' });
    
    return {
      content: [
        {
          type: 'text',
          text: `📋 Deployment logs:\n\n${output}`
        }
      ]
    };
  }

  async listDeployments() {
    const output = execSync('vercel list', { encoding: 'utf-8' });
    
    return {
      content: [
        {
          type: 'text',
          text: `📋 Recent deployments:\n\n${output}`
        }
      ]
    };
  }

  async promote(args) {
    const { deploymentId } = args;
    
    execSync(`vercel promote ${deploymentId}`, { stdio: 'inherit' });
    
    return {
      content: [
        {
          type: 'text',
          text: `✅ Deployment ${deploymentId} promoted to production`
        }
      ]
    };
  }

  async getStatus() {
    // Get project info
    const projectInfo = execSync('vercel project ls', { encoding: 'utf-8' });
    
    // Get latest deployment
    const deployments = execSync('vercel list --limit 1', { encoding: 'utf-8' });
    
    // Get domains
    const domains = execSync('vercel domains ls', { encoding: 'utf-8' });
    
    return {
      content: [
        {
          type: 'text',
          text: `📊 Project Status:\n\n📝 Project Info:\n${projectInfo}\n\n🚀 Latest Deployment:\n${deployments}\n\n🌐 Domains:\n${domains}`
        }
      ]
    };
  }

  async autoSetup(args) {
    const { openaiKey, domain, businessName } = args;
    
    console.log('[MCP] Starting automated setup...');
    
    const steps = [];
    
    // Step 1: Set OpenAI key
    try {
      execSync(`vercel env add OPENAI_API_KEY production --yes <<< "${openaiKey}"`, { stdio: 'pipe' });
      steps.push('✅ OpenAI API key configured');
    } catch (e) {
      steps.push('❌ Failed to set OpenAI key: ' + e.message);
    }
    
    // Step 2: Set business name
    try {
      execSync(`vercel env add BUSINESS_NAME production --yes <<< "${businessName}"`, { stdio: 'pipe' });
      steps.push('✅ Business name configured');
    } catch (e) {
      steps.push('❌ Failed to set business name: ' + e.message);
    }
    
    // Step 3: Deploy to production
    let deploymentUrl;
    try {
      const output = execSync('vercel --prod', { encoding: 'utf-8' });
      const urlMatch = output.match(/https:\/\/[^\s]+\.vercel\.app/);
      deploymentUrl = urlMatch ? urlMatch[0] : null;
      steps.push(`✅ Deployed to production: ${deploymentUrl}`);
    } catch (e) {
      steps.push('❌ Deployment failed: ' + e.message);
      throw e;
    }
    
    // Step 4: Add custom domain if provided
    if (domain) {
      try {
        execSync(`vercel domains add ${domain}`, { stdio: 'pipe' });
        steps.push(`✅ Custom domain added: ${domain}`);
        steps.push('⏳ DNS configuration needed:');
        steps.push(`   Add CNAME: ${domain} → cname.vercel-dns.com`);
      } catch (e) {
        steps.push('⚠️ Domain setup: ' + e.message);
      }
    }
    
    return {
      content: [
        {
          type: 'text',
          text: `🎉 Automated setup complete!\n\n${steps.join('\n')}\n\n🔗 Your AI Chat is live at:\n${deploymentUrl}${domain ? '\n🌐 Custom domain: https://' + domain : ''}\n\n📋 Next steps:\n1. Visit your URL\n2. Complete onboarding\n3. Start chatting!`
        }
      ]
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Vercel MCP Server running on stdio');
  }
}

const server = new VercelMCPServer();
server.run().catch(console.error);
