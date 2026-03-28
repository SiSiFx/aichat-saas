# Deploy AI Chat to Vercel (Free!)

## 🚀 One-Click Deploy

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/yourusername/ai-chat)

## 📋 Manual Deploy (2 Minutes)

### Step 1: Install Vercel CLI
```bash
npm i -g vercel
```

### Step 2: Deploy
```bash
cd /home/sisi/aichat
vercel
```

### Step 3: Done!
Your site is live at `https://ai-chat-yourname.vercel.app`

## 🔧 Custom Domain (Optional)

```bash
vercel domains add aichat.io
```

Or in Vercel Dashboard:
1. Go to Project Settings
2. Click "Domains"
3. Add your domain

## 📁 What Gets Deployed

All static HTML files:
- ✅ landing.html → yoursite.com/
- ✅ signup.html → yoursite.com/signup
- ✅ onboarding.html → yoursite.com/onboarding
- ✅ dashboard.html → yoursite.com/dashboard
- ✅ pricing.html → yoursite.com/pricing
- ✅ integrations.html → yoursite.com/integrations

## 🌍 Environment Variables

If you add a backend later, set env vars in Vercel:

```bash
vercel env add OPENAI_API_KEY
vercel env add DATABASE_URL
```

## 🔄 Auto-Deploy

Every push to GitHub auto-deploys:

```bash
git init
git add .
git commit -m "Initial commit"
git push origin main
# Vercel auto-deploys!
```

## 💰 Vercel Pricing

| Feature | Free Tier | Pro ($20/mo) |
|---------|-----------|--------------|
| Bandwidth | 100GB | 1TB |
| Build Minutes | 6,000 | 400,000 |
| Team Members | 1 | Unlimited |
| Analytics | Basic | Advanced |

**For AI Chat**: Free tier is plenty for starters!

## 🎉 You're Live!

Your AI Chat landing page is now live on:
- `https://ai-chat-yourname.vercel.app` (instant)
- `https://aichat.io` (custom domain)

**Time to deploy: 30 seconds.**
