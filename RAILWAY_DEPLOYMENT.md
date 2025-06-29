# 🚀 Railway Deployment Guide

## Quick Deploy to Railway (Free)

### 1. Prerequisites
- GitHub account
- Railway account (free at railway.app)

### 2. Deploy Steps

#### Option A: Via Railway Dashboard (Recommended)
1. Go to [railway.app](https://railway.app)
2. Sign up/Login with GitHub
3. Click "New Project"
4. Select "Deploy from GitHub repo"
5. Choose your repository: `Drizer909/coding-agent-orchestrator`
6. Railway will automatically detect and deploy

#### Option B: Via Railway CLI
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Deploy
railway up
```

### 3. Environment Variables
Railway will automatically set:
- `PORT`: Railway assigns this
- `JOBS_DIR`: Set to `/app/jobs`
- `AGENT_IMAGE`: Set to `agent-coding:latest`

### 4. Access Your Deployed App
After deployment, Railway will provide a URL like:
```
https://your-app-name.railway.app
```

### 5. Test Your Deployment
```bash
# Health check
curl https://your-app-name.railway.app/health

# API docs
open https://your-app-name.railway.app/docs

# Submit a job
curl -X POST https://your-app-name.railway.app/schedule \
  -H 'Content-Type: application/json' \
  -d '{"task": "Build me a todo app in React"}'
```

### 6. Share Your Link
Once deployed, share this link with anyone:
```
https://your-app-name.railway.app/docs
```

## 🎉 That's it! Your app will be live and accessible to anyone! 