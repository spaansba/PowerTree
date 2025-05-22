# PowerTree

A modern replacement for the `tree` command that lets you explore directory structures with detailed file information and filtering possibilities.

![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PowerTree)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PowerTree)
![License](https://img.shields.io/github/license/spaansba/PowerTree)
![Platform](https://img.shields.io/badge/platform-windows%20%7C%20macOS%20%7C%20linux-blue)
![PowerShell Version](https://img.shields.io/badge/PowerShell-7.0%2B-blue)

## Preview Video
https://github.com/user-attachments/assets/4f5cc8ea-5b3d-49e5-b309-b35caa59dbe2

## Example Images

<details>
  <summary>Regular ptree and show the sizes of files/directories. Sorted on size descending</summary>
  <br>

Used command

  <pre><code class="language-powershell">PowerTree -DisplaySize -Descending -SortBySize</code></pre>

Exactly the same but shorthand

  <pre><code class="language-powershell">ptree -s -desc -ss</code></pre>

  <img src="./images/Size_SortSize_Desc.JPG" alt="Regular ptree and show the sizes of files PowerTree Example">
</details>

<details>
  <summary>All Display options filtered on name descending</summary>
  <br>

Used command

  <pre><code class="language-powershell">PowerTree -DisplaySize -DisplayMode -DisplayModificationDate -DisplayCreationDate -DisplayLastAccessDate -Descending -SortByName</code></pre>

Exactly the same but shorthand

  <pre><code class="language-powershell">ptree -s -dm -dmd -dcd -dla -desc -sn</code></pre>

  <img src="./images/All_Display_Options.JPG" alt="All Display options filtered on name descending PowerTree Example">
</details>

<details>
  <summary>Only show files bigger than 1kb</summary>
  <br>

Used command

  <pre><code class="language-powershell">PowerTree -FileSizeMinimum "1kb" -DisplaySize</code></pre>

Exactly the same but shorthand

  <pre><code class="language-powershell">ptree -fsmi "1kb" -s</code></pre>

  <img src="./images/File_Size_Minimum.JPG" alt="Only show files bigger than 1kb PowerTree Example">
</details>

<details>
  <summary>Directory Only</summary>
  <br>

Used command

  <pre><code class="language-powershell">PowerTree -DirectoryOnly -DisplaySize</code></pre>

Exactly the same but shorthand

  <pre><code class="language-powershell">ptree -d -s</code></pre>

  <img src="./images/Directory_Only.JPG" alt="Directory Only PowerTree Example">
</details>

## What is PowerTree?

PowerTree is a alternative to the traditional `tree` command available in Windows and Unix systems. It provides visualization of directory structures with advanced filtering, sorting, and display options that make exploring and documenting file systems more efficient.

Unlike the standard `tree` command, PowerTree offers:

- Detailed file information (size, dates, attributes)
- Multiple sorting options (by name, size, date etc.)
- Filtering capabilities (by extension, size, directory)
- Customizable configuration via JSON

## Installation

From [PowerShell Gallery](https://www.powershellgallery.com/packages/PowerTree):

```powershell
Install-Module PowerTree
```

## Quick Start

```powershell
# Basic usage - show tree of current directory
PowerTree

# Use the alias for quicker access
ptree

# Show tree with sizes, sorted by size (descending)
PowerTree -DisplaySize -SortBySize -Descending

# Exclude certain directories and show only PowerShell scripts
PowerTree -ExcludeDirectories node_modules,bin -IncludeExtensions ps1

# Save output to a file
PowerTree -OutFile tree_output.txt
```

## Cmdlets and Parameters

PowerTree provides two main cmdlets:

- `Start-PowerTree` - The main command for directory visualization. Alias: (`ptree`, `PowerTree`)
- `Edit-PowerTreeConfig` - A utility to manage your PowerTree configuration. Alias: (`Edit-PowerTree`, `Edit-ptree`)

The main `Start-PowerTree` cmdlet comes with many optional parameters to customize your directory visualization experience.

### Basic Options

| Parameter          | Alias    | Description                                         |
| ------------------ | -------- | --------------------------------------------------- |
| `-Path <string>`   |          | Specify path to search (default: current directory) |
| `-Verbose`         |          | Show verbose output                                 |
| `-ShowHiddenFiles` | `-force` | Show hidden files and directories                   |

### Help Options

| Parameter          | Alias             | Description                           |
| ------------------ | ----------------- | ------------------------------------- |
| `-Help`            | `-h`              | Print helpfull information            |
| `-CheckForUpdates` | `-Check`          | Check if there is an update available |
| `-Version`         | `-v`              | Print current version                 |
| `-ModuleInfo`      | `-i`, `-info`     | Print PowerTree information           |
| `-Examples`        | `-ex`, `-example` | Print examples                        |

### Folder Filtering Options

| Parameter                        | Alias            | Description                                           |
| -------------------------------- | ---------------- | ----------------------------------------------------- |
| `-Depth <int>`                   | `-l`, `-level`   | Limit display to specified number of directory levels |
| `-ExcludeDirectories <string[]>` | `-e`, `-exclude` | Exclude specified directories                         |
| `-PruneEmptyFolders`             | `-p`, `-prune`   | Exclude empty folders from output                     |
| `-DirectoryOnly`                 | `-d`, `-dir`     | Display only directories (no files)                   |

### File Filtering Options

| Parameter                       | Alias   | Description                                    |
| ------------------------------- | ------- | ---------------------------------------------- |
| `-IncludeExtensions <string[]>` | `-if`   | Include only files with specified extension(s) |
| `-ExcludeExtensions <string[]>` | `-ef`   | Exclude files with specified extension(s)      |
| `-FileSizeMinimum <string>`     | `-fsmi` | Filter out files smaller than specified size   |
| `-FileSizeMaximum <string>`     | `-fsma` | Filter out files larger than specified size    |

### Display Options

| Parameter                  | Alias           | Description                               |
| -------------------------- | --------------- | ----------------------------------------- |
| `-OutFile <string>`        | `-o`, `-of`     | Save output to specified file path        |
| `-Quiet`                   | `-q`, `-silent` | Suppress console output                   |
| `-DisplaySize`             | `-s`, `-size`   | Show file sizes in human-readable format  |
| `-DisplayMode`             | `-dm`, `-m`     | Show file/folder attributes (d,a,r,h,s,l) |
| `-DisplayModificationDate` | `-dmd`          | Show last modified date                   |
| `-DisplayCreationDate`     | `-dcd`          | Show creation date                        |
| `-DisplayLastAccessDate`   | `-dla`          | Show last access date                     |

### Sorting Options

| Parameter                 | Alias           | Description                                  |
| ------------------------- | --------------- | -------------------------------------------- |
| `-Sort <string>`          |                 | Specify sort method (size, name, md, cd, la) |
| `-SortBySize`             | `-ss`           | Sort by file size                            |
| `-SortByName`             | `-sn`           | Sort alphabetically by name (default)        |
| `-SortByModificationDate` | `-smd`          | Sort by last modified date                   |
| `-SortByCreationDate`     | `-scd`          | Sort by creation date                        |
| `-SortByLastAccessDate`   | `-sla`          | Sort by last access date                     |
| `-Descending`             | `-des`, `-desc` | Sort in descending order                     |

## Managing Your Configuration

PowerTree provides a built-in configuration editor to help you manage your settings.

`Edit-PowerTreeConfig` function will:

1. Find an existing configuration file if present
2. Create a new configuration file with default settings if one doesn't exist
3. Open the configuration file in your default editor

### Sample Configuration File

```json
{
  "ExcludeDirectories": ["node_modules", ".next"],
  "Sorting": {
    "By": "Name",
    "SortFolders": false
  },
  "Files": {
    "ExcludeExtensions": [],
    "IncludeExtensions": [],
    "FileSizeMinimum": "-1kb",
    "FileSizeMaximum": "-1kb",
    "OpenOutputFileOnFinish": true
  },
  "ShowConnectorLines": true,
  "ShowExecutionStats": true,
  "MaxDepth": -1,
  "LineStyle": "Unicode",
  "HumanReadableSizes": true
}
```

### Configuration Options

| Option                         | Description                                          | Default   |
| ------------------------------ | ---------------------------------------------------- | --------- |
| `ExcludeDirectories`           | Standard array of directories to exclude             | `[]`      |
| `Sorting.By`                   | Default sort method                                  | `"Name"`  |
| `Sorting.SortFolders`          | Whether to apply sorting to folders                  | `false`   |
| `Files.ExcludeExtensions`      | Standard array of file extensions to exclude         | `[]`      |
| `Files.IncludeExtensions`      | Standard array of file extensions to include         | `[]`      |
| `Files.FileSizeMinimum`        | Minimum file size to include                         | `"-1kb"`  |
| `Files.FileSizeMaximum`        | Maximum file size to include                         | `"-1kb"`  |
| `Files.OpenOutputFileOnFinish` | With -o automatically open output file when finished | `true`    |
| `ShowConnectorLines`           | Show connector lines in tree view                    | `true`    |
| `ShowExecutionStats`           | Show execution statistics                            | `true`    |
| `MaxDepth`                     | Default maximum depth of directories                 | `-1`      |
| `LineStyle`                    | Tree display style ("ASCII" or "Unicode")            | `Unicode` |
| `HumanReadableSizes`           | Sizes will include b, kb, mb, gb etc when true       | `true`    |

## Examples

### Basic Usage

```powershell
# Show tree of current directory
Ptree

# Show only directories (no files)
Ptree -DirectoryOnly

# Show tree with file sizes
Ptree -DirectoryOnly -s
```

### Advanced Combinations

```powershell
# Find large files, sort by size descending
Ptree -DisplaySize -SortBySize -Descending -FileSizeMinimum 10MB

# Show tree with all metadata, excluding common build directories
Ptree -DisplaySize -DisplayMode -DisplayModificationDate -ExcludeDirectories bin,obj,node_modules

# Export filtered tree to a file
Ptree -IncludeExtensions ps1,md -ExcludeDirectories .git -OutFile project_docs.txt

# Show tree with file sizes sorted on descending size length with a min file size of 100kb and max file size of 1mb
Ptree -s -desc -sort size -fsmi 100kb -fsma 1mb
```

## TreeStats

PowerTree provides execution statistics at the end of the output, showing information about the files and directories processed.
TreeStats can be fully turned off by setting `ShowExecutionStats` in `Edit-PowerTreeConfig`

### Basic Stats

| Stat           | Description                              |
| -------------- | ---------------------------------------- |
| Files          | Number of files processed                |
| Folders        | Number of folders processed              |
| Total Items    | Total count of files and folders         |
| Depth          | Maximum depth of the directory structure |
| Total Size     | Combined size of all files               |
| Execution Time | Time taken to process the tree           |

### Largest Items

When the `-DisplaySize` parameter is enabled, the following additional information is displayed:

- **Largest File:** Shows the size and full path of the largest file found
- **Largest Folder:** Shows the size and full path of the largest folder found

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created by Bart Spaans

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Upcomming Features

- Allow for files/folders being automatically excluded by reading the -gitignore in the start folder
- Option to print out exported functions in javascript/typescript files
- Ability to tree out the registry on windows
- Option to show ACL
