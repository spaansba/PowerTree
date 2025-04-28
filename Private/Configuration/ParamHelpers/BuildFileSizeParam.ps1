function Build-FileSizeParams {
    param (
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [string]$CommandLineMaxSize,
        
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [string]$CommandLineMinSize,
        
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [string]$SettingsLineMaxSize,
        
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [string]$SettingsLineMinSize
    )
    # Convert string values to bytes
    $cmdMaxBytes = ConvertTo-Bytes -SizeString $CommandLineMaxSize
    $cmdMinBytes = ConvertTo-Bytes -SizeString $CommandLineMinSize
    $settingsMaxBytes = ConvertTo-Bytes -SizeString $SettingsLineMaxSize
    $settingsMinBytes = ConvertTo-Bytes -SizeString $SettingsLineMinSize
    
    # Track whether values come from settings
    $maxFromSettings = $cmdMaxBytes -lt 0
    $minFromSettings = $cmdMinBytes -lt 0

    # Prefer command line values if provided
    $maxSize = if ($cmdMaxBytes -ge 0) { $cmdMaxBytes } else { $settingsMaxBytes }
    $minSize = if ($cmdMinBytes -ge 0) { $cmdMinBytes } else { $settingsMinBytes }

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
