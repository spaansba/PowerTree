function Get-RegistryConfigurationData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [TreeRegistryConfig]$TreeRegistryConfig
    )

    $configData = @()
    
    # Sorting configuration
    $sortByText = if ($TreeRegistryConfig.SortValuesByType) { "Type" } else { "Registry Order" }
    $direction = if ($TreeRegistryConfig.SortDescending) { "Descending" } else { "Ascending" }
    $configData += @{ Key = "Sort By"; Value = "$sortByText $direction" }
    
    # Data type display
    $dataTypeText = if ($TreeRegistryConfig.UseRegistryDataTypes) { 
        "Registry Types (REG_SZ, REG_DWORD, etc.)" 
    } else { 
        "PowerShell Types (String, DWord, etc.)" 
    }
    $configData += @{ Key = "Data Types"; Value = $dataTypeText }

    # Display SubKeys
    $configData += @{ Key = "DisplaySubKeys"; Value = $TreeRegistryConfig.DisplaySubKeys }
    
    # No values option
    $configData += @{ Key = "NoValues"; Value = $TreeRegistryConfig.NoValues }

    # Display item counts
    $configData += @{ Key = "DisplayItemCounts"; Value = $TreeRegistryConfig.DisplayItemCounts }
    
    # Sort values by type
    $configData += @{ Key = "SortValuesByType"; Value = $TreeRegistryConfig.SortValuesByType }

    # Max depth
    if ($TreeRegistryConfig.MaxDepth -ne -1) {
        $configData += @{ Key = "Max Depth"; Value = $TreeRegistryConfig.MaxDepth }
    } else {
        $configData += @{ Key = "Max Depth"; Value = "Unlimited" }
    }
    
    # Include patterns
    if ($TreeRegistryConfig.Include -and $TreeRegistryConfig.Include.Count -gt 0) {
        $configData += @{ Key = "Include (Values)"; Value = ($TreeRegistryConfig.Include -join ', ') }
    } else {
        $configData += @{ Key = "Include (Values)"; Value = "None" }
    }
    
    # Exclude patterns
    if ($TreeRegistryConfig.Exclude -and $TreeRegistryConfig.Exclude.Count -gt 0) {
        $configData += @{ Key = "Exclude (Keys/Values)"; Value = ($TreeRegistryConfig.Exclude -join ', ') }
    } else {
        $configData += @{ Key = "Exclude (Keys/Values)"; Value = "None" }
    }
    
    # Calculate the maximum key length for formatting
    $maxKeyLength = ($configData | ForEach-Object { $_.Key.Length } | Measure-Object -Maximum).Maximum + 1
    
    # Format as table with proper spacing
    $formattedData = $configData | ForEach-Object {
        $paddedKey = $_.Key.PadRight($maxKeyLength)
        "$paddedKey $($_.Value)"
    }
    
    return $formattedData
}