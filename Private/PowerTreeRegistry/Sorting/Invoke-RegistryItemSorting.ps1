
function Invoke-RegistryItemSorting {
    param (
        [array]$ValueItems,
        [array]$KeyItems,
        [bool]$SortValuesByType,
        [bool]$SortDescending
    )
    
    $allItems = @()
    
    # Handle value sorting
    if ($ValueItems.Count -gt 0) {
        if (-not $SortValuesByType) {
            # Registry Editor style: (Default) first, then alphabetical
            $defaultValue = $ValueItems | Where-Object { $_.Name -eq "(Default)" }
            $otherValues = $ValueItems | Where-Object { $_.Name -ne "(Default)" }
            
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
            # When sorting by type, add all values for later sorting
            $allItems += $ValueItems
        }
    }
    
    # Handle key sorting
    if ($KeyItems.Count -gt 0) {
        if (-not $SortValuesByType) {
            # Sort child keys by name with descending option
            if ($SortDescending) {
                $KeyItems = $KeyItems | Sort-Object Name -Descending
            } else {
                $KeyItems = $KeyItems | Sort-Object Name
            }
        }
        $allItems += $KeyItems
    }
    
    # Sort by TypeName if requested (this overrides the natural registry order)
    if ($SortValuesByType -and $allItems.Count -gt 0) {
        if ($SortDescending) {
            $allItems = $allItems | Sort-Object TypeName -Descending
        } else {
            $allItems = $allItems | Sort-Object TypeName
        }
    }
    
    return $allItems
}
