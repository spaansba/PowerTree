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
    
    $registryTypeMap = @{
        'String'       = 'REG_SZ'
        'ExpandString' = 'REG_EXPAND_SZ'
        'Binary'       = 'REG_BINARY'
        'DWord'        = 'REG_DWORD'
        'MultiString'  = 'REG_MULTI_SZ'
        'QWord'        = 'REG_QWORD'
        'Unknown'      = 'REG_NONE'
    }
    
    $valueItems = @()
    if ($regKey.ValueCount -gt 0) {
        $valueItems = Get-ProcessedRegistryValues -RegKey $regKey -RegistryTypeMap $registryTypeMap -UseRegistryDataTypes $UseRegistryDataTypes -Include $Include -Exclude $Exclude -HasValueFilters $hasValueFilters
    }
    
    $keyItems = Get-ProcessedRegistryKeys -RegistryPath $RegistryPath -Exclude $Exclude -HasKeyFilters $hasKeyFilters -DisplayItemCounts $DisplayItemCounts
    $allItems = Invoke-RegistryItemSorting -ValueItems $valueItems -KeyItems $keyItems -SortValuesByType $SortValuesByType -SortDescending $SortDescending
    $allItems = Set-LastItemFlag -Items $allItems
    
    return $allItems
}
