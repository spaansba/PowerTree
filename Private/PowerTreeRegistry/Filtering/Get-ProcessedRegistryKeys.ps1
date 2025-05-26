
function Get-ProcessedRegistryKeys {
    param (
        [string]$RegistryPath,
        [string[]]$Exclude,
        [bool]$HasKeyFilters,
        [bool]$DisplayItemCounts
    )
    
    $childKeys = Get-ChildItem -LiteralPath $RegistryPath -Name -ErrorAction SilentlyContinue
    if (-not $childKeys) {
        return @()
    }
    
    # Apply exclude filters to child keys only if needed
    if ($HasKeyFilters) {
        $filteredChildKeys = @()
        foreach ($key in $childKeys) {
            if (-not (Test-FilterMatch -ItemName $key -Patterns $Exclude)) {
                $filteredChildKeys += $key
            }
        }
    } else {
        $filteredChildKeys = $childKeys
    }
    
    $keyItems = @()
    foreach ($key in $filteredChildKeys) {
        $keyItem = [PSCustomObject]@{
            TypeName = "Key"
            Name = $key
            Path = Join-Path $RegistryPath $key
            IsLast = $false
        }
        
        # Only calculate counts if needed
        if ($DisplayItemCounts) {
            $keyItem | Add-Member -NotePropertyName "ValueCount" -NotePropertyValue $(if ((Get-Item -LiteralPath $keyPath -ErrorAction SilentlyContinue)) { (Get-Item -LiteralPath $keyPath).ValueCount } else { 0 })
            $keyItem | Add-Member -NotePropertyName "SubKeyCount" -NotePropertyValue $((Get-ChildItem -LiteralPath $keyPath -ErrorAction SilentlyContinue | Measure-Object).Count)
        }
        
        $keyItems += $keyItem
    }
    
    return $keyItems
}
