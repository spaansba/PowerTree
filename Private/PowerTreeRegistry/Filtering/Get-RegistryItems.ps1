

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
    
    # Check if we need to do any filtering
    $hasIncludeFilters = $Include.Count -gt 0
    $hasExcludeFilters = $Exclude.Count -gt 0
    $hasValueFilters = $hasIncludeFilters -or $hasExcludeFilters
    $hasKeyFilters = $hasExcludeFilters
    
    $regKey = Get-Item -LiteralPath $RegistryPath -ErrorAction SilentlyContinue
    $allItems = @()
    
    # Add values to the all items object
    if ($regKey -and $regKey.ValueCount -gt 0) {
        $valueItems = @()
        foreach ($valueName in $regKey.GetValueNames()) {
            $valueType = $regKey.GetValueKind($valueName)
            $displayName = if ($valueName -eq "") { "(Default)" } else { $valueName }
            $value = $regKey.GetValue($valueName)
            
            # Apply include/exclude filters only if needed (include and exclude both apply to values)
            if ($hasValueFilters) {
                $shouldInclude = ($Include.Count -eq 0) -or (Test-FilterMatch -ItemName $displayName -Patterns $Include)
                $shouldExclude = Test-FilterMatch -ItemName $displayName -Patterns $Exclude
                
                if (-not $shouldInclude -or $shouldExclude) {
                    continue
                }
            }
            
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
    $childKeys = Get-ChildItem -LiteralPath $RegistryPath -Name -ErrorAction SilentlyContinue
    if ($childKeys) {
        # Apply exclude filters to child keys only if needed (include doesn't apply to keys)
        if ($hasKeyFilters) {
            $filteredChildKeys = @()
            foreach ($key in $childKeys) {
                if (-not (Test-FilterMatch -ItemName $key -Patterns $Exclude)) {
                    $filteredChildKeys += $key
                }
            }
        } else {
            $filteredChildKeys = $childKeys
        }
        
        # Sort child keys by name with descending option (unless overridden by type sorting)
        if (-not $SortValuesByType -and $filteredChildKeys.Count -gt 0) {
            if ($SortDescending) {
                $filteredChildKeys = $filteredChildKeys | Sort-Object -Descending
            } else {
                $filteredChildKeys = $filteredChildKeys | Sort-Object
            }
        }
        
        foreach ($key in $filteredChildKeys) {
            $keyPath = Join-Path $RegistryPath $key
            
            $keyItem = [PSCustomObject]@{
                TypeName = "Key"
                Name = $key
                Path = $keyPath
                IsLast = $false
            }
            
            # Only calculate counts if needed
            if ($DisplayItemCounts) {
                $keyItem | Add-Member -NotePropertyName "ValueCount" -NotePropertyValue $(if ((Get-Item -LiteralPath $keyPath -ErrorAction SilentlyContinue)) { (Get-Item -LiteralPath $keyPath).ValueCount } else { 0 })
                $keyItem | Add-Member -NotePropertyName "SubKeyCount" -NotePropertyValue $((Get-ChildItem -LiteralPath $keyPath -ErrorAction SilentlyContinue | Measure-Object).Count)
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