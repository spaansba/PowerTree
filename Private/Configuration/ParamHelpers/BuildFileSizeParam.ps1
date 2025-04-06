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
