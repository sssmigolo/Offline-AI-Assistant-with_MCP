#!/bin/bash
set -e

echo "============================================"
echo "  Intel Iris Xe AI Dev Stack Installer"
echo "============================================"
echo ""

# ---- Phase 1: System Packages ----
echo "[1/7] Updating system and installing base tools..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y build-essential git curl wget cmake pkg-config software-properties-common gpg

# ---- Phase 2: Intel GPU Compute Runtime ----
echo ""
echo "[2/7] Installing Intel GPU compute runtime..."
sudo add-apt-repository -y ppa:kobuk-team/intel-graphics
sudo apt-get update -y
sudo apt-get install -y libze-intel-gpu1 libze1 intel-opencl-icd clinfo

echo "  → Verifying GPU..."
clinfo | head -20 || echo "  ⚠ clinfo did not detect a GPU (may be normal in WSL2 until drivers are loaded)"

# ---- Phase 3: Intel oneAPI Base Toolkit ----
echo ""
echo "[3/7] Installing Intel oneAPI Base Toolkit (this will take a while ~10-15 min)..."
wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
  sudo gpg --yes --dearmor --output /usr/share/keyrings/oneapi-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
  sudo tee /etc/apt/sources.list.d/oneAPI.list

sudo apt-get update -y
sudo apt-get install -y intel-oneapi-base-toolkit

# Add oneAPI to bashrc
if ! grep -q 'setvars.sh' ~/.bashrc; then
  echo 'source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1' >> ~/.bashrc
fi

# Source it for the rest of this script
source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1 || true

# ---- Phase 4: Miniconda ----
echo ""
echo "[4/7] Installing Miniconda..."
if [ ! -d "$HOME/miniconda3" ]; then
  wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
  bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
  rm /tmp/miniconda.sh
  "$HOME/miniconda3/bin/conda" init bash
else
  echo "  → Miniconda already installed, skipping."
fi

# Source conda for the rest of this script
eval "$($HOME/miniconda3/bin/conda shell.bash hook)"

# ---- Phase 5: Python AI Environment ----
echo ""
echo "[5/7] Creating Python AI environment and installing frameworks..."
conda create -n ai python=3.11 -y || true
conda activate ai

pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install intel-extension-for-pytorch oneccl-bind-pt --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/ || \
  echo "  ⚠ IPEX install had issues - may need manual install later"
pip install openvino openvino-dev
pip install transformers accelerate datasets huggingface-hub
pip install jupyter notebook

# ---- Phase 6: llama.cpp with SYCL ----
echo ""
echo "[6/7] Building llama.cpp with SYCL (Intel GPU) support..."
cd "$HOME"
if [ ! -d "llama.cpp" ]; then
  git clone https://github.com/ggerganov/llama.cpp
fi
cd llama.cpp
mkdir -p build && cd build

cmake .. -DGGML_SYCL=ON -DCMAKE_C_COMPILER=icx -DCMAKE_CXX_COMPILER=icpx 2>/dev/null || \
  cmake .. -DGGML_SYCL=OFF  # Fallback to CPU-only if SYCL compile fails
cmake --build . --config Release -j$(nproc)

# ---- Phase 7: Summary ----
echo ""
echo "============================================"
echo "  ✅ Installation Complete!"
echo "============================================"
echo ""
echo "Installed:"
echo "  • Ubuntu 24.04 system tools"
echo "  • Intel GPU compute runtime"
echo "  • Intel oneAPI Base Toolkit"
echo "  • Miniconda + Python 3.11 (env: ai)"
echo "  • PyTorch + IPEX + OpenVINO"
echo "  • Hugging Face tools"
echo "  • Jupyter Notebook"
echo "  • llama.cpp"
echo ""
echo "To get started:"
echo "  conda activate ai"
echo "  python -c \"import torch; print('PyTorch:', torch.__version__)\""
echo ""
echo "To run a local LLM, download a model:"
echo "  cd ~/llama.cpp/build"
echo "  wget https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf"
echo "  ./bin/llama-cli -m Phi-3-mini-4k-instruct-q4.gguf -p 'Hello!' -ngl 99"
echo ""
