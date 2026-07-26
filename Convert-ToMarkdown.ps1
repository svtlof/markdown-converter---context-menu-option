# Convert to Markdown - Windows Context Menu Script
# Converts PDF, Word, Excel, PowerPoint, images and other formats to .md using markitdown

param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Files
)

$ErrorActionPreference = 'Continue'
Add-Type -AssemblyName System.Windows.Forms

# Debug: log the received parameters
$logPath = Join-Path $env:TEMP "markitdown-debug.log"
"[$(Get-Date)] Received files: $($Files -join ', ')" | Out-File -FilePath $logPath -Append

# Check if markitdown is installed
$markitdownPath = $null
try {
    $markitdownPath = (Get-Command markitdown -ErrorAction SilentlyContinue).Source
} catch {}

if (-not $markitdownPath) {
    # Try common Python installation paths
    $pythonPaths = @(
        "$env:LOCALAPPDATA\Programs\Python\Python*\Scripts\markitdown.exe",
        "$env:LOCALAPPDATA\Python\Python*\Scripts\markitdown.exe",
        "$env:APPDATA\Python\Python*\Scripts\markitdown.exe",
        "C:\Python*\Scripts\markitdown.exe"
    )

    foreach ($pattern in $pythonPaths) {
        $found = Get-Item $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $markitdownPath = $found.FullName
            break
        }
    }
}

if (-not $markitdownPath) {
    [System.Windows.Forms.MessageBox]::Show(
        "markitdown not found. Please install it with: pip install markitdown[all]",
        "Convert to Markdown",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit 1
}

$successCount = 0
$failCount = 0
$errors = @()

foreach ($file in $Files) {
    # Log the file being processed
    "Processing: $file" | Out-File -FilePath $logPath -Append

    # Clean up the file path - remove quotes if present
    $file = $file.Trim('"')

    if (-not (Test-Path $file)) {
        $errorMsg = "File not found: $file (CWD: $(Get-Location))"
        "ERROR: $errorMsg" | Out-File -FilePath $logPath -Append
        $errors += $errorMsg
        $failCount++
        continue
    }

    $fileInfo = Get-Item $file

    # Check if file is empty
    if ($fileInfo.Length -eq 0) {
        $errorMsg = "File is empty: $($fileInfo.Name)"
        "ERROR: $errorMsg" | Out-File -FilePath $logPath -Append
        $errors += $errorMsg
        $failCount++
        continue
    }

    $dir = $fileInfo.DirectoryName
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileInfo.Name)
    $outputPath = Join-Path $dir "$baseName.md"

    try {
        "Running: $markitdownPath $file" | Out-File -FilePath $logPath -Append
        $convertOutput = & $markitdownPath $file 2>&1

        if ($LASTEXITCODE -ne 0) {
            $errorMsg = "Failed to convert: $($fileInfo.Name) (exit code: $LASTEXITCODE)"
            "ERROR: $errorMsg" | Out-File -FilePath $logPath -Append
            $errors += $errorMsg
            $failCount++
            continue
        }

        # Try to write to the original directory
        $savedPath = $null
        try {
            $convertOutput | Out-File -FilePath $outputPath -Encoding UTF8 -ErrorAction Stop
            $savedPath = $outputPath
            "SUCCESS: Created $outputPath" | Out-File -FilePath $logPath -Append
        } catch {
            # If access denied, save to Desktop instead
            $desktopPath = [Environment]::GetFolderPath("Desktop")
            $fallbackPath = Join-Path $desktopPath "$baseName.md"

            # If file already exists on desktop, add number suffix
            $counter = 1
            while (Test-Path $fallbackPath) {
                $fallbackPath = Join-Path $desktopPath "$baseName-$counter.md"
                $counter++
            }

            try {
                $convertOutput | Out-File -FilePath $fallbackPath -Encoding UTF8 -ErrorAction Stop
                $savedPath = $fallbackPath
                "SUCCESS: Created $fallbackPath (fallback to Desktop due to access denied)" | Out-File -FilePath $logPath -Append
            } catch {
                $errorMsg = "Access denied to both original folder and Desktop: $($_.Exception.Message)"
                "ERROR: $errorMsg" | Out-File -FilePath $logPath -Append
                $errors += $errorMsg
                $failCount++
                continue
            }
        }

        if ($savedPath) {
            $successCount++
        }
    } catch {
        $errorMsg = "Error converting $($fileInfo.Name): $($_.Exception.Message)"
        "EXCEPTION: $errorMsg" | Out-File -FilePath $logPath -Append
        $errors += $errorMsg
        $failCount++
    }
}

# Show result only on errors
if ($failCount -gt 0) {
    if ($successCount -gt 0) {
        $message = "Converted $successCount file(s), but failed $failCount`n`n" + ($errors -join "`n")
        [System.Windows.Forms.MessageBox]::Show($message, "Convert to Markdown", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    } else {
        $message = "Failed to convert all files:`n`n" + ($errors -join "`n")
        [System.Windows.Forms.MessageBox]::Show($message, "Convert to Markdown", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}
# No notification on success - just silently create the .md file
