function Invoke-OutputBuilder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [TreeConfig]$TreeConfig,
        [bool]$ShowExecutionStats
    )

    # Only create OutputBuilder if we need to save to a file
    if ([string]::IsNullOrEmpty($TreeConfig.OutFile)) {
        return $null
    }

    $outputBuilder = New-Object System.Text.StringBuilder
    
    # Add configuration details to the output file
    [void]$outputBuilder.AppendLine("# PowerTree Output")
    [void]$outputBuilder.AppendLine("# Generated: $(Get-Date)")
    [void]$outputBuilder.AppendLine("# Path: $($TreeConfig.Path)")
    [void]$outputBuilder.AppendLine("# Output File: $($TreeConfig.OutFile)")

    # Basic configuration options
    if ($TreeConfig.DirectoryOnly) {
        [void]$outputBuilder.AppendLine("# DirectoryOnly: True")
    }

    if ($TreeConfig.Quiet) {
        [void]$outputBuilder.AppendLine("# Quiet Mode: True")
    }

    if ($TreeConfig.PruneEmptyFolders) {
        [void]$outputBuilder.AppendLine("# PruneEmptyFolders: True")
    }

    if ($TreeConfig.ShowHiddenFiles) {
        [void]$outputBuilder.AppendLine("# ShowHiddenFiles: True")
    }

    # Depth control
    if ($TreeConfig.MaxDepth -ne -1) {
        [void]$outputBuilder.AppendLine("# Max Depth: $($TreeConfig.MaxDepth)")
    }
    
    # Excluded Directories
    if ($TreeConfig.ExcludeDirectories -and $TreeConfig.ExcludeDirectories.Count -gt 0) {
        [void]$outputBuilder.AppendLine("# ExcludedDirectories: $($TreeConfig.ExcludeDirectories -join ', ')")
    }
    
    # Sorting configuration
    $sortByText = if ([string]::IsNullOrEmpty($TreeConfig.SortBy)) { "Name" } else { $TreeConfig.SortBy }
    $direction = if ($TreeConfig.SortDescending) { "Descending" } else { "Ascending" }
    [void]$outputBuilder.AppendLine("# Sort By: $sortByText $direction")
    
    # File extensions filtering
    $includeExtensions = @()
    $excludeExtensions = @()
    
    if ($TreeConfig.ChildItemFileParams -and $TreeConfig.ChildItemFileParams.ContainsKey("Include")) {
        $includeExtensions = $TreeConfig.ChildItemFileParams["Include"]
    }
    
    if ($TreeConfig.ChildItemFileParams -and $TreeConfig.ChildItemFileParams.ContainsKey("Exclude")) {
        $excludeExtensions = $TreeConfig.ChildItemFileParams["Exclude"]
    }
    
    if ($includeExtensions -and $includeExtensions.Count -gt 0) {
        [void]$outputBuilder.AppendLine("# IncludedFileTypes: $($includeExtensions -join ', ')")
    }
    
    if ($excludeExtensions -and $excludeExtensions.Count -gt 0) {
        [void]$outputBuilder.AppendLine("# ExcludedFileTypes: $($excludeExtensions -join ', ')")
    }
    
    # File Size Bounds
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
            default { $null }
        }
        
        if ($sizeFilterText) {
            [void]$outputBuilder.AppendLine("# File Size Filter: $sizeFilterText")
        }
    }
    
    # Display configuration
    $displayColumns = @()
    foreach ($column in $TreeConfig.HeaderTable.HeaderColumns) {
        if ($column -ne "Hierarchy") {
            $displayColumns += $column
        }
    }
    
    if ($displayColumns -and $displayColumns.Count -gt 0) {
        [void]$outputBuilder.AppendLine("# Displayed Columns: $($displayColumns -join ', ')")
    }
    
    [void]$outputBuilder.AppendLine("")

    if($ShowExecutionStats){
        [void]$outputBuilder.AppendLine("Append the stats here later!!")
    }

    return $outputBuilder
}