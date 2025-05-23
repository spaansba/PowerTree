function Get-RegistryItems {
    param (
        [Parameter(Mandatory=$true)]
        [string]$RegistryPath,
        [bool]$DisplayItemCounts = $false
    )
    
    $regKey = Get-Item -Path $RegistryPath -ErrorAction SilentlyContinue
    $allItems = @()
    
    # Add values to the all items object
    if ($regKey -and $regKey.ValueCount -gt 0) {
        foreach ($valueName in $regKey.GetValueNames()) {
            $valueType = $regKey.GetValueKind($valueName)
            $displayName = if ($valueName -eq "") { "(Default)" } else { $valueName }
            $value = $regKey.GetValue($valueName)
            $allItems += @{
                TypeName = $valueType.ToString()
                Name = $displayName
                Value = $value
                IsLast = $false  # Initialize as false
            }
        }
    }
    
    # Add child keys to the all items object
    $childKeys = Get-ChildItem -Path $RegistryPath -Name -ErrorAction SilentlyContinue
    if ($childKeys) {
        foreach ($key in $childKeys) {
            $keyPath = Join-Path $RegistryPath $key
            
            $keyItem = @{
                TypeName = "Key"
                Name = $key
                Path = $keyPath
                IsLast = $false  # Initialize as false
            }
            
            # Only calculate counts if needed
            if ($DisplayItemCounts) {
                $subKey = Get-Item -Path $keyPath -ErrorAction SilentlyContinue
                $keyItem.ValueCount = if ($subKey) { $subKey.ValueCount } else { 0 }
                $keyItem.SubKeyCount = (Get-ChildItem -Path $keyPath -ErrorAction SilentlyContinue | Measure-Object).Count
            }
            
            $allItems += $keyItem
        }
    }
    
    # Mark the last item as IsLast = $true
    if ($allItems.Count -gt 0) {
        $allItems[-1].IsLast = $true
    }
    
    return $allItems
}