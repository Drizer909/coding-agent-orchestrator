# Coding Agent Orchestration Server

This project is a **coding agent orchestration system**. It lets you submit a coding task (like "Build me a todo app in React") and automatically spins up a secure, isolated environment to work on that task.

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
1. Start the server: `uvicorn main:app --reload --port 8001` (from the backend folder)
2. Submit a task:
   ```sh
   curl -X POST http://localhost:8001/schedule -H 'Content-Type: application/json' -d '{"task": "Build me a todo app in React"}'
   ```
3. Check status:
   ```sh
   curl http://localhost:8001/status/<job_id>
   ```
4. Download result:
   ```sh
   curl -O http://localhost:8001/download/<job_id>
   ```

## What is actually being built?
- Right now, the agent simulates project creation (for demo purposes).
- You can extend the agent to do real coding, run scripts, or anything you want in a safe environment!

## API Endpoints

- `POST /schedule` — Accepts a plain-text task, spins up an agent container, returns job ID.
- `GET /status/{id}` — Returns job status and download link if complete.
- `GET /download/{id}` — Download the generated project as a zip.

## Agent Container
- Exposes:
  - Jupyter Notebook: http://localhost:8888
  - noVNC (GUI): http://localhost:6080
- Mounts `/workspace` for job files.

## Example Usage

1. Schedule a job:
   ```sh
   curl -X POST http://localhost:8001/schedule -H 'Content-Type: application/json' -d '{"task": "Build me a todo app in React"}'
   ```
2. Check status:
   ```sh
   curl http://localhost:8001/status/<job_id>
   ```
3. Download result:
   ```sh
   curl -O http://localhost:8001/download/<job_id>
   ```

## Kubernetes Job Example (Bonus)

See `backend/k8s-job.yaml` for a sample K8s job to run the agent at scale. 