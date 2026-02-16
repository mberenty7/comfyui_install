@echo off
setlocal enabledelayedexpansion

:: Uncomment next line to debug early exits:
:: pause

:: Go to repo root (parent of \scripts if run from scripts folder, otherwise current dir)
cd /d "%~dp0"
if exist "%~dp0..\ComfyUI" (
    cd /d "%~dp0.."
)
set "ROOT=%cd%"

echo Running from: %ROOT%

:: Default versions (overridden by config\versions.txt)
set "PYTHON_VERSION=3.12"
set "CUDA_VERSION=cu128"

:: Load config if exists (lines starting with # are comments)
set "configFile=%ROOT%\config\versions.txt"
if exist "%configFile%" (
    echo Loading config from %configFile%
    for /f "usebackq tokens=1,2 delims== eol=#" %%a in ("%configFile%") do (
        if /i "%%a"=="PYTHON_VERSION" set "PYTHON_VERSION=%%b"
        if /i "%%a"=="CUDA_VERSION" set "CUDA_VERSION=%%b"
    )
)

echo.
echo === Configuration ===
echo Python: %PYTHON_VERSION%
echo CUDA:   %CUDA_VERSION%
echo.

echo === Preflight checks ===

:: Check Git
where git >nul 2>&1 || (
    echo ERROR: Git not found. Install Git for Windows, then re-run.
    pause
    exit /b 1
)

:: Check Python
where py >nul 2>&1 || (
    echo ERROR: Python launcher not found. Install Python, then re-run.
    pause
    exit /b 1
)

:: Print Python version
echo Checking Python %PYTHON_VERSION%...
py -%PYTHON_VERSION% -c "import sys; print('Python:', sys.version)" || (
    echo ERROR: Python %PYTHON_VERSION% not found.
    pause
    exit /b 1
)

echo.
echo === Clone or update ComfyUI ===

if exist "%ROOT%\ComfyUI" (
    pushd "%ROOT%\ComfyUI"
    git fetch --all
    popd
) else (
    git clone https://github.com/Comfy-Org/ComfyUI.git ComfyUI
)

:: Optionally pin ComfyUI to a commit
set "pin="
set "pinFile=%ROOT%\config\comfy.commit.txt"
if exist "%pinFile%" (
    for /f "usebackq tokens=* eol=#" %%a in ("%pinFile%") do (
        if not defined pin set "pin=%%a"
    )
)
if defined pin (
    echo Pinning ComfyUI to commit: %pin%
    pushd "%ROOT%\ComfyUI"
    git checkout %pin%
    popd
) else (
    if exist "%pinFile%" echo No valid commit pin found in %pinFile%
)

echo.
echo === Create virtual environment ===

if exist "%ROOT%\venv" (
    echo Venv already exists, skipping creation.
) else (
    py -%PYTHON_VERSION% -m venv "%ROOT%\venv"
)

echo.
echo === Activate venv and upgrade pip tooling ===

"%ROOT%\venv\Scripts\python.exe" -m pip install --upgrade pip setuptools wheel

echo.
echo === Install PyTorch (CUDA %CUDA_VERSION%) ===

"%ROOT%\venv\Scripts\python.exe" -m pip install --upgrade torch torchvision torchaudio --index-url https://download.pytorch.org/whl/%CUDA_VERSION%

echo.
echo === Install ComfyUI requirements ===

"%ROOT%\venv\Scripts\python.exe" -m pip install -r "%ROOT%\ComfyUI\requirements.txt"

:: Optional extras
set "extraReq=%ROOT%\config\requirements.extra.txt"
if exist "%extraReq%" (
    echo.
    echo === Install extra requirements ===
    "%ROOT%\venv\Scripts\python.exe" -m pip install -r "%extraReq%"
)

echo.
echo === Install custom nodes from config\nodes.txt ===

set "nodesFile=%ROOT%\config\nodes.txt"
set "customNodesDir=%ROOT%\ComfyUI\custom_nodes"

if exist "%customNodesDir%" (
    echo Custom nodes dir exists.
) else (
    mkdir "%customNodesDir%"
)

if exist "%nodesFile%" (
    for /f "usebackq tokens=* eol=#" %%u in ("%nodesFile%") do (
        set "url=%%u"
        
        :: Extract repo name from URL (last part without .git)
        for %%f in ("!url!") do set "repoName=%%~nf"
        set "target=%customNodesDir%\!repoName!"
        
        if exist "!target!" (
            echo Updating !repoName!
            pushd "!target!"
            git pull
            popd
        ) else (
            echo Cloning !repoName!
            git clone "!url!" "!target!"
        )
        
        :: If the node has requirements.txt, install them
        if exist "!target!\requirements.txt" (
            echo Installing requirements for !repoName!
            "%ROOT%\venv\Scripts\python.exe" -m pip install -r "!target!\requirements.txt"
        )
    )
) else (
    echo No nodes.txt found, skipping node installs.
)

echo.
echo === Quick GPU sanity check ===

"%ROOT%\venv\Scripts\python.exe" -c "import torch; print('torch:', torch.__version__); print('cuda:', torch.version.cuda); print('is_available:', torch.cuda.is_available())"

echo.
echo === Done ===
echo Next: double-click scripts\02_run.bat

pause
