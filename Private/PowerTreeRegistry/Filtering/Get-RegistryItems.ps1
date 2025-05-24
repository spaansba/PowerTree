function Get-RegistryItems {
    param (
        [Parameter(Mandatory=$true)]
        [string]$RegistryPath,
        [bool]$DisplayItemCounts = $false,
        [bool]$SortValuesByType = $false,
        [bool]$SortDescending = $false,
        [bool]$UseRegistryDataTypes = $false,
        [string[]]$Exclude = @(),
        [string[]]$Include = @()
    )
    
    # Fixed the typo: was $Exclude.Count -gt 0 -or $Exclude.Count -gt 0
    $hasValueFilters = $Include.Count -gt 0 -or $Exclude.Count -gt 0
    $hasKeyFilters = $Exclude.Count -gt 0 
    
    $regKey = Get-Item -LiteralPath $RegistryPath -ErrorAction SilentlyContinue
    if (-not $regKey) {
        return @()
    }
    
    # Get registry type mapping
    $registryTypeMap = Get-RegistryTypeMapping
    
    # Process registry values
    $valueItems = @()
    if ($regKey.ValueCount -gt 0) {
        $valueItems = Get-ProcessedRegistryValues -RegKey $regKey -RegistryTypeMap $registryTypeMap -UseRegistryDataTypes $UseRegistryDataTypes -Include $Include -Exclude $Exclude -HasValueFilters $hasValueFilters
    }
    
    # Process registry keys
    $keyItems = Get-ProcessedRegistryKeys -RegistryPath $RegistryPath -Exclude $Exclude -HasKeyFilters $hasKeyFilters -DisplayItemCounts $DisplayItemCounts
    
    # Sort all items
    $allItems = Invoke-RegistryItemSorting -ValueItems $valueItems -KeyItems $keyItems -SortValuesByType $SortValuesByType -SortDescending $SortDescending
    
    # Set the last item flag
    $allItems = Set-LastItemFlag -Items $allItems
    
    return $allItems
}

function Get-RegistryTypeMapping {
    return @{
        'String'       = 'REG_SZ'
        'ExpandString' = 'REG_EXPAND_SZ'
        'Binary'       = 'REG_BINARY'
        'DWord'        = 'REG_DWORD'
        'MultiString'  = 'REG_MULTI_SZ'
        'QWord'        = 'REG_QWORD'
        'Unknown'      = 'REG_NONE'
    }
}
