# Convert to Markdown

A utility for converting files to Markdown via the Windows context menu.

## What it does

Adds a "Convert to Markdown" option to the file context menu in Windows Explorer. When selected, the file is converted PDF, Word, Excel, PowerPoint, images and other formats to .md using Microsoft's [MarkItDown.](https://github.com/microsoft/MarkItDown)

## Installation

### Quick Install

1. Download the project:
```bash
git clone https://github.com/your-username/convert-to-markdown.git
cd convert-to-markdown
```

2. Run the installer:
```bash
install.bat
```

### What happens during installation

- Scripts are copied to `%APPDATA%\ConvertToMarkdown`
- A context menu entry is added via the Windows registry
- A shortcut is created for quick access to settings

## Usage

1. Right-click on any file
2. Select "Convert to Markdown"
3. The file will be converted using the Claude API

## Uninstallation

Run:
```bash
uninstall.bat
```

## Requirements

- Windows 10 or higher
- PowerShell 5.1 or higher

## Configuration

API key and other settings are stored in `%APPDATA%\ConvertToMarkdown\config.json`

## License

MIT
