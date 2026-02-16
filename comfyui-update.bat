@echo off
setlocal enabledelayedexpansion

:: Go to repo root (parent of \scripts)
cd /d "%~dp0.."
set "ROOT=%cd%"

echo Updating ComfyUI and nodes...

:: Update ComfyUI
if exist "%ROOT%\ComfyUI" (
    pushd "%ROOT%\ComfyUI"
    git pull
    popd
)

:: Update custom nodes
set "customNodesDir=%ROOT%\ComfyUI\custom_nodes"

if exist "%customNodesDir%" (
    for /d %%d in ("%customNodesDir%\*") do (
        if exist "%%d\.git" (
            echo Updating %%~nxd
            pushd "%%d"
            git pull
            popd
        )
    )
)

echo.
echo Re-installing requirements (to catch node changes)...

"%ROOT%\venv\Scripts\python.exe" -m pip install -r "%ROOT%\ComfyUI\requirements.txt"

:: Reinstall node requirements if they exist
if exist "%customNodesDir%" (
    for /d %%d in ("%customNodesDir%\*") do (
        if exist "%%d\requirements.txt" (
            echo Installing requirements for %%~nxd
            "%ROOT%\venv\Scripts\python.exe" -m pip install -r "%%d\requirements.txt"
        )
    )
)

echo.
echo Done.
pause
