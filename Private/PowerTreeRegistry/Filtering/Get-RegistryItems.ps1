function Get-RegistryItems {
    param (
        [Parameter(Mandatory=$true)]
        [string]$RegistryPath
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
            $allItems += @{
                TypeName = "Key"
                Name = $key
                Path = (Join-Path $RegistryPath $key)
                IsLast = $false  # Initialize as false
            }
        }
    }
    
    # Mark the last item as IsLast = $true
    if ($allItems.Count -gt 0) {
        $allItems[-1].IsLast = $true
    }
    
    return $allItems
}