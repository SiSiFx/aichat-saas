# 🔷 Vercel MCP Configuration Guide

## Quick Setup

### 1. Install Vercel MCP Server

```bash
npm install -g @vercel/mcp-server@latest
```

### 2. Login to Vercel

```bash
vercel login
```

### 3. Run Setup Script

```bash
chmod +x scripts/setup-vercel-mcp.sh
./scripts/setup-vercel-mcp.sh
```

This will:
- ✅ Install Vercel CLI
- ✅ Get your Vercel token
- ✅ Create/link project
- ✅ Generate MCP config files
- ✅ Set up environment variables

---

## MCP Configuration Files

### Global Config: `mcp.json`
Main MCP configuration file in project root.

### IDE-Specific Configs:
- **Cursor**: `.cursor/mcp.json`
- **VS Code**: `.vscode/mcp.json`
- **Claude**: `claude_mcp_config.json`

---

## Environment Variables

Create `.env.local`:

```env
# Vercel
VERCEL_TOKEN=your_token_here
VERCEL_ORG_ID=your_org_id
VERCEL_PROJECT_ID=your_project_id

# AI Chat
OPENAI_API_KEY=sk-your-key
BUSINESS_NAME=Your Business
CUSTOM_DOMAIN=yourdomain.com
```

---

## MCP Tools Available

### From Official Vercel MCP Server:

| Tool | Description |
|------|-------------|
| `vercel_deploy` | Deploy project to Vercel |
| `vercel_list_deployments` | List all deployments |
| `vercel_get_project` | Get project details |
| `vercel_create_project` | Create new project |
| `vercel_add_environment_variable` | Set env var |
| `vercel_list_teams` | List teams |

### From Custom AI Chat Server:

| Tool | Description |
|------|-------------|
| `auto_setup` | Complete automated setup |
| `project_status` | Get full project status |
| `vercel_add_domain` | Add custom domain |

---

## Usage Examples

### Deploy to Production

```bash
# Using MCP
npx @vercel/mcp-server vercel_deploy --project=ai-chat --environment=production

# Or traditional
vercel --prod
```

### Set Environment Variable

```bash
# Using MCP
npx @vercel/mcp-server vercel_add_environment_variable \
  --project=ai-chat \
  --name=OPENAI_API_KEY \
  --value=sk-... \
  --environment=production

# Or traditional
vercel env add OPENAI_API_KEY production
```

### Complete Auto-Setup

```bash
# Using custom MCP
node mcp/client/deploy-client.js deploy

# Or menu
./deploy-mcp.sh
```

---

## Testing MCP Connection

```bash
# Test if MCP server is running
npx @vercel/mcp-server vercel_list_projects

# Should output your Vercel projects
```

---

## Troubleshooting

### "VERCEL_TOKEN not set"

```bash
# Get token from auth file
cat ~/.vercel/auth.json | grep token

# Or re-login
vercel login
```

### "Project not found"

```bash
# Link project
vercel link

# Or create new
vercel --confirm
```

### "MCP server not responding"

```bash
# Reinstall MCP server
npm install -g @vercel/mcp-server@latest

# Check node version
node --version  # Should be 18+
```

---

## IDE Integration

### Cursor
MCP config in `.cursor/mcp.json` - automatically detected.

### VS Code
Install MCP extension, config in `.vscode/mcp.json`.

### Claude Desktop
Add to Claude settings:
```json
{
  "mcpServers": {
    "vercel": {
      "command": "npx",
      "args": ["-y", "@vercel/mcp-server@latest"]
    }
  }
}
```

---

## Complete Deploy with MCP

```bash
# 1. Setup
./scripts/setup-vercel-mcp.sh

# 2. Configure env
echo "OPENAI_API_KEY=sk-..." >> .env.local

# 3. Deploy with MCP
./deploy-mcp.sh

# Or use Vercel CLI directly
vercel --prod
```

---

## 🎉 You're Ready!

MCP is now configured. You can:
- Deploy from IDE using MCP tools
- Automate deployments
- Manage infrastructure as code

**Next: Run `./scripts/setup-vercel-mcp.sh`**
