#!/bin/bash
set -e
TASK="$1"
echo "[INFO] Agent started with task: $TASK" | tee /workspace/agent.log

# Simulate project generation
mkdir -p /workspace/output
cat <<EOF > /workspace/output/README.md
# Generated Project

Task: $TASK

This is a simulated project output.
EOF

# Zip the output
cd /workspace
zip -r result.zip output

echo "[INFO] Project generated and zipped at /workspace/result.zip" | tee -a /workspace/agent.log 