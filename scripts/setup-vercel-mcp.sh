#!/bin/bash
# Setup Vercel MCP for AI Chat
# One-command setup for Vercel MCP integration

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[Vercel MCP]${NC} $1"; }
success() { echo -e "${GREEN}[Vercel MCP]${NC} $1"; }
warn() { echo -e "${YELLOW}[Vercel MCP]${NC} $1"; }

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           🔷 VERCEL MCP SETUP FOR AI CHAT                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    log "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install Vercel CLI globally
log "Installing Vercel CLI..."
npm install -g vercel@latest

# Install Vercel MCP Server globally
log "Installing Vercel MCP Server..."
npm install -g @vercel/mcp-server@latest

# Check if user is logged in
log "Checking Vercel authentication..."
if ! vercel whoami &> /dev/null; then
    warn "Not logged in to Vercel"
    echo ""
    echo "Please login:"
    vercel login
fi

# Get Vercel token
log "Getting Vercel token..."
VERCEL_TOKEN=$(cat ~/.vercel/auth.json | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$VERCEL_TOKEN" ]; then
    error "Could not get Vercel token. Please run 'vercel login' first."
    exit 1
fi

# Get project info
echo ""
read -p "📁 Enter your Vercel project name (or press Enter to create new): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="ai-chat"
    warn "Using default project name: $PROJECT_NAME"
fi

# Link project
log "Linking Vercel project..."
vercel link --yes --project=$PROJECT_NAME || true

# Get project details
VERCEL_PROJECT_ID=$(vercel project ls 2>/dev/null | grep "$PROJECT_NAME" | awk '{print $2}' || echo "")
VERCEL_ORG_ID=$(vercel team ls 2>/dev/null | grep "Personal" | awk '{print $2}' || echo "")

if [ -z "$VERCEL_PROJECT_ID" ]; then
    warn "Creating new Vercel project..."
    vercel --confirm --name=$PROJECT_NAME
    VERCEL_PROJECT_ID=$(vercel project ls | grep "$PROJECT_NAME" | awk '{print $2}')
fi

# Create environment files
log "Creating MCP configuration..."

# Create .env file for local development
cat > .env.vercel << EOF
# Vercel MCP Configuration
VERCEL_TOKEN=$VERCEL_TOKEN
VERCEL_ORG_ID=$VERCEL_ORG_ID
VERCEL_PROJECT_ID=$VERCEL_PROJECT_ID
VERCEL_PROJECT_NAME=$PROJECT_NAME
EOF

# Create .env.local for Next.js/Vercel
cat > .env.local << EOF
# AI Chat Environment
VERCEL_TOKEN=$VERCEL_TOKEN
OPENAI_API_KEY=your-openai-key-here
BUSINESS_NAME=Your Business Name
EOF

# Export for current session
export VERCEL_TOKEN=$VERCEL_TOKEN
export VERCEL_ORG_ID=$VERCEL_ORG_ID
export VERCEL_PROJECT_ID=$VERCEL_PROJECT_ID

# Create MCP config with actual values
cat > mcp-config.json << EOF
{
  "mcpServers": {
    "vercel": {
      "command": "npx",
      "args": ["-y", "@vercel/mcp-server@latest"],
      "env": {
        "VERCEL_TOKEN": "$VERCEL_TOKEN",
        "VERCEL_ORG_ID": "$VERCEL_ORG_ID",
        "VERCEL_PROJECT_ID": "$VERCEL_PROJECT_ID"
      }
    }
  }
}
EOF

echo ""
success "✅ Vercel MCP Setup Complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔧 Configuration saved to:"
echo "   • .env.vercel (local env)"
echo "   • .env.local (app env)"
echo "   • mcp-config.json (MCP config)"
echo ""
echo "📋 Your Vercel Details:"
echo "   Project: $PROJECT_NAME"
echo "   Org ID: $VERCEL_ORG_ID"
echo "   Project ID: $VERCEL_PROJECT_ID"
echo ""
echo "🚀 Next Steps:"
echo "   1. Add your OpenAI key to .env.local"
echo "   2. Deploy: vercel --prod"
echo "   3. MCP tools are now available in your IDE"
echo ""
echo "💡 MCP Tools Available:"
echo "   • vercel_deploy - Deploy your project"
echo "   • vercel_list_deployments - List all deployments"
echo "   • vercel_get_project - Get project info"
echo "   • vercel_create_project - Create new project"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
