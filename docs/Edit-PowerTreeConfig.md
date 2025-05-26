---
external help file: PowerTree-help.xml
Module Name: PowerTree
online version: https://github.com/spaansba/PowerTree
schema: 2.0.0
---

# Edit-PowerTreeConfig

## SYNOPSIS

Opens the PowerTree configuration file for editing.

## SYNTAX

```
Edit-PowerTreeConfig [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Edit-PowerTreeConfig is a utility cmdlet that manages your PowerTree and PowerTreeRegistry configuration file. It automatically locates or creates the configuration file and opens it in the appropriate editor for your operating system.

## EXAMPLES

### Example 1: Open configuration file

```powershell
PS C:\> Edit-PowerTreeConfig
```

Opens the PowerTree configuration file in the default editor. If no configuration file exists, creates a new one with default settings.

## NOTES

**Configuration File Location:**

- **Windows:** `$env:USERPROFILE\.PowerTree\config.json`
- **macOS/Linux:** `$HOME/.PowerTree/config.json`

**Default Editor Behavior:**

- **Windows:** Opens with the system default application for JSON files
- **macOS:** Uses the `open` command to launch the default editor
- **Linux:** Attempts to use `xdg-open`, `nano`, `vim`, or `vi` in that order

**Configuration File Structure:**

```json
{
  // Regular PowerTree
  "FileSystem": {
    // Maximum directory depth to traverse (-1 = unlimited)
    // Overwritten by -Depth
    "MaxDepth": -1,
    "Files": {
      // Only show files with these extensions (empty = all files) same as -IncludeExtensions
      "IncludeExtensions": [],
      // Hide files with these extensions same as -ExcludeExtensions
      "ExcludeExtensions": [],
      // Hide files larger than this size (-1kb = no limit)
      // Default setting, overwritten by -FileSizeMaximum parameter
      "FileSizeMaximum": "-1kb",
      // Hide files smaller than this size (-1kb = no limit)
      // Default setting, overwritten by -FileSizeMinimum parameter
      "FileSizeMinimum": "-1kb"
    },
    "Sorting": {
      // Default sort method: "Name", "Size", "Date", etc.
      // Default setting, overwritten by -Sort and -SortBy* parameters
      "By": "Name",
      // Apply sorting to directories (false = folders first)
      // Can be changed via Edit-PowerTreeConfig only
      "SortFolders": false
    },
    // Show sizes as KB/MB/GB instead of raw bytes
    "HumanReadableSizes": true,
    // Standard directories to always exclude same as -ExcludeDirectories
    "ExcludeDirectories": []
  },
  // PowerTreeRegistry
  "Registry": {
    // Maximum registry depth to traverse (-1 = unlimited)
    // Overwritten by -Depth
    "MaxDepth": -1,
    // Show registry value data (can be verbose)
    // Default setting, overwritten by -DisplayValues parameter in Show-PowerTreeRegistry
    "DisplayValues": false,
    // Registry keys to always exclude
    // Default setting, overwritten by -ExcludeKeys parameter in Show-PowerTreeRegistry
    "ExcludeKeys": []
  },
  "Shared": {
    // Tree connector style: "unicode" (├──) or "ascii" (|--)
    "LineStyle": "unicode",
    // Display timing and file count statistics
    "ShowExecutionStats": true,
    // Display active configuration at start
    "ShowConfigurations": true,
    "ShowConnectorLines": true,
    // Automatically open output file when using -OutFile
    "OpenOutputFileOnFinish": true
  }
}
```

If the configuration file doesn't exist, Edit-PowerTreeConfig will create it with sensible defaults.

## RELATED LINKS

[PowerTree GitHub Repository](https://github.com/spaansba/PowerTree)

[Show-PowerTree](Show-PowerTree.md)

[Show-PowerTreeRegistry](Show-PowerTreeRegistry.md)
