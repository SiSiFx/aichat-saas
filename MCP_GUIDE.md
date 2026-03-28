# 🤖 AI Chat - MCP Management Guide

## What is MCP?

**Model Context Protocol (MCP)** - A protocol for managing AI applications through standardized tools and interfaces.

AI Chat uses MCP to provide **automated deployment and management**.

---

## 🚀 Quick Deploy with MCP

### One Command Deploy
```bash
./deploy-mcp.sh
```

Or directly:
```bash
cd mcp && npm install && node client/deploy-client.js deploy
```

### What Happens Automatically:
1. ✅ Sets OpenAI API key
2. ✅ Sets business configuration
3. ✅ Deploys to Vercel production
4. ✅ Configures custom domain (if provided)
5. ✅ Saves deployment info

---

## 📋 MCP Tools Available

### `auto_setup`
Complete automated setup in one command.

**Parameters:**
- `openaiKey` (required) - Your OpenAI API key
- `businessName` (required) - Your business name
- `domain` (optional) - Custom domain

**Example:**
```javascript
await client.callTool({
  name: 'auto_setup',
  arguments: {
    openaiKey: 'sk-...',
    businessName: 'My Store',
    domain: 'aichat.mystore.com'
  }
});
```

### `vercel_deploy`
Deploy to production or preview.

**Parameters:**
- `environment` - "production" or "preview"
- `openaiKey` - OpenAI API key

### `vercel_set_env`
Set environment variables.

**Parameters:**
- `key` - Variable name
- `value` - Variable value

### `vercel_add_domain`
Add custom domain.

**Parameters:**
- `domain` - Domain name

### `project_status`
Get complete project status.

### `vercel_list_deployments`
List all deployments.

### `vercel_promote`
Promote preview to production.

**Parameters:**
- `deploymentId` - Deployment to promote

---

## 🔧 Using MCP Client

### Deploy
```bash
cd mcp
node client/deploy-client.js deploy
```

### Check Status
```bash
cd mcp
node client/deploy-client.js status
```

### Add Domain
```bash
cd mcp
node client/deploy-client.js domain
```

---

## 🌐 MCP Server Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     MCP CLIENT                               │
│                 (deploy-client.js)                           │
│                                                              │
│  • User interface                                            │
│  • Tool orchestration                                        │
│  • Result handling                                           │
└──────────────────────┬───────────────────────────────────────┘
                       │ MCP Protocol
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                   MCP SERVERS                                │
├──────────────────┬──────────────────┬────────────────────────┤
│  vercel-server   │  github-server   │  project-server        │
│                  │                  │                        │
│  • Deploy        │  • Create repo   │  • Manage config       │
│  • Set env       │  • Push code     │  • Monitor health      │
│  • Add domain    │  • PRs           │  • Analytics           │
└──────────────────┴──────────────────┴────────────────────────┘
                       │
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
      Vercel       GitHub       AI Chat
      Platform     Repo         Backend
```

---

## ⚙️ Configuration

### MCP Config File (`mcp/config/mcp.json`)

```json
{
  "mcpServers": {
    "vercel": {
      "command": "node",
      "args": ["mcp/servers/vercel-server.js"],
      "env": {
        "VERCEL_TOKEN": "${VERCEL_TOKEN}"
      }
    }
  }
}
```

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `OPENAI_API_KEY` | OpenAI API key | ✅ Yes |
| `VERCEL_TOKEN` | Vercel auth token | ✅ Yes |
| `BUSINESS_NAME` | Your business name | ✅ Yes |
| `CUSTOM_DOMAIN` | Custom domain (optional) | ❌ No |
| `GITHUB_TOKEN` | GitHub token (optional) | ❌ No |

---

## 🔄 Automated Workflows

### GitHub Actions + MCP

When you push to GitHub, MCP automatically:
1. Deploys to Vercel
2. Sets environment variables
3. Sends Slack notification
4. Updates deployment log

### Local Development
```bash
# Start MCP server
npm run server

# In another terminal, run client
npm run deploy
```

---

## 📊 Monitoring

### Get Status
```bash
cd mcp
node client/deploy-client.js status
```

### View Logs
```bash
vercel logs
```

### List Deployments
```bash
vercel list
```

---

## 🎯 Advanced Usage

### Custom MCP Tool

Create your own tool in `mcp/servers/`:

```javascript
// my-tool.js
{
  name: 'my_custom_tool',
  description: 'Does something custom',
  inputSchema: {
    type: 'object',
    properties: {
      param: { type: 'string' }
    }
  }
}
```

### Batch Operations

```javascript
// Deploy to multiple environments
await Promise.all([
  client.callTool({ name: 'vercel_deploy', arguments: { environment: 'preview' } }),
  client.callTool({ name: 'vercel_set_env', arguments: { key: 'DEBUG', value: 'true' } })
]);
```

---

## 🛠️ Troubleshooting

### "MCP Server not found"
```bash
cd mcp && npm install
```

### "Vercel token invalid"
```bash
vercel login
# Then copy token from ~/.vercel/auth.json
```

### "Deployment failed"
Check logs:
```bash
vercel logs
```

---

## 🎉 Benefits of MCP

| Feature | Traditional | MCP |
|---------|-------------|-----|
| **Setup time** | 10+ minutes | 30 seconds |
| **Commands** | Multiple | Single |
| **Automation** | Manual | Full |
| **Monitoring** | Separate | Integrated |
| **Scaling** | Manual | Automatic |

---

## 🚀 Deploy Now

```bash
# Easiest way
./deploy-mcp.sh

# Or step by step
cd mcp
npm install
node client/deploy-client.js deploy
```

**Your AI Chat will be live in 30 seconds!** 🎊
