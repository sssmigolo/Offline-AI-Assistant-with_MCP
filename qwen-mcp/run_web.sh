#!/usr/bin/env bash
cd /home/migg/qwen-mcp

# Free port 7860 if another instance is already running
fuser -k 7860/tcp 2>/dev/null || true

source .venv/bin/activate
echo "Starting Qwen Web UI..."
echo "Open your browser to: http://localhost:7860"
python web_agent.py
