---
external help file: PowerTree-help.xml
Module Name: powertree
online version: https://github.com/spaansba/PowerTree
schema: 2.0.0
---

# Show-PowerTree

## SYNOPSIS

A modern replacement for the tree command with advanced filtering, sorting, and display options.

## SYNTAX

```
Show-PowerTree [[-LiteralPath] <String>] [-Depth <Int32>] [-Examples] [-PruneEmptyFolders] [-DisplayAll]
 [-DisplayMode] [-DisplaySize] [-DisplayModificationDate] [-DisplayCreationDate] [-DisplayLastAccessDate]
 [-DirectoryOnly] [-ExcludeDirectories <String[]>] [-Sort <String>] [-SortByModificationDate]
 [-SortByCreationDate] [-SortByLastAccessDate] [-SortBySize] [-SortByName] [-Descending]
 [-FileSizeMinimum <String>] [-FileSizeMaximum <String>] [-FileSizeFilter <String>]
 [-ExcludeExtensions <String[]>] [-IncludeExtensions <String[]>] [-ShowHiddenFiles] [-OutFile <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION

PowerTree is an advanced alternative to the traditional `tree` command available in Windows and Unix systems. It provides visualization of directory structures with advanced filtering, sorting, and display options that make exploring and documenting file systems more efficient.

Unlike the standard `tree` command, PowerTree offers:

- Detailed file information (size, dates, attributes)
- Multiple sorting options (by name, size, date etc.)
- Filtering capabilities (by extension, size, directory)
- Customizable configuration via JSON
- Export functionality to save output to files

## EXAMPLES

### Example 1: Basic usage

```powershell
PS C:\> Show-PowerTree
# Shorthand
PS C:\> ptree
```

Shows the basic tree structure of the current directory. This is your starting point for exploring any directory structure.

### Example 2: Show tree with sizes

```powershell
PS C:\> Show-PowerTree -DisplaySize -SortBySize -Descending -FileSizeMinimum 10MB
# Shorthand
PS C:\> ptree -s -ss -desc -fsmi 10MB
```

Displays only files larger than 10MB and sorts them from largest to smallest. This creates a "disk usage audit" view of your directory. File sizes are displayed in human-readable format (KB, MB, GB) by default. To show exact byte counts instead, use Edit-PowerTreeConfig and set HumanReadableSizes to false.

### Example 3: Show tree with sizes

```powershell
PS C:\> Show-PowerTree -DisplayAll -ExcludeDirectories bin,obj,node_modules
# Shorthand
ps C:\> ptree -da -e bin,obj,node_modules
```

Shows complete file information (size, dates, mode) while excluding common build/dependency directories.

### Example 4: Place output in other file

```powershell
PS C:\> Show-PowerTree -DisplaySize -OutFile "powertree.txt"
# Shorthand
ps C:\> ptree -s -o "powertree"
```

Generates a tree view with file sizes and saves the complete output to a text file instead of displaying it in the console. This is faster than console output as it doesn't have to write to the host.

## PARAMETERS

### -Depth

Controls how many levels deep PowerTree will traverse into subdirectories.

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

### -Descending

Reverses the sort order for any active sorting method, showing results from largest to smallest or Z to A.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: des, desc

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DirectoryOnly

Shows only folder structure without individual files in the output.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: d, dir

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayAll

Enables all display options simultaneously including size, creation date, modification date, last accessed date and mode.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: da

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayCreationDate

Displays when each file or folder was originally created.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: dcd

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayLastAccessDate

Displays when files were last opened or accessed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: dla

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayMode

Displays file system attributes using codes: directory (d), archive (a), readonly (r), hidden (h), system (s), and symbolic link (l).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: dm, m

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayModificationDate

Displays when files were last modified.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: dmd

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplaySize

Displays file and folder sizes in readable units (KB, MB, GB) instead of raw byte counts. To show exact byte counts instead, use Edit-PowerTreeConfig and set HumanReadableSizes to false.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: s, size

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Examples
{{ Fill Examples Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ex, example

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeDirectories

Hides the specified folder names from the tree display. Accepts multiple directory names separated by commas.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: e, exclude

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeExtensions

Hides files with the specified file extensions from the output. Accepts multiple extensions separated by commas.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: ef

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileSizeFilter

Applies advanced file size filtering using complex criteria in a single parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases: fs, filesize

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileSizeMaximum

Hides files that exceed the specified size limit. Supports size units like KB, MB, GB. (e.g 10kb)

```yaml
Type: String
Parameter Sets: (All)
Aliases: fsma

Required: False
Position: Named
Default value: -1kb
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileSizeMinimum

Shows only files larger than the specified threshold. Supports size units like KB, MB, GB. (e.g 10kb)

```yaml
Type: String
Parameter Sets: (All)
Aliases: fsmi

Required: False
Position: Named
Default value: -1kb
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeExtensions

Shows only files with the specified file extensions, hiding all other file types. Accepts multiple extensions separated by commas.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: if

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralPath
{{ Fill LiteralPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile

Writes the tree output to a text file instead of displaying it in the console. Faster than regular since we dont have to write to the host. Accepts both a name or a full path

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

### -PruneEmptyFolders

Excludes empty folders from the output.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: prune, p

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowHiddenFiles

Shows hidden files and directories. (e.g. .git)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: force

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort

Sets the sorting criteria using predefined values: size, name, md (modified date), cd (creation date), or la (last access).

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: size, name, md, cd, la

Required: False
Position: Named
Default value: name
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortByCreationDate

Sorts by creation date.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: scd

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortByLastAccessDate

Sorts by last access date.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: sla, sld

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortByModificationDate

Sorts by last modified date.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: smd

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortByName

Sorts alphabetically by name (default).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: sn

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -SortBySize

Orders files and folders by their size, from smallest to largest unless combined with -Descending.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ss

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

You cannot pipe objects to Show-PowerTree.

## OUTPUTS

### System.String

Show-PowerTree outputs tree structure as text to the console and optionally to a file.

## NOTES

PowerTree provides extensive customization through a JSON configuration file. Use `Edit-PowerTreeConfig` to modify default settings.

File size filters support units: b, kb, mb, gb, tb.

## RELATED LINKS

[PowerTree GitHub Repository](https://github.com/spaansba/PowerTree)

[Edit-PowerTreeConfig](Edit-PowerTreeConfig.md)

[Show-PowerTreeRegistry](Show-PowerTreeRegistry.md)
