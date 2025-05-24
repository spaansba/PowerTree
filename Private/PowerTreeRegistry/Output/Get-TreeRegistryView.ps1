function Get-TreeRegistryView {
    param (
        [Parameter(Mandatory=$true)]
        [TreeRegistryConfig]$TreeRegistryConfig,
        [string]$CurrentPath = $TreeRegistryConfig.Path,
        [bool]$EscapeWildcards = $false,
        [string]$TreeIndent = "",
        [bool]$IsRoot = $true,
        [int]$CurrentDepth = 0,
        [System.Collections.Generic.List[string]]$OutputCollection = $null,
        [RegistryStats]$Stats = $null
    )
 
    # Initialize stats only on root call
    if ($IsRoot -and $null -eq $Stats) {
        $Stats = [RegistryStats]::new()
    }
    
    # Update depth tracking
    if ($null -ne $Stats) {
        $Stats.UpdateDepth($CurrentDepth)
    }
    
    # Only escape if we're in a recursive call
    $pathToUse = if ($EscapeWildcards) {
        $CurrentPath -replace '\*', '[*]' -replace '\?', '[?]'
    } else {
        $CurrentPath
    }
    
    # Determine if we're collecting output for file
    $collectingOutput = $null -ne $OutputCollection
    
    if ($IsRoot) {
        if ($collectingOutput) {
            $OutputCollection.Add("Type         Hierarchy")
            $OutputCollection.Add($TreeRegistryConfig.lineStyle.RegistryHeaderSeparator)
            $keyName = Split-Path $CurrentPath -Leaf
            $OutputCollection.Add("Key          $TreeIndent$keyName")
        } else {
            Write-Host "Type         Hierarchy" -ForegroundColor Magenta
            Write-Host $TreeRegistryConfig.lineStyle.RegistryHeaderSeparator
            $keyName = Split-Path $CurrentPath -Leaf
            Write-Host "Key          $TreeIndent$keyName"
        }
    }
    
    # Check if we've reached the maximum depth
    if ($TreeRegistryConfig.MaxDepth -ne -1 -and $CurrentDepth -ge $TreeRegistryConfig.MaxDepth) {
        # Return stats if this is the root call
        if ($IsRoot) {
            return $Stats
        }
        return
    }
    
    $allItems = Get-RegistryItems -RegistryPath $pathToUse `
        -DisplayItemCounts $TreeRegistryConfig.DisplayItemCounts `
        -SortValuesByType $TreeRegistryConfig.SortValuesByType `
        -SortDescending $TreeRegistryConfig.SortDescending `
        -UseRegistryDataTypes $TreeRegistryConfig.UseRegistryDataTypes `
        -Exclude $TreeRegistryConfig.Exclude `
        -Include $TreeRegistryConfig.Include
    
    # Count items for stats
    if ($null -ne $Stats) {
        $keyCount = ($allItems | Where-Object { $_.TypeName -eq "Key" }).Count
        $valueCount = ($allItems | Where-Object { $_.TypeName -ne "Key" }).Count
        
        $Stats.KeysProcessed += $keyCount
        $Stats.ValuesProcessed += $valueCount
        $Stats.TotalSubKeys += $keyCount
        $Stats.TotalValues += $valueCount
    }
        
    foreach ($item in $allItems) {
        if ($item.isLast) {
            $itemPrefix = "$TreeIndent$($TreeRegistryConfig.lineStyle.LastBranch)"
            $newTreeIndent = "$TreeIndent$($TreeRegistryConfig.lineStyle.Space)"
        } else {
            $itemPrefix = "$TreeIndent$($TreeRegistryConfig.lineStyle.Branch)"
            $newTreeIndent = "$TreeIndent$($TreeRegistryConfig.lineStyle.VerticalLine)"
        }
        
        if ($item.TypeName -eq "Key") {
            $countInfo = ""
            if ($TreeRegistryConfig.DisplayItemCounts) {
                $countInfo = " ($($item.SubKeyCount) keys, $($item.ValueCount) values)"
            }
            
            if ($collectingOutput) {
                $OutputCollection.Add("$($item.TypeName.PadRight(12)) $itemPrefix$($item.Name)$countInfo")
            } else {
                Write-Host "$($item.TypeName.PadRight(12)) $itemPrefix$($item.Name)" -NoNewline
                Write-Host $countInfo -ForegroundColor DarkCyan
            }
            
            # Recursive call with stats
            Get-TreeRegistryView -TreeRegistryConfig $TreeRegistryConfig -CurrentPath $item.Path -EscapeWildcards $true -TreeIndent $newTreeIndent -IsRoot $false -CurrentDepth ($CurrentDepth + 1) -OutputCollection $OutputCollection -Stats $Stats
        
        } else {
            if ($collectingOutput) {
                if (-not $TreeRegistryConfig.NoValues) {
                    $OutputCollection.Add("$($item.TypeName.PadRight(12)) $itemPrefix$($item.Name) = $($item.Value)")
                } else {
                    $OutputCollection.Add("$($item.TypeName.PadRight(12)) $itemPrefix$($item.Name)")
                }
            } else {
                Write-Host "$($item.TypeName.PadRight(12)) $itemPrefix" -NoNewline
                Write-Host $item.Name -ForegroundColor DarkGray -NoNewline
                if (-not $TreeRegistryConfig.NoValues) {
                    Write-Host " = " -NoNewline
                    Write-Host $item.Value -ForegroundColor Yellow
                } else {
                    Write-Host ""
                }
            }
        }
    }
    
    if ($IsRoot) {
        return $Stats
    }
}