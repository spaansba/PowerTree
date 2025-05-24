

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
