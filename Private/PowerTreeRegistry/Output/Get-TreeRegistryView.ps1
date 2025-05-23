function Get-TreeRegistryView {
    param (
        [Parameter(Mandatory=$true)]
        [TreeRegistryConfig]$TreeRegistryConfig,
        [string]$CurrentPath = $TreeRegistryConfig.Path,
        [bool]$EscapeWildcards = $false,
        [string]$TreeIndent = "",
        [bool]$IsRoot = $true
    )

    # Only escape if we're in a recursive call
    $pathToUse = if ($EscapeWildcards) {
        $CurrentPath -replace '\*', '[*]' -replace '\?', '[?]'
    } else {
        $CurrentPath
    }
    
    # Print header and root key name if this is the root call
    if ($IsRoot) {
        Write-Host "Type       Hierarchy" -ForegroundColor Magenta
        Write-Host "────       ─────────" 
        $keyName = Split-Path $CurrentPath -Leaf
        Write-Host "Key        $TreeIndent$keyName"
    }
    
    # Get the registry key object using the full path
    $regKey = Get-Item -Path $pathToUse -ErrorAction SilentlyContinue
    
    # Collect all items (values and child keys) in a single array
    $allItems = @()
    
    # Add values
    if ($regKey -and $regKey.ValueCount -gt 0) {
        foreach ($valueName in $regKey.GetValueNames()) {
            $valueType = $regKey.GetValueKind($valueName)
            $displayName = if ($valueName -eq "") { "(Default)" } else { $valueName }
            $allItems += @{
                TypeName = $valueType.ToString()
                Name = $displayName
            }
        }
    }
    
    # Add child keys
    $childKeys = Get-ChildItem -Path $pathToUse -Name -ErrorAction SilentlyContinue
    if ($childKeys) {
        foreach ($key in $childKeys) {
            $allItems += @{
                TypeName = "Key"
                Name = $key
                Path = (Join-Path $CurrentPath $key)
            }
        }
    }
    
    # Process all items
    foreach ($item in $allItems) {
        $isLast = ($item -eq $allItems[-1])
        
        if ($isLast) {
            $itemPrefix = "$TreeIndent└── "
            $newTreeIndent = "$TreeIndent     "
        } else {
            $itemPrefix = "$TreeIndent├── "
            $newTreeIndent = "$TreeIndent│    "
        }
        
        if ($item.TypeName -eq "Key") {
            Write-Host "$($item.TypeName.PadRight(10)) $itemPrefix$($item.Name)"
            Get-TreeRegistryView -TreeRegistryConfig $TreeRegistryConfig -CurrentPath $item.Path -EscapeWildcards $true -TreeIndent $newTreeIndent -IsRoot $false
        } else {
            Write-Host "$($item.TypeName.PadRight(10)) $itemPrefix" -NoNewline
            Write-Host $item.Name -ForegroundColor DarkGray
        }
    }
}