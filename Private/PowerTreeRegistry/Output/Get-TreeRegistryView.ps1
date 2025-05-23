function Get-TreeRegistryView {
    param (
        [Parameter(Mandatory=$true)]
        [TreeRegistryConfig]$TreeRegistryConfig,
        [string]$CurrentPath = $TreeRegistryConfig.Path,
        [bool]$EscapeWildcards = $false,
        [string]$TreeIndent = "",
        [bool]$IsRoot = $true,
        [int]$CurrentDepth = 0
    )
 
    # Only escape if we're in a recursive call
    $pathToUse = if ($EscapeWildcards) {
        $CurrentPath -replace '\*', '[*]' -replace '\?', '[?]'
    } else {
        $CurrentPath
       
    }

    if ($IsRoot) {
        Write-Host "Type       Hierarchy" -ForegroundColor Magenta
        Write-Host "────       ─────────" -ForegroundColor Magenta
        $keyName = Split-Path $CurrentPath -Leaf
        Write-Host "Key        $TreeIndent$keyName"
    }

    # Check if we've reached the maximum depth
    if ($TreeRegistryConfig.MaxDepth -ne -1 -and $CurrentDepth -ge $TreeRegistryConfig.MaxDepth) {
        return
    }

    $allItems = Get-RegistryItems -RegistryPath $pathToUse

    foreach ($item in $allItems) {
        if ($item.isLast) {
            $itemPrefix = "$TreeIndent$($TreeRegistryConfig.lineStyle.LastBranch)"
            $newTreeIndent = "$TreeIndent$($TreeRegistryConfig.lineStyle.Space)"
        } else {
            $itemPrefix = "$TreeIndent$($TreeRegistryConfig.lineStyle.Branch)"
            $newTreeIndent = "$TreeIndent$($TreeRegistryConfig.lineStyle.VerticalLine)"
        }

        if ($item.TypeName -eq "Key") {
            Write-Host "$($item.TypeName.PadRight(10)) $itemPrefix$($item.Name)"
            Get-TreeRegistryView -TreeRegistryConfig $TreeRegistryConfig -CurrentPath $item.Path -EscapeWildcards $true -TreeIndent $newTreeIndent -IsRoot $false -CurrentDepth ($CurrentDepth + 1)
        } else {
            Write-Host "$($item.TypeName.PadRight(10)) $itemPrefix" -NoNewline
            Write-Host $item.Name -ForegroundColor DarkGray -NoNewline

            if (-not $TreeRegistryConfig.DontDisplayValues) {
                Write-Host " = " -NoNewline
                Write-Host $item.Value -ForegroundColor Yellow
            } else {
                Write-Host ""
            }
        }
    }
}