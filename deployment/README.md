# Coding Agent Orchestrator - Deployment Guide

This guide covers deploying the coding agent orchestrator to different environments.

## Architecture Overview

The system consists of:
- **FastAPI Server**: Main orchestration server that manages jobs
- **Agent Containers**: Docker containers that execute coding tasks
- **Job Storage**: Local file system for job results

## Prerequisites

- Docker and Docker Compose
- Python 3.8+
- For Kubernetes: kubectl and a Kubernetes cluster

## Deployment Options

### 1. Local Development Deployment

#### Quick Start
```bash
cd backend
pip install fastapi uvicorn docker
uvicorn main:app --reload --port 8001
```

#### Using Docker Compose
```bash
docker-compose up -d
```

### 2. Production Docker Deployment

#### Build and Run
```bash
# Build the orchestrator
docker build -t coding-orchestrator:latest .

# Build the agent image
cd backend
docker build -t agent-coding:latest .

# Run the orchestrator
docker run -d \
  --name coding-orchestrator \
  -p 8001:8001 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/jobs:/app/jobs \
  coding-orchestrator:latest
```

### 3. Kubernetes Deployment

#### Prerequisites
- Kubernetes cluster (minikube, GKE, EKS, AKS, etc.)
- kubectl configured

#### Deploy to Kubernetes
```bash
kubectl apply -f k8s/
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `JOBS_DIR` | Directory for job storage | `jobs` |
| `AGENT_IMAGE` | Docker image for agents | `agent-coding` |
| `PORT` | Server port | `8001` |
| `HOST` | Server host | `0.0.0.0` |

## Security Considerations

### Production Security Checklist

- [ ] Use HTTPS/TLS
- [ ] Implement authentication/authorization
- [ ] Use secrets management for sensitive data
- [ ] Configure resource limits
- [ ] Set up monitoring and logging
- [ ] Use non-root containers
- [ ] Implement rate limiting
- [ ] Regular security updates

### Docker Security
- [ ] Use specific image tags (not `latest`)
- [ ] Scan images for vulnerabilities
- [ ] Use multi-stage builds
- [ ] Minimize attack surface

## Monitoring and Logging

### Health Checks
```bash
curl http://localhost:8001/health
```

### Logs
```bash
# Docker logs
docker logs coding-orchestrator

# Kubernetes logs
kubectl logs -f deployment/coding-orchestrator
```

## Scaling

### Horizontal Scaling
- Use Kubernetes HPA (Horizontal Pod Autoscaler)
- Load balancer for multiple instances
- Shared storage for job results

### Vertical Scaling
- Increase CPU/memory limits
- Optimize agent container resources

## Troubleshooting

### Common Issues

1. **Docker socket permission denied**
   ```bash
   sudo chmod 666 /var/run/docker.sock
   ```

2. **Port already in use**
   ```bash
   lsof -i :8001
   kill -9 <PID>
   ```

3. **Agent container fails to start**
   ```bash
   docker logs agent_<job_id>
   ```

## Performance Optimization

- Use persistent volumes for job storage
- Implement job cleanup policies
- Optimize agent container startup time
- Use connection pooling for database (if added)

## Backup and Recovery

- Regular backups of job results
- Database backups (if using persistent storage)
- Configuration backups
- Disaster recovery plan 