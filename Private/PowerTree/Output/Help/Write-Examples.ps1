
function Write-Examples {
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Magenta
    Write-Host ""

    Write-Host "POWERFUL COMBINED SCENARIOS:" -ForegroundColor Cyan
    Write-Host "  PowerTree -s -ss -Depth 5 -e .next,node_modules  Show file sizes sorted on file size, 5 levels deep, excluding .next and node_modules"
    Write-Host "  PowerTree -p -Depth 3 -s -ss -desc               Prune empty folders, 3 levels deep, show sizes descending"
    Write-Host "  PowerTree -e node_modules,bin -if ps1,md         Exclude specific dirs, show only PS1 and MD files"
    Write-Host "  PowerTree -force -fsmi 1MB -smd                  Show hidden files, files larger than 1MB, sorted by modification date"
    Write-Host "  PowerTree -s -dm -dmd                            Show sizes, modes, mod dates"
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
    Write-Host ""
    
    Write-Host "ADVANCED COMBINED EXAMPLES:" -ForegroundColor Cyan
    Write-Host "  PowerTree -s -ss -desc -e node_modules  Show sizes, sort by size (descending), exclude node_modules"
    Write-Host "  PowerTree -if ps1,log -dmd              Show only PS1 and log files with modification dates"
    Write-Host "  PowerTree -s -ss -desc -fsmi 10MB       Find large files (>10MB), sort by size descending"
    Write-Host "  PowerTree -p -Depth 2 -s                Prune empty folders, show 2 levels with sizes"
    Write-Host ""
}