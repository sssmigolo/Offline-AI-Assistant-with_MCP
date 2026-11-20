#!/usr/bin/env bash
# Fix for UR_RESULT_ERROR_OUT_OF_RESOURCES on Intel Iris Xe:
# 1. Disable oneDNN SDPA which crashes Level Zero on Intel integrated GPUs
# 2. Set -np 1 (single slot) so memory isn't multiplied across slots
# 3. Set -c 8192 for ample context to support MCP tool schemas + conversation

export GGML_SYCL_FA_ONEDNN=0
export PATH="$HOME/.local/bin:$PATH"
source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1

echo "Starting llama-server with Qwen3.5-4B on Intel Iris Xe GPU..."
echo "Port: 8080, Context: 8192 tokens, Slots: 1"

exec llama-server \
  -m "$HOME/models/Qwen3.5-4B-Q4_K_M.gguf \
  --alias Qwen3.5-4B \
  -ngl 99 \
  -c 8192 \
  -np 1 \
  --port 8080 \
  --host 127.0.0.1
