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

Edit-PowerTreeConfig is a utility cmdlet that manages your PowerTree configuration file. It automatically locates or creates the configuration file and opens it in the appropriate editor for your operating system.

The configuration file allows you to customize default behaviors for PowerTree, including:

- Default sorting preferences
- Display options
- Line style preferences
- File filtering defaults
- Performance settings

## EXAMPLES

### Example 1: Open configuration file

```powershell
PS C:\> Edit-PowerTreeConfig
```

Opens the PowerTree configuration file in the default editor. If no configuration file exists, creates a new one with default settings.

### Example 2: Using alias

```powershell
PS C:\> Edit-PowerTree
```

Alternative way to open the configuration file using the alias.

## PARAMETERS

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

You cannot pipe objects to Edit-PowerTreeConfig.

## OUTPUTS

### None

Edit-PowerTreeConfig does not generate output. It opens the configuration file in an editor.

## NOTES

**Configuration File Location:**

- **Windows:** `$env:USERPROFILE\.PowerTree\config.json`
- **macOS/Linux:** `$HOME/.PowerTree/config.json`

**Default Editor Behavior:**

- **Windows:** Opens with the system default application for JSON files
- **macOS:** Uses the `open` command to launch the default editor
- **Linux:** Attempts to use `xdg-open`, `nano`, `vim`, or `vi` in that order

**Configuration File Structure:**
The configuration file is a JSON document with the following main sections:

- `LineStyle`: Tree display styling options
- `Sorting`: Default sorting preferences
- `Files`: File filtering and handling options
- `ShowConnectorLines`: Whether to show tree connector lines
- `MaxDepth`: Default maximum depth limit
- `HumanReadableSizes`: Whether to display sizes in human-readable format
- `ShowExecutionStats`: Whether to show performance statistics

If the configuration file doesn't exist, Edit-PowerTreeConfig will create it with sensible defaults.

## RELATED LINKS

[PowerTree GitHub Repository](https://github.com/spaansba/PowerTree)

[Show-PowerTree](Show-PowerTree.md)

[Show-PowerTreeRegistry](Show-PowerTreeRegistry.md)
