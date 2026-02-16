# ComfyUI Setup Scripts

Batch scripts for installing and managing ComfyUI on Windows with proper Python/CUDA version control.

## Quick Start

1. **Clone or download this repo** into your desired ComfyUI folder
2. **Create config files** (see Configuration below)
3. **Run `comfyui-setup.bat`** — installs everything
4. **Run `comfyui-run.bat`** — starts ComfyUI

## Scripts

| Script | Purpose |
|--------|---------|
| `comfyui-setup.bat` | Full installation: clones ComfyUI, creates venv, installs PyTorch + requirements, installs custom nodes |
| `comfyui-run.bat` | Starts ComfyUI (opens http://localhost:8188) |
| `comfyui-update.bat` | Pulls latest ComfyUI + updates all custom nodes |
| `comfyui-add-node.bat` | Adds a custom node repo to your config |

## Configuration

All config files go in the `config/` folder.

### `config/versions.txt` (required)

Copy from `config/versions.txt.example` and edit:

```ini
# Python version (must be installed on your system)
PYTHON_VERSION=3.12

# CUDA version for PyTorch
# Options: cu118, cu121, cu124, cu128, cpu
CUDA_VERSION=cu128
```

**Choosing CUDA version:**

Run `nvidia-smi` and check "CUDA Version" in the top right:

| nvidia-smi shows | Use |
|------------------|-----|
| 11.8 | cu118 |
| 12.1 | cu121 or cu118 |
| 12.4+ | cu124, cu121, or cu118 |
| 12.8+ | cu128, cu124, cu121, or cu118 |
| No GPU | cpu |

## Usage

### First Time Setup

```batch
:: 1. Create config folder and versions.txt
mkdir config
copy config\versions.txt.example config\versions.txt
:: Edit versions.txt with your Python/CUDA versions

:: 2. (Optional) Add custom nodes
echo https://github.com/ltdrdata/ComfyUI-Manager.git > config\nodes.txt

:: 3. Run setup
comfyui-setup.bat

:: 4. Start ComfyUI
comfyui-run.bat
```

### Updating

```batch
comfyui-update.bat
```

Pulls latest ComfyUI and all custom nodes, reinstalls requirements.

### Adding New Nodes

```batch
comfyui-add-node.bat https://github.com/user/ComfyUI-SomeNode.git
comfyui-setup.bat
```

### Run Options

```batch
:: Basic
comfyui-run.bat

:: Allow LAN access
comfyui-run.bat --listen 0.0.0.0

:: Low VRAM mode
comfyui-run.bat --lowvram

:: Different port
comfyui-run.bat --port 8080

:: Combine options
comfyui-run.bat --listen 0.0.0.0 --lowvram
```

## Troubleshooting

### "Python X.XX not found"

Install the Python version specified in `config/versions.txt`, or change it to a version you have installed.

Check installed versions:
```batch
py --list
```

### "not was unexpected at this time"

Config file may have special characters. Simplify `config/versions.txt` to just:
```ini
PYTHON_VERSION=3.12
CUDA_VERSION=cu128
```

### CUDA errors / torch not detecting GPU

1. Check `nvidia-smi` for your CUDA version
2. Update `config/versions.txt` with correct CUDA version
3. Delete `venv/` folder
4. Re-run `comfyui-setup.bat`

### Custom node errors

Try updating:
```batch
comfyui-update.bat
```

Or remove the problematic node from `ComfyUI/custom_nodes/` and re-run setup.

### `config/nodes.txt` (optional)

List of custom node repos to install, one per line:

```
# Lines starting with # are comments
https://github.com/ltdrdata/ComfyUI-Manager.git
https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
```

Add nodes with:
```batch
comfyui-add-node.bat https://github.com/user/ComfyUI-SomeNode.git
```

Then re-run `comfyui-setup.bat` to install them.

### `config/comfy.commit.txt` (optional)

Pin ComfyUI to a specific commit (for reproducibility):

```
abc123def456
```

Leave empty or delete to use latest.

### `config/requirements.extra.txt` (optional)

Additional pip packages to install:

```
opencv-python
scipy
```

## Directory Structure After Setup

```
your-comfy-folder/
├── config/
│   ├── versions.txt
│   ├── nodes.txt
│   └── ...
├── ComfyUI/
│   ├── main.py
│   ├── custom_nodes/
│   │   ├── ComfyUI-Manager/
│   │   └── ...
│   └── ...
├── venv/
│   └── ...
├── comfyui-setup.bat
├── comfyui-run.bat
├── comfyui-update.bat
└── comfyui-add-node.bat
```
