function Write-TreeSnapshot {
    param(
        [Parameter(Mandatory=$true)]
        [object]$Node,
        [Parameter(Mandatory=$true)]
        [object]$TreeConfig,
        [Parameter(Mandatory=$true)]
        [object]$TreeStats,
        [string]$TreeIndent = "",
        [bool]$IsRoot = $true,
        [System.Text.StringBuilder]$OutputBuilder = $null
    )

    $directories = @($Node.Directories | Where-Object {
        $_.IsVisible -and (-not $TreeConfig.PruneEmptyFolders -or $_.HasVisibleContent)
    })
    $totalItems = $Node.Files.Count + $directories.Count
    $currentItemIndex = 0

    foreach ($file in $Node.Files) {
        $currentItemIndex++
        $isLastItem = $currentItemIndex -eq $totalItems
        $treeBranch = if ($isLastItem) { $TreeConfig.LineStyle.LastBranch } else { $TreeConfig.LineStyle.Branch }
        $treePrefix = if ($IsRoot) { $treeBranch } else { "$TreeIndent$treeBranch" }
        $outputInfo = Build-OutputLine -HeaderTable $TreeConfig.HeaderTable `
            -Item $file `
            -TreePrefix $treePrefix `
            -HumanReadableSizes $TreeConfig.HumanReadableSizes

        if ($outputInfo.SizeColor -and $outputInfo.SizePosition -ge 0 -and $outputInfo.SizeLength -gt 0) {
            if ($null -ne $OutputBuilder) {
                [void]$OutputBuilder.AppendLine($outputInfo.Line)
            } else {
                $before = $outputInfo.Line.Substring(0, $outputInfo.SizePosition)
                $size = $outputInfo.Line.Substring($outputInfo.SizePosition, $outputInfo.SizeLength)
                $after = $outputInfo.Line.Substring($outputInfo.SizePosition + $outputInfo.SizeLength)
                Write-Host $before -NoNewline
                Write-Host $size -ForegroundColor $outputInfo.SizeColor -NoNewline
                Write-Host $after
            }
        } else {
            Write-OutputLine -Line $outputInfo.Line -OutputBuilder $OutputBuilder
        }

        $TreeStats.AddFile($file)
    }

    foreach ($child in $directories) {
        $currentItemIndex++
        $isLastItem = $currentItemIndex -eq $totalItems

        if ($TreeConfig.ShowConnectorLines -and $Node.Files.Count -gt 0) {
            $hierarchyPosition = $TreeConfig.HeaderTable.Indentations["Hierarchy"]
            $connector = " " * $hierarchyPosition + "$TreeIndent$($TreeConfig.LineStyle.Vertical)"
            Write-OutputLine -Line $connector -OutputBuilder $OutputBuilder
        }

        $treeBranch = if ($isLastItem) { $TreeConfig.LineStyle.LastBranch } else { $TreeConfig.LineStyle.Branch }
        $treePrefix = if ($IsRoot) { $treeBranch } else { "$TreeIndent$treeBranch" }
        $outputInfo = Build-OutputLine -HeaderTable $TreeConfig.HeaderTable `
            -Item $child.Item `
            -TreePrefix $treePrefix `
            -HumanReadableSizes $TreeConfig.HumanReadableSizes `
            -DirectorySize $child.Size

        Write-OutputLine -Line $outputInfo.Line -OutputBuilder $OutputBuilder
        $TreeStats.FoldersPrinted++
        $TreeStats.UpdateMaxDepth($child.Depth)

        if ($TreeConfig.HeaderTable.HeaderColumns -contains "Size") {
            $TreeStats.UpdateLargestFolder($child.Item.FullName, $child.Size)
        }

        $newTreeIndent = if ($IsRoot) {
            if ($isLastItem) { $TreeConfig.LineStyle.Space } else { $TreeConfig.LineStyle.VerticalLine }
        } else {
            if ($isLastItem) { "$TreeIndent$($TreeConfig.LineStyle.Space)" } else { "$TreeIndent$($TreeConfig.LineStyle.VerticalLine)" }
        }

        Write-TreeSnapshot -Node $child `
            -TreeConfig $TreeConfig `
            -TreeStats $TreeStats `
            -TreeIndent $newTreeIndent `
            -IsRoot $false `
            -OutputBuilder $OutputBuilder
    }
}
