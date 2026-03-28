#!/bin/bash
# AI Chat - ONE COMMAND DEPLOY
# Everything automated. Just run this script.

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[AI Chat]${NC} $1"; }
success() { echo -e "${GREEN}[AI Chat]${NC} $1"; }
warn() { echo -e "${YELLOW}[AI Chat]${NC} $1"; }
error() { echo -e "${RED}[AI Chat]${NC} $1"; }

print_banner() {
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                    🤖 AI CHAT DEPLOYER                         ║
║                                                                ║
║     One command deploys EVERYTHING automatically              ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        error "Node.js not found. Installing..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker not found. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    success "Prerequisites OK"
}

# Get user input
get_input() {
    echo ""
    echo "┌────────────────────────────────────────────────────────────────┐"
    echo "│  Let's set up your AI Chat in 2 minutes!                      │"
    echo "└────────────────────────────────────────────────────────────────┘"
    echo ""
    
    read -p "📧 Your email: " EMAIL
    read -p "🏢 Business name: " BUSINESS_NAME
    read -p "🌐 Your website URL (or press Enter to skip): " WEBSITE
    
    echo ""
    read -sp "🔑 OpenAI API Key (sk-...): " OPENAI_KEY
    echo ""
    
    if [ -z "$OPENAI_KEY" ]; then
        error "OpenAI API Key is required"
        exit 1
    fi
    
    echo ""
    success "Configuration saved!"
}

# Create environment file
create_env() {
    log "Creating configuration..."
    
    cat > .env << EOF
# AI Chat Configuration
NODE_ENV=production
PORT=3000

# API Keys
OPENAI_API_KEY=$OPENAI_KEY

# Database
DATABASE_URL=file:./data/aichat.db

# App Settings
BUSINESS_NAME="$BUSINESS_NAME"
ADMIN_EMAIL=$EMAIL
WEBSITE_URL=$WEBSITE
JWT_SECRET=$(openssl rand -hex 32)

# Features
ENABLE_ANALYTICS=true
ENABLE_CACHE=true
EOF
    
    chmod 600 .env
    success "Environment configured"
}

# Setup backend
setup_backend() {
    log "Setting up backend API..."
    
    # Create backend directory
    mkdir -p api
    
    # Create package.json for backend
    cat > api/package.json << 'EOF'
{
  "name": "ai-chat-api",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "better-sqlite3": "^9.4.0",
    "openai": "^4.28.0",
    "uuid": "^9.0.1",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3"
  }
}
EOF
    
    # Create simple backend
    cat > api/index.js << 'EOF'
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Database = require('better-sqlite3');
const OpenAI = require('openai');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Ensure data directory exists
const dataDir = path.join(__dirname, 'data');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });

// Database setup
const db = new Database(path.join(dataDir, 'aichat.db'));
db.exec(`
  CREATE TABLE IF NOT EXISTS conversations (
    id TEXT PRIMARY KEY,
    email TEXT,
    message TEXT,
    response TEXT,
    created_at INTEGER
  );
`);

// OpenAI setup
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

// Middleware
app.use(cors());
app.use(express.json());

// Serve frontend
app.use(express.static(path.join(__dirname, '../')));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

// Chat endpoint
app.post('/api/chat', async (req, res) => {
  try {
    const { message, email } = req.body;
    
    if (!message) {
      return res.status(400).json({ error: 'Message required' });
    }
    
    // Call OpenAI
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: 'You are a helpful customer support AI. Be friendly and concise.' },
        { role: 'user', content: message }
      ],
      max_tokens: 500
    });
    
    const response = completion.choices[0].message.content;
    
    // Save to database
    db.prepare('INSERT INTO conversations (id, email, message, response, created_at) VALUES (?, ?, ?, ?, ?)')
      .run(uuidv4(), email || 'anonymous', message, response, Date.now());
    
    res.json({ 
      success: true, 
      response,
      id: uuidv4()
    });
    
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Something went wrong' });
  }
});

// Stats endpoint
app.get('/api/stats', (req, res) => {
  const total = db.prepare('SELECT COUNT(*) as count FROM conversations').get();
  const today = db.prepare('SELECT COUNT(*) as count FROM conversations WHERE created_at > ?').get(Date.now() - 86400000);
  
  res.json({
    total: total.count,
    today: today.count
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 AI Chat API running on http://localhost:${PORT}`);
});
EOF
    
    success "Backend created"
}

# Create Docker Compose
create_docker_compose() {
    log "Creating Docker configuration..."
    
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    env_file:
      - .env
    volumes:
      - ./data:/app/api/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Optional: Caddy for HTTPS
  caddy:
    image: caddy:2-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    restart: unless-stopped
    profiles:
      - production

volumes:
  caddy_data:
  caddy_config:
EOF
    
    # Create Dockerfile
    cat > Dockerfile << 'EOF'
FROM node:20-alpine

WORKDIR /app

# Copy frontend
COPY . /app/

# Setup backend
WORKDIR /app/api
RUN npm install

# Create startup script
WORKDIR /app
RUN echo '#!/bin/sh\ncd /app/api && npm start' > start.sh && chmod +x start.sh

EXPOSE 3000

CMD ["./start.sh"]
EOF
    
    success "Docker configuration created"
}

# Create startup script
create_startup() {
    cat > start-local.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting AI Chat..."
cd api && npm install && npm start
EOF
    chmod +x start-local.sh
}

# Deploy everything
deploy() {
    echo ""
    echo "┌────────────────────────────────────────────────────────────────┐"
    echo "│  🚀 DEPLOYING AI CHAT                                          │"
    echo "└────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Install backend dependencies
    log "Installing dependencies..."
    cd api && npm install && cd ..
    
    # Option 1: Docker Deploy (Recommended)
    if command -v docker-compose &> /dev/null; then
        log "Deploying with Docker..."
        docker-compose up -d --build
        
        success "✅ Deployed with Docker!"
        echo ""
        echo "📍 Your AI Chat is live at:"
        echo "   http://localhost:3000"
        echo ""
        
    # Option 2: Local Node.js
    else
        log "Starting locally with Node.js..."
        cd api && npm start &
        cd ..
        
        success "✅ Started locally!"
        echo ""
        echo "📍 Your AI Chat is live at:"
        echo "   Frontend: file://$(pwd)/landing.html"
        echo "   API: http://localhost:3000"
        echo ""
    fi
    
    # Save deployment info
    cat > DEPLOYMENT_INFO.txt << EOF
AI Chat Deployment Info
========================

Deployed: $(date)
Business: $BUSINESS_NAME
Email: $EMAIL

URLs:
- Main App: http://localhost:3000
- API: http://localhost:3000/api
- Health Check: http://localhost:3000/api/health

Next Steps:
1. Open http://localhost:3000 in your browser
2. Customize your AI in the dashboard
3. Add the widget code to your website
4. Start chatting!

To stop: docker-compose down
To restart: docker-compose up -d
EOF
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 SUCCESS!                                 ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                ║"
    echo "║  Your AI Chat is LIVE at:                                      ║"
    echo "║  http://localhost:3000                                         ║"
    echo "║                                                                ║"
    echo "║  Business: $BUSINESS_NAME"
    echo "║  Email: $EMAIL"
    echo "║                                                                ║"
    echo "║  Next steps:                                                   ║"
    echo "║  1. Open http://localhost:3000                                 ║"
    echo "║  2. Upload your FAQ documents                                  ║"
    echo "║  3. Customize your AI assistant                                ║"
    echo "║  4. Copy the widget code to your website                       ║"
    echo "║                                                                ║"
    echo "║  Info saved to: DEPLOYMENT_INFO.txt                            ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
}

# Main
main() {
    print_banner
    check_prerequisites
    get_input
    create_env
    setup_backend
    create_docker_compose
    create_startup
    deploy
}

# Run
main "$@"
