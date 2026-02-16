@echo off
cd /d "%~dp0"

:: Activate virtual environment
call venv\Scripts\activate.bat

:: Run ComfyUI
:: Add flags as needed:
::   --listen 0.0.0.0    Allow LAN access
::   --port 8188         Change port (default 8188)
::   --lowvram           For GPUs with less VRAM
::   --cpu               Run on CPU only

python ComfyUI\main.py %*

pause
