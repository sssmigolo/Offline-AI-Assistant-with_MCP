# Local Qwen Assistant with Filesystem MCP

A private, 100% local AI computer assistant powered by **Qwen3.5-4B** accelerated on **Intel Iris Xe GPU** (via `llama.cpp` + SYCL). 

Integrated with the **Model Context Protocol (MCP)**, allowing the model to search, read, write, and manage files across your entire PC—featuring both a **Terminal CLI** and a browser-based **Web UI (Gradio)**.

---

## 🌟 Key Features

- **🧠 100% Local Inference**: Zero cloud dependencies; all prompt evaluation and text generation run on your local Intel Iris Xe / Arc GPU using `llama.cpp` compiled with SYCL.
- **📁 Full Filesystem MCP**: Uses `@modelcontextprotocol/server-filesystem` to safely read, edit, write, and search files across Linux root (`/`) and mounted Windows drives (`/mnt/c`, `/mnt/d`).
- **🌐 Interactive Web UI**: ChatGPT-style web interface with live visualization of MCP tool calls and filesystem execution results.
- **⚡ Intel Iris Xe Optimizations**:
  - `GGML_SYCL_FA_ONEDNN=0` to eliminate Level Zero `UR_RESULT_ERROR_OUT_OF_RESOURCES` crashes on integrated GPUs.
  - Single-slot memory management (`-np 1`) and 8,192 token context window (`-c 8192`) sized for full MCP tool schemas.

---

## 📂 Project Structure

```text
qwen-mcp/
├── agent.py            # Terminal interactive assistant
├── web_agent.py        # Gradio browser Web UI assistant
├── run_server.sh       # Launches llama-server with SYCL GPU flags
├── run_web.sh          # Starts the Web UI (auto-frees port 7860)
├── run_agent.sh        # Starts the Terminal CLI
├── requirements.txt    # Python dependencies
├── .gitignore          # Excludes virtual environments and models
└── README.md           # Documentation
```

---

## 🚀 Quick Start

### 1. Prerequisites
- **WSL2** (Ubuntu 24.04 recommended)
- **Node.js** (for `npx @modelcontextprotocol/server-filesystem`)
- **Intel oneAPI Base Toolkit** + Intel GPU compute drivers
- `llama.cpp` compiled with SYCL support (`llama-server`)
- Qwen GGUF model (e.g. `Qwen3.5-4B-Q4_K_M.gguf` stored in `~/models/`)

### 2. Environment Setup

```bash
git clone https://github.com/<your-username>/<your-repo-name>.git
cd <your-repo-name>

# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Launching

#### Step 1: Start the Local LLM Server (Terminal 1)
```bash
./run_server.sh
```
*Listens on `http://127.0.0.1:8080/v1`.*

#### Step 2: Start the Assistant Interface (Terminal 2)

**Option A — Web Browser UI (Recommended):**
```bash
./run_web.sh
```
Open your browser and navigate to: **`http://localhost:7860`**

**Option B — Terminal CLI:**
```bash
./run_agent.sh
```

---

## ⚙️ Configuration Details

### Server Parameters (`run_server.sh`)
```bash
export GGML_SYCL_FA_ONEDNN=0
llama-server \
  -m ~/models/Qwen3.5-4B-Q4_K_M.gguf \
  --alias Qwen3.5-4B \
  -ngl 99 \
  -c 8192 \
  -np 1 \
  --port 8080 \
  --host 127.0.0.1
```

---

## 📄 License
MIT License.
