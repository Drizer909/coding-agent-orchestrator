FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    nodejs npm \
    xvfb xdotool x11vnc \
    supervisor wget curl git zip unzip \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify

# Install Jupyter
RUN pip3 install jupyter

# Expose ports: 5900 (VNC), 6080 (noVNC), 8888 (Jupyter)
EXPOSE 5900 6080 8888

# Create workspace
RUN mkdir /workspace
WORKDIR /workspace

# Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY agent_entrypoint.sh /usr/local/bin/agent_entrypoint.sh
RUN chmod +x /usr/local/bin/agent_entrypoint.sh

CMD ["/usr/bin/supervisord"]

# Default entrypoint for agent jobs
ENTRYPOINT ["/usr/local/bin/agent_entrypoint.sh"] 