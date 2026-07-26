# Uninstall script for Convert to Markdown Windows context menu
# Requires Administrator privileges

#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

Write-Host "→ Removing context menu entry from Windows Registry..." -ForegroundColor Cyan

# Registry path for context menu
$regPath = "Registry::HKEY_CLASSES_ROOT\*\shell\ConvertToMarkdown"

if (Test-Path $regPath) {
    Remove-Item -Path $regPath -Recurse -Force
    Write-Host "✅ Context menu entry removed successfully." -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: You may need to restart Explorer for changes to take effect." -ForegroundColor Yellow
    Write-Host "To restart Explorer, run: Stop-Process -Name explorer -Force" -ForegroundColor Yellow
} else {
    Write-Host "Context menu entry not found. Nothing to remove." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Note: markitdown package is still installed. To remove it, run:" -ForegroundColor Cyan
Write-Host "  pip uninstall markitdown" -ForegroundColor White
