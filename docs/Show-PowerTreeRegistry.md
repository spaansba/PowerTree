---
external help file: PowerTree-help.xml
Module Name: PowerTree
online version: https://github.com/spaansba/PowerTree
schema: 2.0.0
---

# Show-PowerTreeRegistry

## SYNOPSIS

Displays Windows Registry structure in a tree format with advanced filtering and display options.

## SYNTAX

```
Show-PowerTreeRegistry [[-Path] <String>] [-OutFile <String>] [-NoValues] [-SortValuesByType]
 [-UseRegistryDataTypes] [-SortDescending] [-DisplayItemCounts] [-Exclude <String[]>] [-Include <String[]>]
 [-Depth <Int32>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

Show-PowerTreeRegistry provides a tree-like visualization of the Windows Registry, similar to how Show-PowerTree works for file systems. It allows you to explore registry keys and values with filtering, sorting, and display customization options.

This cmdlet is particularly useful for:

- Registry exploration and documentation
- System administration tasks
- Troubleshooting registry-related issues
- Creating registry reports

**Note:** This cmdlet is only available on Windows systems.

## EXAMPLES

### Example 1: Show registry tree for a specific path

```powershell
PS C:\> Show-PowerTreeRegistry -Path "HKLM:\SOFTWARE\Microsoft"
```

Displays the registry tree for the Microsoft software keys in HKEY_LOCAL_MACHINE.

### Example 2: Show only registry keys

```powershell
PS C:\> Show-PowerTreeRegistry -Path "HKCU:\Software" -NoValues
```

Shows only registry keys without displaying any registry values.

### Example 3: Display with item counts

```powershell
PS C:\> Show-PowerTreeRegistry -Path "HKLM:\SYSTEM" -DisplayItemCounts -Depth 2
```

Shows the registry tree up to 2 levels deep with counts of sub-keys and values.

### Example 4: Filter and save to file

```powershell
PS C:\> Show-PowerTreeRegistry -Path "HKLM:\SOFTWARE" -Include "*Microsoft*" -OutFile registry_report.txt
```

Filters to show only items containing "Microsoft" and saves the output to a file.

### Example 5: Sort values by type with registry data types

```powershell
PS C:\> Show-PowerTreeRegistry -Path "HKCU:\Environment" -SortValuesByType -UseRegistryDataTypes
```

Displays environment variables sorted by registry data type, showing native registry type names.

### Example 6: Exclude specific keys

```powershell
PS C:\> Show-PowerTreeRegistry -Path "HKLM:\SOFTWARE" -Exclude "*Classes*","*WOW6432Node*" -Depth 3
```

Shows the software registry tree excluding Classes and WOW6432Node branches, limited to 3 levels.

## PARAMETERS

### -Depth

Limits the display to the specified number of registry levels.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: l, level

Required: False
Position: Named
Default value: -1 (unlimited)
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayItemCounts

Shows the count of sub-keys and values for each registry key.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: dic

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude

Excludes registry keys or values that match the specified patterns.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: e, exc

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include

Includes only registry keys or values that match the specified patterns.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: i, inc

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoValues

Shows only registry keys, excluding registry values.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: nv

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile

Saves the registry tree output to the specified file path.

```yaml
Type: String
Parameter Sets: (All)
Aliases: o, of

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specifies the registry path to explore. Supports standard registry hive abbreviations.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: . (current registry location)
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortDescending

Sorts items in descending order.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: des, desc, descending

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortValuesByType

Sorts registry values by their data type.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: st

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseRegistryDataTypes

Displays registry values using their native registry data type names.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: dt, types, rdt

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

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

You cannot pipe objects to Show-PowerTreeRegistry.

## OUTPUTS

### System.String

Show-PowerTreeRegistry outputs the registry tree structure as text to the console and optionally to a file.

## NOTES

**Registry Path Formats:**
You can use standard PowerShell registry provider paths:

- `HKLM:\` for HKEY_LOCAL_MACHINE
- `HKCU:\` for HKEY_CURRENT_USER
- `HKCR:\` for HKEY_CLASSES_ROOT
- `HKU:\` for HKEY_USERS
- `HKCC:\` for HKEY_CURRENT_CONFIG

**Registry Data Types:**
When using `-UseRegistryDataTypes`, you'll see native registry types like:

- REG_SZ (String)
- REG_DWORD (32-bit number)
- REG_BINARY (Binary data)
- REG_MULTI_SZ (Multi-string)
- REG_EXPAND_SZ (Expandable string)

**Performance Considerations:**
Large registry subtrees can take time to process. Use `-Depth` to limit traversal depth for better performance.

**Platform Support:**
This cmdlet is only available on Windows systems and will display an error on other platforms.

## RELATED LINKS

[PowerTree GitHub Repository](https://github.com/spaansba/PowerTree)

[Show-PowerTree](Show-PowerTree.md)

[Edit-PowerTreeConfig](Edit-PowerTreeConfig.md)
