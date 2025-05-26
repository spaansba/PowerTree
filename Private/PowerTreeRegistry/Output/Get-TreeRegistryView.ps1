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
 
    if ($IsRoot -and $null -eq $Stats) {
        $Stats = [RegistryStats]::new()
    }
    
    if ($null -ne $Stats) {
        $Stats.UpdateDepth($CurrentDepth)
    }
    
    # Only escape if we're in a recursive call
    $pathToUse = if ($EscapeWildcards) {
        $CurrentPath -replace '\*', '[*]' -replace '\?', '[?]'
    } else {
        $CurrentPath
    }
    
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
    
    if ($TreeRegistryConfig.MaxDepth -ne -1 -and $CurrentDepth -ge $TreeRegistryConfig.MaxDepth) {
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
    
    if ($null -ne $Stats) {
        $keyCount = ($allItems | Where-Object { $_.TypeName -eq "Key" }).Count
        $valueCount = ($allItems | Where-Object { $_.TypeName -ne "Key" }).Count
        
        $Stats.KeysProcessed += $keyCount
        $Stats.ValuesProcessed += $valueCount
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
            # Count info is for when DisplayItemCounts is true
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
            
            Get-TreeRegistryView -TreeRegistryConfig $TreeRegistryConfig -CurrentPath $item.Path -EscapeWildcards $true -TreeIndent $newTreeIndent -IsRoot $false -CurrentDepth ($CurrentDepth + 1) -OutputCollection $OutputCollection -Stats $Stats
        
        } else { # Writing the subkey
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