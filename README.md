# Coding Agent Orchestration Server

This project is a **coding agent orchestration system**. It lets you submit a coding task (like "Build me a todo app in React") and automatically spins up a secure, isolated environment to work on that task.

## 🚀 Quick Deploy

### Railway (Recommended - Free)
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/new?template=https://github.com/Drizer909/coding-agent-orchestrator)

1. Click the Railway button above
2. Connect your GitHub account
3. Deploy automatically
4. Get your public URL instantly

### Local Deployment
```bash
git clone https://github.com/Drizer909/coding-agent-orchestrator.git
cd coding-agent-orchestrator/deployment
./scripts/deploy.sh -m docker-compose
```

## How does it work?

1. **Orchestration Server (FastAPI):**
   - You send a task to the server using a simple API.
   - The server creates a new job and starts a Docker container (an "agent") to work on your task.

2. **Agent Container:**
   - The agent runs in a sandboxed Docker container with tools for coding, running code, and even GUI automation.
   - It simulates building a project for your task and saves the result as a zip file.

3. **Job Status & Download:**
   - You can check the status of your job (is it running, done, or failed?).
   - When the job is done, you can download the generated project as a zip file.

## Why is this cool?
- **Security:** Each job runs in its own isolated container.
- **Scalability:** You can run many jobs at once, and even scale up using Kubernetes.
- **Extensible:** You can add more tools, languages, or smarter agent logic.

## How do I use it?

### Railway Deployment
1. Deploy using the Railway button above
2. Access your API at the provided URL
3. Submit a task:
   ```bash
   curl -X POST https://your-app.railway.app/schedule \
     -H 'Content-Type: application/json' \
     -d '{"task": "Build me a todo app in React"}'
   ```

### Local Deployment
1. Start the server: `uvicorn main:app --reload --port 8001` (from the backend folder)
2. Submit a task:
   ```bash
   curl -X POST http://localhost:8001/schedule \
     -H 'Content-Type: application/json' \
     -d '{"task": "Build me a todo app in React"}'
   ```
3. Check status:
   ```bash
   curl http://localhost:8001/status/<job_id>
   ```
4. Download result:
   ```bash
   curl -O http://localhost:8001/download/<job_id>
   ```

## What is actually being built?
- **Railway Deployment:** Simulates project creation with mock files
- **Local Deployment:** Uses Docker containers for real isolated execution
- You can extend the agent to do real coding, run scripts, or anything you want in a safe environment!

## API Endpoints

- `POST /schedule` — Accepts a plain-text task, spins up an agent container, returns job ID.
- `GET /status/{id}` — Returns job status and download link if complete.
- `GET /download/{id}` — Download the generated project as a zip.
- `GET /health` — Health check endpoint.
- `GET /docs` — Interactive API documentation.

## Agent Container (Local Only)
- Exposes:
  - Jupyter Notebook: http://localhost:8888
  - noVNC (GUI): http://localhost:6080
- Mounts `/workspace` for job files.

## Example Usage

1. Schedule a job:
   ```bash
   curl -X POST https://your-app.railway.app/schedule \
     -H 'Content-Type: application/json' \
     -d '{"task": "Build me a todo app in React"}'
   ```
2. Check status:
   ```bash
   curl https://your-app.railway.app/status/<job_id>
   ```
3. Download result:
   ```bash
   curl -O https://your-app.railway.app/download/<job_id>
   ```

## Deployment Options

- **Railway** (Recommended): One-click deployment with public URL
- **Docker Compose**: Local development with full Docker support
- **Kubernetes**: Production deployment with scaling

## Kubernetes Job Example (Bonus)

See `backend/k8s-job.yaml` for a sample K8s job to run the agent at scale.

## About

A coding agent orchestration system that demonstrates containerized task execution with FastAPI. 