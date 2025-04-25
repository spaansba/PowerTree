function Write-Help {
    Write-Host ""

    Write-Host "BASIC OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -Help, -?, -h                       Help"
    Write-Host "  -Version, -v                        Display current PowerTree version"
    Write-Host "  -ModuleInfo, -i, -info              Display detailed module information"
    Write-Host "  -CheckForUpdates, -check            Check for available updates"
    Write-Host "  -Examples, -ex, -example            Show examples"
    Write-Host "  -Verbose                            Show verbose output"
    Write-Host "  -Path, -p <path>                    Specify path to search (default: current directory)"
    Write-Host "  -ShowHiddenFiles, -force            Show hidden files and directories"
    Write-Host ""

    Write-Host "Folder Filtering"  -ForegroundColor Yellow
    Write-Host "  -Depth -l -level <number>                   Limit display to specified number of directory levels"
    Write-Host "  -ExcludeDirectories, -e, -exclude           Exclude specified directory(s)"
    Write-Host "  -PruneEmptyFolders, -p                      Exclude empty folders from output, also excludes empty folders caused by filters"
    Write-Host "  -DirectoryOnly, -d                          Display only directories (no files)"
    Write-Host ""

    Write-Host "FILE FILTERING:" -ForegroundColor Yellow
    Write-Host "   Multiple files should be comma separated" -ForegroundColor Cyan
    Write-Host "  -IncludeExtensions, -if                     Include only files with specified extension(s)"
    Write-Host "  -ExcludeExtensions, -ef                     Exclude files with specified extension(s)"
    Write-Host "  -FileSizeMinimum -fmsi <size format>        Filters out all sizes below this size"
    Write-Host "  -FileSizeMaximum -fmsm <size format>        Filters out all sizes above this size"
    Write-Host ""

    Write-Host "DISPLAY OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -OutFile, -o, -of <filepath>                Save output to specified file path (defaults to .txt if no extension specified)"
    Write-Host "  -quiet, -q, -silent <number>                Suppress output to console (turns -OutFile on with default ./PowerTree.txt), (recommended for big trees)"
    Write-Host "  -DisplaySize, -s, -size                     Display file sizes in human-readable format"
    Write-Host "  -DisplayMode, -m, -dm                       Display mode of in file/folder (d - dir, a - archive, r - Read-only, h - hidden, s - system, l - reparse point, symlink etc)"
    Write-Host "  -DisplayModificationDate, -dmd,             Display modification date"
    Write-Host "  -DisplayCreationDate, -dcd,                 Display creation date"
    Write-Host "  -DisplayLastAccessDate, -dla,               Display last access date"
    Write-Host ""

    Write-Host "SORTING OPTIONS:" -ForegroundColor Yellow
    Write-Host "   You can use either the consolidated -Sort parameter OR individual sort switches:" -ForegroundColor Cyan
    Write-Host "  -SortBySize, -ss, -Sort size                Sort by size"
    Write-Host "  -SortByName, -sn, -Sort name                Sort alphabetically by name (default)"
    Write-Host "  -SortByModificationDate, -smd, -Sort md     Sort by last modified date"
    Write-Host "  -SortByCreationDate, -scd, -Sort cd         Sort by creation date"
    Write-Host "  -SortByLastAccessDate, -sla, -Sort la       Sort by last access date"
    Write-Host "  -Descending, -des, -desc                    Sort in Descending order"
    Write-Host ""

    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  PowerTree -Examples for more examples" -ForegroundColor Cyan
    Write-Host "  PowerTree                               Show all files and directories in current path"
    Write-Host "  PowerTree -Sort size                    Sort by size"
    Write-Host "  PowerTree -ss -desc                     Sort by size (Descending)"
    Write-Host "  PowerTree -DisplayDate md               Show modification dates for files"
    Write-Host "  PowerTree -e node_modules,bin           Exclude node_modules and bin directories"
    Write-Host "  PowerTree -if ps1,txt                   Show only PowerShell scripts and text files"
    Write-Host "  PowerTree -s -ss                        Show and sort by file sizes"
    Write-Host "  PowerTree -o C:\temp\output.txt         Save output to specified file"
    Write-Host ""

    Write-Host ""
    Write-CheckForUpdates
}
