
function Build-ExcludedDirectoryParams {
    param (
        [string[]]$CommandLineExcludedDir = @(),
        [hashtable]$Settings
    )

    $excludedDirs = @()
    
    if ($Settings -and $Settings.ExcludeDirectories -and $Settings.ExcludeDirectories.Count -gt 0) {
        $excludedDirs += $Settings.ExcludeDirectories
    }
    
    if ($CommandLineExcludedDir -and $CommandLineExcludedDir.Count -gt 0) {
        foreach ($dir in $CommandLineExcludedDir) {
            if ($excludedDirs -notcontains $dir) { # Exclude duppies
                $excludedDirs += $dir
            }
        }
    }
    
    return $excludedDirs
}
