@echo off
:: Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run
) else (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:run
echo Installing Convert to Markdown...
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1"
pause
