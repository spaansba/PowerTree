function Get-TreeConfigurationData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$TreeConfig
    )
    
    $configLines = @()
    
    # Sort configuration
    $sortByText = if ([string]::IsNullOrEmpty($TreeConfig.SortBy)) { "Name" } else { $TreeConfig.SortBy }
    $direction = if ($TreeConfig.SortDescending) { "Descending" } else { "Ascending" }
    $configLines += "Sort By".PadRight(22) + " $sortByText $direction"
    
    # Display columns
    $displayColumns = @()
    foreach ($column in $TreeConfig.HeaderTable.HeaderColumns) {
        if ($column -ne "Hierarchy") {
            $displayColumns += $column
        }
    }
    $displayText = if ($displayColumns.Count -gt 0) { $displayColumns -join ", " } else { "Hierarchy Only" }
    $configLines += "Display Columns".PadRight(22) + " $displayText"
    
    # Human readable sizes
    $humanReadableText = if ($TreeConfig.HumanReadableSize -ne $true) { "False" } else { "True" }
    $configLines += "Human Readable Sizes".PadRight(22) + " $humanReadableText"
    
    # Directory only
    $configLines += "Directory Only".PadRight(22) + " $($TreeConfig.DirectoryOnly.ToString())"
    
    # Show hidden files
    $configLines += "Show Hidden Files".PadRight(22) + " $($TreeConfig.ShowHiddenFiles.ToString())"
    
    # Prune empty folders
    $configLines += "Prune Empty Folders".PadRight(22) + " $($TreeConfig.PruneEmptyFolders.ToString())"
    
    # Max depth
    $maxDepthText = if ($TreeConfig.MaxDepth -eq -1) { "Unlimited" } else { $TreeConfig.MaxDepth.ToString() }
    $configLines += "Max Depth".PadRight(22) + " $maxDepthText"
    
    # Excluded directories
    $excludedDirsText = if ($TreeConfig.ExcludeDirectories -and $TreeConfig.ExcludeDirectories.Count -gt 0) {
        $TreeConfig.ExcludeDirectories -join ", "
    } else {
        "None"
    }
    $configLines += "Excluded Directories".PadRight(22) + " $excludedDirsText"
    
    # File extension filtering
    $includeExtensions = @()
    $excludeExtensions = @()
    
    if ($TreeConfig.ChildItemFileParams -and $TreeConfig.ChildItemFileParams.ContainsKey("Include")) {
        $includeExtensions = $TreeConfig.ChildItemFileParams["Include"]
    }
    
    if ($TreeConfig.ChildItemFileParams -and $TreeConfig.ChildItemFileParams.ContainsKey("Exclude")) {
        $excludeExtensions = $TreeConfig.ChildItemFileParams["Exclude"]
    }
    
    $includeText = if ($includeExtensions.Count -gt 0) { $includeExtensions -join ", " } else { "None" }
    $excludeText = if ($excludeExtensions.Count -gt 0) { $excludeExtensions -join ", " } else { "None" }
    
    $configLines += "Include File Types".PadRight(22) + " $includeText"
    $configLines += "Exclude File Types".PadRight(22) + " $excludeText"
    
    # File size bounds
    if ($TreeConfig.FileSizeBounds) {
        $lowerBound = $TreeConfig.FileSizeBounds.LowerBound
        $upperBound = $TreeConfig.FileSizeBounds.UpperBound
        $humanReadableLowerBound = if ($lowerBound -ge 0) { Get-HumanReadableSize -Bytes $lowerBound -Format "Compact" } else { $null }
        $humanReadableUpperBound = if ($upperBound -ge 0) { Get-HumanReadableSize -Bytes $upperBound -Format "Compact" } else { $null }

        $sizeFilterText = switch ($true) {
            (($lowerBound -ge 0) -and ($upperBound -ge 0)) { 
                "Between $humanReadableLowerBound and $humanReadableUpperBound" 
            }
            (($lowerBound -ge 0) -and ($upperBound -lt 0)) { 
                "Minimum $humanReadableLowerBound" 
            }
            (($lowerBound -lt 0) -and ($upperBound -ge 0)) { 
                "Maximum $humanReadableUpperBound" 
            }
            default { "None" }
        }
        
        $configLines += "File Size Filter".PadRight(22) + " $sizeFilterText"
    } else {
        $configLines += "File Size Filter".PadRight(22) + " None"
    }
    
    $configLines += ""
    
    return $configLines
}