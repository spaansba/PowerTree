function Write-PSTreeHelp {
    Write-Host ""

    Write-Host "BASIC OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -Help, -?, -h                       Help"
    Write-Host "  -Examples                           Show examples"
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
    Write-Host "  -SortByVersion, -sv -Sort version           Sort by version numbers in filenames"
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
}

function Write-ExamplesHelp {
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Magenta
    Write-Host ""

    Write-Host "POWERFUL COMBINED SCENARIOS:" -ForegroundColor Cyan
    Write-Host "  PowerTree -s -ss -Depth 5 -e .next,node_modules  Show file sizes sorted on file size, 5 levels deep, excluding .next and node_modules"
    Write-Host "  PowerTree -p -Depth 3 -s -ss -desc               Prune empty folders, 3 levels deep, show sizes descending"
    Write-Host "  PowerTree -Quiet -e node_modules,bin -if ps1,md  Silent mode, exclude specific dirs, show only PS1 and MD files"
    Write-Host "  PowerTree -force -fsmi 1MB -smd                  Show hidden files, files larger than 1MB, sorted by modification date"
    Write-Host "  PowerTree -s -dm -dmd -Sort version              Show sizes, modes, mod dates, sorted by version numbers"
    Write-Host "  PowerTree -o project_summary.txt -p              Save output to file, prune empty folders"
    Write-Host "  PowerTree -ef dll,exe -fsma 10MB                 Exclude DLL and EXE, show files smaller than 10MB"
    Write-Host ""

    Write-Host "EXAMPLE PER CATEGORY:" -ForegroundColor Magenta
    Write-Host ""

    Write-Host "BASIC USAGE:" -ForegroundColor Cyan
    Write-Host "  PowerTree                               Show all files and directories in current path"
    Write-Host "  PowerTree C:\Projects\MyApp             Show files and directories in specified path"
    Write-Host "  PowerTree -Depth 2                      Limit display to 2 directory levels"
    Write-Host "  PowerTree -PruneEmptyFolders            Remove empty folders from the tree"
    Write-Host "  PowerTree -Quiet                        Suppress console output and save to PowerTree.txt"
    Write-Host ""
    
    Write-Host "FILE & DIRECTORY FILTERING:" -ForegroundColor Cyan
    Write-Host "  PowerTree -DirectoryOnly                Show only directories, no files"
    Write-Host "  PowerTree -d                            Short form for DirectoryOnly"
    Write-Host "  PowerTree -e node_modules,bin,obj       Exclude specified directories"
    Write-Host "  PowerTree -if ps1,txt,log               Show only PowerShell, text, and log files"
    Write-Host "  PowerTree -ef dll,exe,bin               Exclude DLL, executable, and binary files"
    Write-Host "  PowerTree -force                        Show hidden files and directories"
    Write-Host "  PowerTree -p                            Prune and remove empty folders"
    Write-Host ""
    
    Write-Host "DEPTH & FOLDER CONTROL:" -ForegroundColor Cyan
    Write-Host "  PowerTree -Depth 3                      Show only up to 3 directory levels"
    Write-Host "  PowerTree -Depth 1                      Show only first-level directories and files"
    Write-Host "  PowerTree -p -Depth 2                   Prune empty folders, limit to 2 levels"
    Write-Host ""
    
    Write-Host "SIZE-BASED FILTERING:" -ForegroundColor Cyan
    Write-Host "  PowerTree -fsmi 1MB                     Show only files larger than 1MB"
    Write-Host "  PowerTree -fsma 500KB                   Show only files smaller than 500KB"
    Write-Host "  PowerTree -fsmi 100KB -fsma 10MB        Show files between 100KB and 10MB in size"
    Write-Host ""
        
    Write-Host "SORTING OPTIONS:" -ForegroundColor Cyan
    Write-Host "  PowerTree -ss                           Sort by file size (ascending)"
    Write-Host "  PowerTree -Sort size                    Alternative syntax for sorting by size"
    Write-Host "  PowerTree -ss -desc                     Sort by file size (descending)"
    Write-Host "  PowerTree -smd                          Sort by last modification date"
    Write-Host "  PowerTree -Sort md                      Alternative syntax for sorting by modification date"
    Write-Host "  PowerTree -scd                          Sort by creation date"
    Write-Host "  PowerTree -sla                          Sort by last access date"
    Write-Host "  PowerTree -sv                           Sort by version numbers in filenames"
    Write-Host ""
    
    Write-Host "DISPLAY OPTIONS:" -ForegroundColor Cyan
    Write-Host "  PowerTree -s                            Display file sizes in human-readable format"
    Write-Host "  PowerTree -dm                           Display file/folder attributes (d,a,r,h,s,l)"
    Write-Host "  PowerTree -dmd                          Display modification dates"
    Write-Host "  PowerTree -dcd                          Display creation dates"
    Write-Host "  PowerTree -dla                          Display last access dates"
    Write-Host "  PowerTree -s -dmd -dm                   Show sizes, modification dates, and attributes"
    Write-Host ""
    
    Write-Host "OUTPUT OPTIONS:" -ForegroundColor Cyan
    Write-Host "  PowerTree -o tree_output                Save output to tree_output.txt"
    Write-Host "  PowerTree -o C:\temp\tree.md            Save output to specified file path"
    Write-Host "  PowerTree -Quiet                        Suppress console output, save to PowerTree.txt"
    Write-Host "  PowerTree -Quiet -o custom_report.txt   Suppress output, save to custom file"
    Write-Host ""
    
    Write-Host "ADVANCED COMBINED EXAMPLES:" -ForegroundColor Cyan
    Write-Host "  PowerTree -s -ss -desc -e node_modules  Show sizes, sort by size (descending), exclude node_modules"
    Write-Host "  PowerTree -if ps1,log -dmd              Show only PS1 and log files with modification dates"
    Write-Host "  PowerTree -s -ss -desc -fsmi 10MB       Find large files (>10MB), sort by size descending"
    Write-Host "  PowerTree -p -Depth 2 -s                Prune empty folders, show 2 levels with sizes"
    Write-Host "  PowerTree -Quiet -e bin,obj -s          Silent mode, exclude directories, show sizes"
    Write-Host ""
}