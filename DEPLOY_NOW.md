# 🚀 DEPLOY AI CHAT NOW (Choose Your Way)

## ⚡ EASIEST: Vercel (30 Seconds) ⭐ PICK THIS

```bash
# 1. Install Vercel (one time)
npm i -g vercel

# 2. Set your OpenAI key
vercel env add OPENAI_API_KEY
# Enter: sk-your-openai-key-here

# 3. Deploy
vercel --prod
```

**✅ Done! Your site is live at:**
`https://ai-chat-yourname.vercel.app`

**What you get:**
- Frontend + Backend API
- Global CDN (fast worldwide)
- Free HTTPS
- Auto-deploys
- **FREE hosting**

---

## 🐳 FULL CONTROL: Docker (2 Minutes)

```bash
# Just run:
./deploy.sh

# Or manually:
docker-compose up -d
```

**✅ Done! Your site is live at:**
`http://localhost:3000`

---

## 📋 STEP-BY-STEP (Complete Guide)

### Step 1: Get OpenAI API Key
1. Go to [platform.openai.com](https://platform.openai.com)
2. Sign up / Log in
3. Go to API Keys
4. Create new key (starts with `sk-`)
5. Copy it

### Step 2: Choose Deploy Method

| If you want... | Run this | Time |
|----------------|----------|------|
| **Easiest, no maintenance** | `vercel --prod` | 30 sec |
| **Full control, own server** | `./deploy.sh` | 2 min |
| **Enterprise, scale big** | `docker-compose up -d` | 2 min |

### Step 3: Open Your Site
```
Vercel:    https://ai-chat-yourname.vercel.app
Docker:    http://localhost:3000 (or your server IP)
```

### Step 4: Configure
1. Open your URL
2. Go through onboarding (2 minutes)
3. Upload your FAQ documents
4. Customize your AI
5. Copy widget code to your website

---

## 🌍 Add Your Domain (Optional)

### Vercel:
```bash
vercel domains add yourdomain.com
```

Then update DNS at your domain registrar:
- Type: CNAME
- Name: @
- Value: cname.vercel-dns.com

### Docker (with HTTPS):
```bash
# Edit Caddyfile with your domain
docker-compose --profile production up -d
```

---

## 💰 Costs

### Vercel (Free Tier):
- Hosting: **FREE**
- Bandwidth: 100GB/month FREE
- API calls: Unlimited (your OpenAI key)
- **Total: FREE + OpenAI usage (~$0.01/chat)**

### Docker (Your Server):
- VPS: $5-20/month (DigitalOcean, AWS, etc.)
- **Total: $5-20/month + OpenAI usage**

---

## 🎯 Which Should I Pick?

**Pick Vercel if:**
- ✅ You want the easiest setup
- ✅ You don't want to manage servers
- ✅ You want auto-scaling
- ✅ You want free HTTPS + CDN

**Pick Docker if:**
- ✅ You have your own server
- ✅ You want full control
- ✅ You need custom integrations
- ✅ You have a technical team

---

## 🔧 Troubleshooting

### "vercel command not found"
```bash
npm install -g vercel
```

### "docker command not found"
Install Docker: https://docs.docker.com/get-docker/

### "OPENAI_API_KEY not set"
```bash
vercel env add OPENAI_API_KEY
# or for Docker, edit .env file
```

### "Port 3000 already in use"
```bash
# Change port in docker-compose.yml
# Or stop other services using port 3000
```

---

## 🎉 You're Live!

After deploying, your AI Chat is ready:

1. **Landing Page**: Your marketing site
2. **Sign Up**: Users can register
3. **Dashboard**: Control your AI
4. **API**: Backend at `/api/chat`

**Next:** Go to your URL and complete the 2-minute onboarding!

---

**Need help?** Open an issue or email help@aichat.io

**Deploy now and get your first AI customer in 5 minutes!** 🚀
