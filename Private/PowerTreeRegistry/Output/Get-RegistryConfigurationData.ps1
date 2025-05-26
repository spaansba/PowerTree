function Get-RegistryConfigurationData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [TreeRegistryConfig]$TreeRegistryConfig
    )

    $configData = @()
    
    $sortByText = if ($TreeRegistryConfig.SortValuesByType) { "Type" } else { "Registry Order" }
    $direction = if ($TreeRegistryConfig.SortDescending) { "Descending" } else { "Ascending" }
    $configData += @{ Key = "Sort By"; Value = "$sortByText $direction" }
    
    $dataTypeText = if ($TreeRegistryConfig.UseRegistryDataTypes) { 
        "REG_SZ, REG_DWORD, etc." 
    } else { 
        "String, DWord, etc." 
    }
    $configData += @{ Key = "Type Format"; Value = $dataTypeText }
    $configData += @{ Key = "NoValues"; Value = $TreeRegistryConfig.NoValues }
    $configData += @{ Key = "DisplayItemCounts"; Value = $TreeRegistryConfig.DisplayItemCounts }
    $configData += @{ Key = "SortValuesByType"; Value = $TreeRegistryConfig.SortValuesByType }

    if ($TreeRegistryConfig.MaxDepth -ne -1) {
        $configData += @{ Key = "Max Depth"; Value = $TreeRegistryConfig.MaxDepth }
    } else {
        $configData += @{ Key = "Max Depth"; Value = "Unlimited" }
    }

    if ($TreeRegistryConfig.Include -and $TreeRegistryConfig.Include.Count -gt 0) {
        $configData += @{ Key = "Include (Values)"; Value = ($TreeRegistryConfig.Include -join ', ') }
    } else {
        $configData += @{ Key = "Include (Values)"; Value = "None" }
    }
    
    if ($TreeRegistryConfig.Exclude -and $TreeRegistryConfig.Exclude.Count -gt 0) {
        $configData += @{ Key = "Exclude (Keys/Values)"; Value = ($TreeRegistryConfig.Exclude -join ', ') }
    } else {
        $configData += @{ Key = "Exclude (Keys/Values)"; Value = "None" }
    }
    

    $maxKeyLength = ($configData | ForEach-Object { $_.Key.Length } | Measure-Object -Maximum).Maximum + 1
    
    $formattedData = $configData | ForEach-Object {
        $paddedKey = $_.Key.PadRight($maxKeyLength)
        "$paddedKey $($_.Value)"
    }
    
    return $formattedData
}