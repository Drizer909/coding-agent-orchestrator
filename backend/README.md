# Coding Agent Orchestration Server

## Build Agent Docker Image

```sh
cd backend
docker build -t agent-coding .
```

## Run Orchestration Server

```sh
uvicorn main:app --reload
```

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
   curl -X POST http://localhost:8000/schedule -H 'Content-Type: application/json' -d '{"task": "Build me a todo app in React"}'
   ```
2. Check status:
   ```sh
   curl http://localhost:8000/status/<job_id>
   ```
3. Download result:
   ```sh
   curl -O http://localhost:8000/download/<job_id>
   ```

## Agent Entrypoint
- The agent container runs `/usr/local/bin/agent_entrypoint.sh <task>`
- Simulates project generation and zips output to `/workspace/result.zip`
- Logs to `/workspace/agent.log`

## Context Management
- See `context_manager.py` for file-based context save/load/prune logic.

## Kubernetes Job Example
- See `k8s-job.yaml` for a sample K8s job to run the agent at scale. 