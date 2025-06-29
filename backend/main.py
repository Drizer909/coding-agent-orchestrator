import os
import uuid
import shutil
import subprocess
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import Dict

app = FastAPI(
    title="Coding Agent Orchestrator",
    description="A system for orchestrating coding tasks in isolated containers",
    version="1.0.0"
)

JOBS_DIR = "jobs"
AGENT_IMAGE = "agent-coding"

os.makedirs(JOBS_DIR, exist_ok=True)

class ScheduleRequest(BaseModel):
    task: str

class ScheduleResponse(BaseModel):
    job_id: str

class StatusResponse(BaseModel):
    status: str
    download_url: str = None

# In-memory job status (for demo; in prod use persistent store)
jobs: Dict[str, Dict] = {}

@app.get("/health")
def health_check():
    """Health check endpoint for monitoring"""
    return {"status": "healthy", "service": "coding-agent-orchestrator"}

@app.get("/")
def root():
    """Root endpoint with basic info"""
    return {
        "message": "Coding Agent Orchestrator API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }

@app.post("/schedule", response_model=ScheduleResponse)
def schedule_job(req: ScheduleRequest):
    job_id = str(uuid.uuid4())
    job_dir = os.path.join(JOBS_DIR, job_id)
    os.makedirs(job_dir, exist_ok=True)
    # Save task
    with open(os.path.join(job_dir, "task.txt"), "w") as f:
        f.write(req.task)
    # Start agent container (simulate Firecracker VM)
    # Mount job_dir as /workspace in container
    cmd = [
        "docker", "run", "-d",
        "-v", f"{os.path.abspath(job_dir)}:/workspace",
        "--name", f"agent_{job_id}",
        AGENT_IMAGE,
        req.task
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    jobs[job_id] = {"status": "running", "dir": job_dir}
    return {"job_id": job_id}

@app.get("/status/{job_id}", response_model=StatusResponse)
def get_status(job_id: str, request: Request):
    job = jobs.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    # Check if result exists
    result_zip = os.path.join(job["dir"], "result.zip")
    if os.path.exists(result_zip):
        url = str(request.base_url) + f"download/{job_id}"
        return {"status": "complete", "download_url": url}
    # Check if container is still running
    container_name = f"agent_{job_id}"
    status = subprocess.getoutput(f"docker inspect -f '{{{{.State.Running}}}}' {container_name}")
    if status.strip() == "true":
        return {"status": "running"}
    else:
        # If not running and no result, mark as failed
        return {"status": "failed"}

@app.get("/download/{job_id}")
def download_result(job_id: str):
    job = jobs.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    result_zip = os.path.join(job["dir"], "result.zip")
    if not os.path.exists(result_zip):
        raise HTTPException(status_code=404, detail="Result not ready")
    return FileResponse(result_zip, filename="result.zip") 