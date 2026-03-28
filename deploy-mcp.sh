#!/bin/bash
# AI Chat - MCP-Based Deployment
# The most sophisticated deployment system

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[MCP]${NC} $1"; }
success() { echo -e "${GREEN}[MCP]${NC} $1"; }

print_banner() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              🤖 AI CHAT - MCP DEPLOYMENT                       ║
║                                                                ║
║     Model Context Protocol based automated deployment         ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
}

# Check prerequisites
check_prerequisites() {
    log "Checking MCP prerequisites..."
    
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js required. Installing..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    fi
    
    if ! command -v vercel &> /dev/null; then
        log "Installing Vercel CLI..."
        npm install -g vercel
    fi
    
    success "Prerequisites OK"
}

# Install MCP dependencies
install_mcp() {
    log "Installing MCP SDK..."
    cd mcp && npm install && cd ..
    success "MCP ready"
}

# Main deployment with MCP
deploy_with_mcp() {
    print_banner
    
    check_prerequisites
    install_mcp
    
    echo ""
    echo "┌────────────────────────────────────────────────────────────────┐"
    echo "│  🚀 Starting MCP-based deployment                             │"
    echo "└────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Run MCP client
    cd mcp && node client/deploy-client.js deploy
}

# Quick deploy (no MCP)
quick_deploy() {
    print_banner
    
    log "Quick deployment mode..."
    
    # Use simple vercel deploy
    if [ -z "$OPENAI_API_KEY" ]; then
        read -sp "🔑 OpenAI API Key: " OPENAI_API_KEY
        echo ""
    fi
    
    # Set env and deploy
    vercel env add OPENAI_API_KEY production --yes <<< "$OPENAI_API_KEY"
    vercel --prod
    
    success "✅ Deployed!"
}

# Menu
show_menu() {
    print_banner
    echo ""
    echo "Choose deployment method:"
    echo ""
    echo "  1) 🤖 MCP Auto-Deploy (Recommended)"
    echo "     - Full automated setup"
    echo "     - Custom domain support"
    echo "     - Complete management"
    echo ""
    echo "  2) ⚡ Quick Deploy (Vercel CLI)"
    echo "     - Simple and fast"
    echo "     - Basic deployment"
    echo ""
    echo "  3) 🐳 Docker Deploy"
    echo "     - Self-hosted"
    echo "     - Full control"
    echo ""
    echo "  4) 📊 Check Status"
    echo ""
    
    read -p "Select [1-4]: " choice
    
    case $choice in
        1)
            deploy_with_mcp
            ;;
        2)
            quick_deploy
            ;;
        3)
            docker-compose up -d
            success "Docker deployment complete!"
            echo "Visit: http://localhost:3000"
            ;;
        4)
            vercel list
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
}

# Run
if [ "$1" == "--mcp" ]; then
    deploy_with_mcp
elif [ "$1" == "--quick" ]; then
    quick_deploy
else
    show_menu
fi
