function Initialize-OutputBuilder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [TreeConfig]$TreeConfig,
        [boolean]$ShowExecutionStats
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
function Write-ToFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Content,
        
        [Parameter(Mandatory=$true)]
        [bool]$OpenOutputFileOnFinish
    )
    
    begin {
        try {
            # Ensure the directory exists
            $directory = Split-Path -Path $FilePath -Parent
            if (-not [string]::IsNullOrEmpty($directory) -and -not (Test-Path -Path $directory)) {
                New-Item -Path $directory -ItemType Directory -Force | Out-Null
                Write-Verbose "Created directory: $directory"
            }
            
            # Create or clear the file
            if (Test-Path -Path $FilePath) {
                Clear-Content -Path $FilePath
                Write-Verbose "Cleared existing file: $FilePath"
            } else {
                New-Item -Path $FilePath -ItemType File -Force | Out-Null
                Write-Verbose "Created new file: $FilePath"
            }
        } catch {
            Write-Error "Failed to initialize output file: $_"
            throw
        }
    }
    
    process {
        try {
            $Content | Add-Content -Path $FilePath
        } catch {
            Write-Error "Failed to write to output file: $_"
            throw
        }
    }
    
    end {
        Write-Verbose "Successfully wrote output to $FilePath"
        
        # Open the file after writing if requested
        if ($OpenOutputFileOnFinish) {
            try {
                # Try to resolve the path to handle relative paths
                $resolvedPath = Resolve-Path $FilePath -ErrorAction Stop
                Write-Verbose "Opening file: $resolvedPath"
                
                # Use the appropriate method to open the file based on OS
                if ($IsWindows -or $null -eq $IsWindows) {
                    # On Windows or PowerShell 5.1 where $IsWindows is not defined
                    Start-Process $resolvedPath
                } elseif ($IsMacOS) {
                    # On macOS
                    Start-Process "open" -ArgumentList $resolvedPath
                } elseif ($IsLinux) {
                    # On Linux, try xdg-open first
                    try {
                        Start-Process "xdg-open" -ArgumentList $resolvedPath
                    } catch {
                        # If xdg-open fails, try other common utilities
                        try { Start-Process "nano" -ArgumentList $resolvedPath } catch { 
                            Write-Verbose "Could not open file with xdg-open or nano" 
                        }
                    }
                }
            } catch {
                Write-Warning "Could not open file after writing: $_"
            }
        }
    }
}

# Adds a default .txt extension to a file path if it doesn't already have an extension
function Add-DefaultExtension {
    param (
        [string]$FilePath,
        [bool]$Quiet
    )
    
    if ([string]::IsNullOrEmpty($FilePath)) {
        # If no filepath is set and Quiet is true, use default "PowerTree.txt"
        if ($Quiet) {
            return "PowerTree.txt"
        }
        return $FilePath # meaning no outfile
    }
    
    if ([string]::IsNullOrEmpty([System.IO.Path]::GetExtension($FilePath))) {
        return "$FilePath.txt"
    }
    
    return $FilePath
}