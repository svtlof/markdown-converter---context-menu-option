# Install script for Convert to Markdown Windows context menu
# Requires Administrator privileges

#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Convert to Markdown - Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Python
Write-Host "[1/4] Checking Python..." -ForegroundColor Cyan
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    Write-Host "X Python not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Python first:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://www.python.org/downloads/" -ForegroundColor White
    Write-Host "  2. Run installer and CHECK the box: 'Add Python to PATH'" -ForegroundColor White
    Write-Host "  3. Restart your terminal/computer after installation" -ForegroundColor White
    Write-Host "  4. Run this installer again" -ForegroundColor White
    Write-Host ""
    pause
    exit 1
}

$pythonVersion = & python --version 2>&1
Write-Host "  + Python found: $pythonVersion" -ForegroundColor Green

# Check pip
Write-Host ""
Write-Host "[2/4] Checking pip..." -ForegroundColor Cyan
try {
    $pipVersion = & python -m pip --version 2>&1
    Write-Host "  + pip found: $pipVersion" -ForegroundColor Green
} catch {
    Write-Host "X pip not found!" -ForegroundColor Red
    Write-Host "Please reinstall Python with pip included." -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""
Write-Host "[3/4] Installing markitdown package..." -ForegroundColor Cyan
Write-Host "  This may take a minute..." -ForegroundColor Gray
try {
    & python -m pip install --upgrade "markitdown[all]" --quiet
    Write-Host "  + markitdown installed successfully" -ForegroundColor Green
} catch {
    Write-Host "X Failed to install markitdown: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try running manually:" -ForegroundColor Yellow
    Write-Host "  python -m pip install markitdown[all]" -ForegroundColor White
    pause
    exit 1
}

# Verify markitdown is installed and accessible
Write-Host ""
Write-Host "[4/4] Verifying markitdown installation..." -ForegroundColor Cyan
$markitdownPath = $null
try {
    $markitdownPath = (Get-Command markitdown -ErrorAction SilentlyContinue).Source
} catch {}

if (-not $markitdownPath) {
    Write-Host "  ! markitdown installed but not found in PATH" -ForegroundColor Yellow
    Write-Host "  Checking if it works via Python module..." -ForegroundColor Gray
    try {
        $testOutput = & python -m markitdown --version 2>&1
        Write-Host "  + markitdown accessible via: python -m markitdown" -ForegroundColor Green
    } catch {
        Write-Host "X markitdown not working. Installation may have failed." -ForegroundColor Red
        pause
        exit 1
    }
} else {
    Write-Host "  + markitdown found at: $markitdownPath" -ForegroundColor Green
}

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$converterScript = Join-Path $scriptDir "Convert-ToMarkdown.ps1"

if (-not (Test-Path $converterScript)) {
    Write-Host "X Convert-ToMarkdown.ps1 not found in $scriptDir" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "-> Adding context menu entry to Windows Registry..." -ForegroundColor Cyan

# Use reg.exe instead of PowerShell registry provider (more reliable)
$regPath = "HKEY_CLASSES_ROOT\*\shell\ConvertToMarkdown"
$regCommandPath = "$regPath\command"
$command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$converterScript`" `"%1`""

try {
    # Create main key
    $result1 = & reg add $regPath /ve /d "Convert to Markdown" /f 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Failed to create registry key: $result1" }

    # Add icon
    $result2 = & reg add $regPath /v "Icon" /d "imageres.dll,-5302" /f 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Failed to add icon: $result2" }

    # Create command subkey
    $result3 = & reg add $regCommandPath /ve /d $command /f 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Failed to add command: $result3" }

    Write-Host "  + Context menu entry added to registry" -ForegroundColor Green
} catch {
    Write-Host "X Failed to add registry entry: $_" -ForegroundColor Red
    Write-Host "Make sure you run this as Administrator." -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "How to use:" -ForegroundColor Cyan
Write-Host "  1. Right-click any file in Windows Explorer" -ForegroundColor White
Write-Host "  2. Select 'Convert to Markdown'" -ForegroundColor White
Write-Host "  3. A .md file will appear in the same folder" -ForegroundColor White
Write-Host ""
Write-Host "Supported formats: PDF, Word, Excel, PowerPoint, Images, etc." -ForegroundColor Gray
Write-Host ""
Write-Host "Note: If the context menu doesn't appear immediately," -ForegroundColor Yellow
Write-Host "restart Windows Explorer by running:" -ForegroundColor Yellow
Write-Host "  Stop-Process -Name explorer -Force" -ForegroundColor White
Write-Host ""
pause
