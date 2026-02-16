@echo off
setlocal

:: Check for argument
if "%~1"=="" (
    echo Usage: comfyui-add-node.bat ^<repo-url^>
    echo Example: comfyui-add-node.bat https://github.com/user/ComfyUI-SomeNode.git
    exit /b 1
)

:: Go to repo root (parent of \scripts)
cd /d "%~dp0.."
set "ROOT=%cd%"

set "nodesFile=%ROOT%\config\nodes.txt"

:: Make sure config dir exists
if not exist "%ROOT%\config" mkdir "%ROOT%\config"

:: Add the URL to nodes.txt
echo %~1>> "%nodesFile%"

echo Added to nodes.txt: %~1
echo Now run comfyui-setup.bat again (it will clone/update and install requirements).

pause
