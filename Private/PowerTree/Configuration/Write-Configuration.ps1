function Write-Configuration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$TreeConfig
    )

    # Don't show configuration if we're outputting to a file
    if (-not [string]::IsNullOrEmpty($TreeConfig.OutFile)) {
        return
    }
    
    $absolutePath = Resolve-Path $TreeConfig.Path -ErrorAction SilentlyContinue
    if ($null -eq $absolutePath) {
        Write-Host "Path not found: $($TreeConfig.Path)" -ForegroundColor Red
        return
    }
    
    $sortByText = if ([string]::IsNullOrEmpty($TreeConfig.SortBy)) { "Name" } else { $TreeConfig.SortBy }
    $direction = if ($TreeConfig.SortDescending) { "Descending" } else { "Ascending" }
    $sortDisplay = "$sortByText $direction"
    
    $displayItems = @()
    foreach ($headerColumn in $TreeConfig.HeaderTable.HeaderColumns) {
        if ($headerColumn -ne "Hierarchy") {
            $displayItems += $headerColumn
        }
    }
    
    $displayText = $displayItems -join ", "
    
    Write-Host ""
    Write-Verbose "Some settings might be sourced from the .config.json file" 
    Write-Host "Sort By: $sortDisplay" -ForegroundColor Green
    Write-Host "Display: $displayText" -ForegroundColor Green

    if ($TreeConfig.HumanReadableSize -ne $true) {
        Write-Host "Human Readable Sizes: False" -ForegroundColor Green
    } else {
        Write-Verbose "Human Readbale Sizes: True"
    }

    # Explicitly display or verbose output for various configuration options
    if ($TreeConfig.ShowHiddenFiles) {
        Write-Host "ShowHiddenFiles: True" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "ShowHiddenFiles: False"
    }
    
    if ($TreeConfig.DirectoryOnly) {
        Write-Host "DirectoryOnly: True" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "DirectoryOnly: False"
    }
    
    if ($TreeConfig.PruneEmptyFolders) {
        Write-Host "PruneEmptyFolders: True" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "PruneEmptyFolders: False"
    }
    
    if ($TreeConfig.ExcludeDirectories -and $TreeConfig.ExcludeDirectories.Count -gt 0) {
        Write-Host "ExcludedDirectories: $($TreeConfig.ExcludeDirectories -join ', ')" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "No directories excluded"
    }

    if ($TreeConfig.MaxDepth -ne -1) {
        Write-Host "Max Depth: $($TreeConfig.MaxDepth)" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "MaxDepth: -1 (no limit)"
    }
    
    # Extension filtering
    $includeExtensions = @()
    $excludeExtensions = @()
    
    if ($TreeConfig.ChildItemFileParams -and $TreeConfig.ChildItemFileParams.ContainsKey("Include")) {
        $includeExtensions = $TreeConfig.ChildItemFileParams["Include"]
    }
    
    if ($TreeConfig.ChildItemFileParams -and $TreeConfig.ChildItemFileParams.ContainsKey("Exclude")) {
        $excludeExtensions = $TreeConfig.ChildItemFileParams["Exclude"]
    }
    
    if ($excludeExtensions -and $excludeExtensions.Count -gt 0) {
        Write-Host "ExcludedFileTypes: $($excludeExtensions -join ', ')" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "No file types excluded"
    }
    
    if ($includeExtensions -and $includeExtensions.Count -gt 0) {
        Write-Host "IncludedFileTypes: $($includeExtensions -join ', ')" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "No specific file types included"
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
            Write-Host "File Size Filter: $sizeFilterText" -ForegroundColor Green
        }
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "No file size filtering applied"
    }
    
    # Output file handling
    if (-not [string]::IsNullOrEmpty($TreeConfig.OutFile)) {
        Write-Host "Output File: $($TreeConfig.OutFile)" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "No output file specified"
    }
    
    Write-Host ""
}