function Get-RegistryItems {
    param (
        [Parameter(Mandatory=$true)]
        [string]$RegistryPath,
        [bool]$DisplayItemCounts = $false,
        [bool]$SortValuesByType = $false,
        [bool]$SortDescending = $false,
        [bool]$UseRegistryDataTypes = $false
    )
    
    # Registry type mapping from PowerShell types to registry types
    $registryTypeMap = @{
        'String'       = 'REG_SZ'
        'ExpandString' = 'REG_EXPAND_SZ'
        'Binary'       = 'REG_BINARY'
        'DWord'        = 'REG_DWORD'
        'MultiString'  = 'REG_MULTI_SZ'
        'QWord'        = 'REG_QWORD'
        'Unknown'      = 'REG_NONE'
    }
    
    $regKey = Get-Item -Path $RegistryPath -ErrorAction SilentlyContinue
    $allItems = @()
    
    # Add values to the all items object
    if ($regKey -and $regKey.ValueCount -gt 0) {
        $valueItems = @()
        foreach ($valueName in $regKey.GetValueNames()) {
            $valueType = $regKey.GetValueKind($valueName)
            $displayName = if ($valueName -eq "") { "(Default)" } else { $valueName }
            $value = $regKey.GetValue($valueName)
            
            # Choose between PowerShell type or Registry type
            $displayType = if ($UseRegistryDataTypes) {
                $registryTypeMap[$valueType.ToString()]
            } else {
                $valueType.ToString()
            }
            
            $valueItems += [PSCustomObject]@{
                TypeName = $displayType
                Name = $displayName
                Value = $value
                IsLast = $false
            }
        }
        
        # Sort values like Registry Editor: (Default) first, then alphabetical (unless overridden by type sorting)
        if (-not $SortValuesByType) {
            $defaultValue = $valueItems | Where-Object { $_.Name -eq "(Default)" }
            $otherValues = $valueItems | Where-Object { $_.Name -ne "(Default)" }
            
            # Sort other values by name with descending option
            if ($SortDescending) {
                $otherValues = $otherValues | Sort-Object Name -Descending
            } else {
                $otherValues = $otherValues | Sort-Object Name
            }
            
            # Add default first (if exists), then other values
            if ($defaultValue) {
                $allItems += $defaultValue
            }
            $allItems += $otherValues
        } else {
            # When sorting by type, include all values for later sorting
            $allItems += $valueItems
        }
    }
    
    # Add child keys to the all items object
    $childKeys = Get-ChildItem -Path $RegistryPath -Name -ErrorAction SilentlyContinue
    if ($childKeys) {
        # Sort child keys by name with descending option (unless overridden by type sorting)
        if (-not $SortValuesByType) {
            if ($SortDescending) {
                $childKeys = $childKeys | Sort-Object -Descending
            } else {
                $childKeys = $childKeys | Sort-Object
            }
        }
        
        foreach ($key in $childKeys) {
            $keyPath = Join-Path $RegistryPath $key
            
            $keyItem = [PSCustomObject]@{
                TypeName = "Key"
                Name = $key
                Path = $keyPath
                IsLast = $false
            }
            
            # Only calculate counts if needed
            if ($DisplayItemCounts) {
                $keyItem | Add-Member -NotePropertyName "ValueCount" -NotePropertyValue $(if ((Get-Item -Path $keyPath -ErrorAction SilentlyContinue)) { (Get-Item -Path $keyPath).ValueCount } else { 0 })
                $keyItem | Add-Member -NotePropertyName "SubKeyCount" -NotePropertyValue $((Get-ChildItem -Path $keyPath -ErrorAction SilentlyContinue | Measure-Object).Count)
            }
            
            $allItems += $keyItem
        }
    }
    
    # Sort by TypeName if requested (this overrides the natural registry order)
    if ($SortValuesByType -and $allItems.Count -gt 0) {
        if ($SortDescending) {
            $allItems = $allItems | Sort-Object TypeName -Descending
        } else {
            $allItems = $allItems | Sort-Object TypeName
        }
    }
    
    # Mark the last item as IsLast = $true (do this AFTER sorting)
    if ($allItems.Count -gt 0) {
        # Reset all IsLast flags
        foreach ($item in $allItems) {
            $item.IsLast = $false
        }
        # Set the last item
        $allItems[-1].IsLast = $true
    }
    
    return $allItems
}
