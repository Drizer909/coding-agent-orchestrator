# Quick Start Guide

Get your coding agent orchestrator running in minutes!

## Prerequisites

- Docker and Docker Compose installed
- Git (to clone the repository)

## Option 1: Docker Compose (Recommended for local development)

### 1. Navigate to deployment directory
```bash
cd deployment
```

### 2. Run the deployment script
```bash
./scripts/deploy.sh -m docker-compose
```

### 3. Test the deployment
```bash
# Check if the service is running
curl http://localhost:8001/docs

# Submit a test job
curl -X POST http://localhost:8001/schedule \
  -H 'Content-Type: application/json' \
  -d '{"task": "Build me a simple todo app in React"}'
```

## Option 2: Manual Docker Compose

### 1. Build and start services
```bash
cd deployment
docker-compose up -d
```

### 2. Check status
```bash
docker-compose ps
```

## Option 3: Local Development

### 1. Install Python dependencies
```bash
cd backend
pip install -r ../deployment/requirements.txt
```

### 2. Start the server
```bash
uvicorn main:app --reload --port 8001
```

## Access Points

- **API Documentation**: http://localhost:8001/docs
- **Health Check**: http://localhost:8001/health
- **API Base URL**: http://localhost:8001

## API Usage

### Submit a job
```bash
curl -X POST http://localhost:8001/schedule \
  -H 'Content-Type: application/json' \
  -d '{"task": "Your coding task here"}'
```

### Check job status
```bash
curl http://localhost:8001/status/<job_id>
```

### Download result
```bash
curl -O http://localhost:8001/download/<job_id>
```

## Troubleshooting

### Common Issues

1. **Port 8001 already in use**
   ```bash
   lsof -i :8001
   kill -9 <PID>
   ```

2. **Docker permission issues**
   ```bash
   sudo chmod 666 /var/run/docker.sock
   ```

3. **Service not starting**
   ```bash
   docker-compose logs orchestrator
   ```

### Cleanup

To remove all deployed resources:
```bash
./scripts/cleanup.sh -m all
```

## Next Steps

- Check the full [deployment guide](README.md) for production deployment
- Explore the [API documentation](http://localhost:8001/docs) for more endpoints
- Customize the agent container for your specific needs 