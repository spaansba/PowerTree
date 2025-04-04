function Build-FileSizeParams {
    param (
        [long]$CommandLineMaxSize,
        [long]$CommandLineMinSize,
        [long]$SettingsLineMaxSize,
        [long]$SettingsLineMinSize
    )
    # Track whether values come from settings
    $maxFromSettings = $CommandLineMaxSize -lt 0
    $minFromSettings = $CommandLineMinSize -lt 0

    # Prefer command line values if provided
    $maxSize = if ($CommandLineMaxSize -ge 0) { $CommandLineMaxSize } else { $SettingsLineMaxSize }
    $minSize = if ($CommandLineMinSize -ge 0) { $CommandLineMinSize } else { $SettingsLineMinSize }

    # If both max and min are non-negative, validate. Also if one of the values came from the settings add it for clarity
    if ($maxSize -ge 0 -and $minSize -ge 0 -and $maxSize -lt $minSize) {
        $errorMessage = "Error: Maximum file size cannot be smaller than minimum file size.`n"
        $errorMessage += "  Maximum Size: $maxSize bytes" + $(if ($maxFromSettings) { " (from configuration settings)" } else { "" }) + "`n"
        $errorMessage += "  Minimum Size: $minSize bytes" + $(if ($minFromSettings) { " (from configuration settings)" } else { "" }) + "`n"

        Write-Host $errorMessage -ForegroundColor Red
        exit 1
    }

    return @{
        LowerBound = $minSize
        UpperBound = $maxSize
        ShouldFilter = ($minSize -ge 0) -or ($maxSize -ge 0)
    }
}

function Build-ExcludedDirectoryParams {
    param (
        [string[]]$CommandLineExcludedDir = @(),
        [hashtable]$Settings
    )

    $excludedDirs = @()
    
    # Add settings excluded directories if they exist
    if ($Settings -and $Settings.ExcludeDirectories -and $Settings.ExcludeDirectories.Count -gt 0) {
        $excludedDirs += $Settings.ExcludeDirectories
    }
    
    # Add command line excluded directories if they exist
    if ($CommandLineExcludedDir -and $CommandLineExcludedDir.Count -gt 0) {
        foreach ($dir in $CommandLineExcludedDir) {
            if ($excludedDirs -notcontains $dir) { # Exclude duppies
                $excludedDirs += $dir
            }
        }
    }
    
    return $excludedDirs
}

function Build-ChildItemDirectoryParams {
    param(
        [boolean]$ShowHiddenFiles
    )

    $dirParams = @{
        Directory = $true
        ErrorAction = "SilentlyContinue"
    }
    
    if ($ShowHiddenFiles) {
        $dirParams.Add("Force", $true)
    }
    return $dirParams 
}

# Build file parameter hashtable (for some reason we cant add the path variable here)
function Build-ChildItemFileParams {
    param(
        [boolean]$ShowHiddenFiles,
        [string[]]$CommandLineIncludeExt = @(),
        [string[]]$CommandLineExcludeExt = @(),
        [hashtable]$FileSettings
    )

    $fileParams = @{
        File = $true
        ErrorAction = "SilentlyContinue"
    }
    
    if ($ShowHiddenFiles) {
        $fileParams.Add("Force", $true) 
    }

    # Determine which extensions to use (command line or config file)
    $includeExtensions = @()
    $excludeExtensions = @()
    
    # For Include Extensions - check if command line parameters are provided
    if ($CommandLineIncludeExt -and $CommandLineIncludeExt.Count -gt 0) {
        # Command-line parameters take precedence
        $includeExtensions = $CommandLineIncludeExt
    }
    elseif ($FileSettings -and $FileSettings.IncludeExtensions -and $FileSettings.IncludeExtensions.Count -gt 0) {
        # Fall back to config file FileSettings if available
        $includeExtensions = $FileSettings.IncludeExtensions
    }
    
    # For Exclude Extensions - check if command line parameters are provided
    if ($CommandLineExcludeExt -and $CommandLineExcludeExt.Count -gt 0) {
        $excludeExtensions = $CommandLineExcludeExt
    }
    elseif ($FileSettings -and $FileSettings.ExcludeExtensions -and $FileSettings.ExcludeExtensions.Count -gt 0) {
        $excludeExtensions = $FileSettings.ExcludeExtensions
    }
    
    # Format the extensions for PowerShell commands
    $normalizedIncludeExt = Format-FileExtensions -Extensions $includeExtensions
    $normalizedExcludeExt = Format-FileExtensions -Extensions $excludeExtensions
    
    # Add to parameters if not empty
    if ($normalizedIncludeExt -and $normalizedIncludeExt.Count -gt 0) {
        $fileParams.Add("Include", $normalizedIncludeExt)
    }
    
    if ($normalizedExcludeExt -and $normalizedExcludeExt.Count -gt 0) {
        $fileParams.Add("Exclude", $normalizedExcludeExt)
    }

    return $fileParams
}

function Build-TreeLineStyle {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("ASCII", "Unicode")]
        [string]$Style
    )
    
    $lineStyles = @{
        ASCII = @{
            Branch = "+----"       # Branch connector
            VerticalLine = "|   "  # Vertical connector
            LastBranch = "\----"   # Last item branch
            Vertical = "|"         # Vertical line
            Space = "    "         # Space for indentation after last branch
        }
        Unicode = @{
            Branch = "├───"        # Branch connector
            VerticalLine = "│   "  # Vertical connector
            LastBranch = "└───"    # Last item branch
            Vertical = "│"         # Vertical line
            Space = "    "         # Space for indentation after last branch
        }
    }
    
    return $lineStyles[$Style]
}