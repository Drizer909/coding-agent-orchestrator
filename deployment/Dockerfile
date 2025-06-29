FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies including Docker
RUN apt-get update && apt-get install -y \
    curl \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add Docker's official GPG key
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
RUN apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY deployment/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code from backend directory
COPY backend/main.py ./main.py
COPY backend/context_manager.py ./context_manager.py

# Create jobs directory
RUN mkdir -p jobs

# Create non-root user
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app

# Add app user to docker group
RUN usermod -aG docker app

# Expose port
EXPOSE 8001

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8001/health || exit 1

# Switch to app user
USER app

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"] 