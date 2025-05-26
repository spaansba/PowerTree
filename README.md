# PowerTree

A modern replacement for the `tree` command that lets you explore directory structures and Windows Registry with detailed information and advanced filtering possibilities.

![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PowerTree)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PowerTree)
![License](https://img.shields.io/github/license/spaansba/PowerTree)
![Platform](https://img.shields.io/badge/platform-windows%20%7C%20macOS%20%7C%20linux-blue)
![PowerShell Version](https://img.shields.io/badge/PowerShell-7.0%2B-blue)

## Preview Video

https://github.com/user-attachments/assets/4f5cc8ea-5b3d-49e5-b309-b35caa59dbe2

## What is PowerTree?

PowerTree is a comprehensive tree visualization tool that provides two main capabilities:

- **File System Explorer**: A modern alternative to the traditional `tree` command with advanced filtering, sorting, and display options
- **Registry Explorer**: Windows Registry visualization in tree format (Windows only)

Unlike standard tree commands, PowerTree offers detailed information display, multiple sorting options, filtering capabilities, and customizable configuration.

## Installation

From [PowerShell Gallery](https://www.powershellgallery.com/packages/PowerTree):

```powershell
Install-Module PowerTree
```

## Quick Start

### File System Exploration

```powershell
# Basic usage - show tree of current directory
Show-PowerTree
# or use the alias
ptree

# Show tree with sizes, sorted by size (descending)
ptree -DisplaySize -SortBySize -Descending

# Exclude directories and filter by extension
ptree -ExcludeDirectories node_modules,bin -IncludeExtensions ps1

# Save output to a file
ptree -OutFile tree_output.txt
```

### Registry Exploration (Windows Only)

```powershell
# Show registry tree for a specific path
Show-PowerTreeRegistry -Path "HKLM:\SOFTWARE\Microsoft"

# Show only registry keys (no values)
Show-PowerTreeRegistry -Path "HKCU:\Software" -NoValues

# Display with item counts and depth limit
Show-PowerTreeRegistry -Path "HKLM:\SYSTEM" -DisplayItemCounts -Depth 2
```

## Available Commands

PowerTree provides three main cmdlets:

| Command                  | Alias                          | Description                         | Documentation                                               |
| ------------------------ | ------------------------------ | ----------------------------------- | ----------------------------------------------------------- |
| `Show-PowerTree`         | `ptree`, `PowerTree`           | File system tree visualization      | [Show-PowerTree.md](docs/Show-PowerTree.md)                 |
| `Show-PowerTreeRegistry` | `ptreer`, `PowerRegistry`      | Windows Registry tree visualization | [Show-PowerTreeRegistry.md](docs/Show-PowerTreeRegistry.md) |
| `Edit-PowerTreeConfig`   | `Edit-PowerTree`, `Edit-ptree` | Configuration file editor           | [Edit-PowerTreeConfig.md](docs/Edit-PowerTreeConfig.md)     |

## Key Features

### File System Explorer (Show-PowerTree)

- **Display Options**: File sizes, cumulative folder sizes (with all subfolders/files), creation date, modification date, or access date and mode
- **Sorting**: By name, size, creation date, modification date, or access date
- **Filtering**: Include/exclude files by extension, filter on size (e.g., 1kb-20mb), show only directories, or remove empty directories
- **Output Options**: Console display or export to file
- **Cross-Platform**: Works on Windows, macOS, and Linux

### Registry Explorer (Show-PowerTreeRegistry) (Windows Only)

- **Registry Navigation**: Explore any registry hive or key with tree structure. Returns both the key and the value
- **Advanced Filtering**: Include/exclude patterns for keys and values
- **Output Options**: Console display or export to file

### Configuration Management (Edit-PowerTreeConfig)

- **JSON Configuration**: Fully configurable via JSON
- **Visual Customization**: Set visual custimizations not available through parameters. E.G. Tree line styles (├── vs |--), show/hide execution stats, human-readable sizes (10MB vs 10485760)
- **Parameter Defaults**: Configure default exclusions (e.g., always exclude node_modules, bin, obj directories), file size limits, and depth restrictions

## Example Images

<details>
  <summary>File system with sizes sorted by size descending</summary>
  <br>

```powershell
ptree -DisplaySize -Descending -SortBySize
```

  <img src="./images/Size_SortSize_Desc.JPG" alt="PowerTree with file sizes sorted by size">
</details>

<details>
  <summary>All display options with name sorting</summary>
  <br>

```powershell
ptree -DisplayAll -Descending -SortByName
```

  <img src="./images/All_Display_Options.JPG" alt="PowerTree with all display options">
</details>

<details>
  <summary>File size filtering</summary>
  <br>

```powershell
ptree -FileSizeMinimum "1kb" -DisplaySize
```

  <img src="./images/File_Size_Minimum.JPG" alt="PowerTree with file size filtering">
</details>

<details>
  <summary>Directory only view</summary>
  <br>

```powershell
ptree -DirectoryOnly -DisplaySize
```

  <img src="./images/Directory_Only.JPG" alt="PowerTree directory only view">
</details>

## Common Use Cases

### System Administration

```powershell
# Find large files consuming disk space
ptree -DisplaySize -SortBySize -Descending -FileSizeMinimum 100MB

# Explore registry configuration
Show-PowerTreeRegistry -Path "HKLM:\SOFTWARE\Microsoft" -DisplayItemCounts

# Document directory structure for compliance
ptree -DisplayAll -OutFile system_audit.txt
```

### Development Workflows

```powershell
# Exclude build artifacts and show only source files
ptree -ExcludeDirectories bin,obj,node_modules -IncludeExtensions cs,js,ts

# Check project structure and sizes
ptree -DisplaySize -ExcludeDirectories .git,.vs -Depth 3

# Export project documentation
ptree -IncludeExtensions md,txt -OutFile project_docs.txt
```

## Configuration

PowerTree supports persistent configuration through a JSON file. Use `Edit-PowerTreeConfig` to customize default behaviors:

```powershell
Edit-PowerTreeConfig
```

This opens your configuration file where you can set default sorting, filtering, display options, and more. See [Edit-PowerTreeConfig.md](Edit-PowerTreeConfig.md) for complete configuration reference.

## Documentation

For detailed parameter references and advanced usage examples:

- **[Show-PowerTree Documentation](Show-PowerTree.md)** - Complete file system tree reference
- **[Show-PowerTreeRegistry Documentation](Show-PowerTreeRegistry.md)** - Windows Registry exploration guide
- **[Edit-PowerTreeConfig Documentation](Edit-PowerTreeConfig.md)** - Configuration management reference

## TreeStats

PowerTree provides execution statistics showing files/folders processed, total size, execution time, and largest items found. This feature can be customized or disabled through the configuration file.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created by Bart Spaans

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Upcoming Features

- Git integration (automatic .gitignore exclusion)
- Export function signatures from JavaScript/TypeScript files
- Access Control List (ACL) display options
- Enhanced registry data type visualization
