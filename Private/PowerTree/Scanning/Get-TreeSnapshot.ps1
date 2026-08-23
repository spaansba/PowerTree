function Get-TreeSnapshot {
    param(
        [Parameter(Mandatory=$true)]
        [object]$TreeConfig,
        [Parameter(Mandatory=$true)]
        [hashtable]$ChildItemFileParams
    )

    $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TreeConfig.Path)
    $root = [TreeNode]::new([System.IO.DirectoryInfo]::new($resolvedPath), 0)
    $root.CanRenderContents = $TreeConfig.MaxDepth -ne 0

    $includePatterns = if ($ChildItemFileParams.ContainsKey("Include")) {
        @($ChildItemFileParams.Include)
    } else {
        @()
    }
    $excludePatterns = if ($ChildItemFileParams.ContainsKey("Exclude")) {
        @($ChildItemFileParams.Exclude)
    } else {
        @()
    }
    $hiddenAttributes = [System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System
    $needFullSizes = $TreeConfig.HeaderTable.HeaderColumns -contains "Size" -or
        ($TreeConfig.SortFolders -and $TreeConfig.SortBy -eq "Size")
    $nodes = [System.Collections.Generic.List[object]]::new()
    $pending = [System.Collections.Generic.Stack[object]]::new()
    $pending.Push($root)

    while ($pending.Count -gt 0) {
        $node = $pending.Pop()
        $nodes.Add($node)

        if (-not $node.CanRenderContents -and -not $needFullSizes) {
            continue
        }

        $files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
        $directories = [System.Collections.Generic.List[object]]::new()

        try {
            foreach ($item in $node.Item.EnumerateFileSystemInfos()) {
                if (-not $TreeConfig.ShowHiddenFiles -and ($item.Attributes -band $hiddenAttributes)) {
                    continue
                }

                if ($item -is [System.IO.DirectoryInfo]) {
                    $child = [TreeNode]::new($item, $node.Depth + 1)
                    $child.IsVisible = $node.CanRenderContents -and
                        $TreeConfig.ExcludeDirectories -notcontains $item.Name
                    $child.CanRenderContents = $child.IsVisible -and
                        ($TreeConfig.MaxDepth -eq -1 -or $child.Depth -lt $TreeConfig.MaxDepth)
                    $directories.Add($child)

                    if (($child.CanRenderContents -or $needFullSizes) -and
                        -not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                        $pending.Push($child)
                    }
                    continue
                }

                if ($item -isnot [System.IO.FileInfo]) {
                    continue
                }

                $node.DirectSize += $item.Length
                if (-not $node.CanRenderContents) {
                    continue
                }

                $included = $includePatterns.Count -eq 0
                foreach ($pattern in $includePatterns) {
                    if ($item.Name -like $pattern) {
                        $included = $true
                        break
                    }
                }
                if (-not $included) {
                    continue
                }

                $excluded = $false
                foreach ($pattern in $excludePatterns) {
                    if ($item.Name -like $pattern) {
                        $excluded = $true
                        break
                    }
                }
                if ($excluded) {
                    continue
                }

                if ($TreeConfig.FileSizeBounds.ShouldFilter) {
                    if ($TreeConfig.FileSizeBounds.LowerBound -ge 0 -and
                        $item.Length -lt $TreeConfig.FileSizeBounds.LowerBound) {
                        continue
                    }
                    if ($TreeConfig.FileSizeBounds.UpperBound -ge 0 -and
                        $item.Length -gt $TreeConfig.FileSizeBounds.UpperBound) {
                        continue
                    }
                }

                $node.HasFilteredFiles = $true
                if (-not $TreeConfig.DirectoryOnly) {
                    $files.Add($item)
                }
            }
        } catch {
            Write-Verbose "Could not enumerate '$($node.Item.FullName)': $($_.Exception.Message)"
        }

        $node.Files = $files.ToArray()
        $node.Directories = $directories.ToArray()
    }

    $nodeArray = $nodes.ToArray()
    [array]::Reverse($nodeArray)

    foreach ($node in $nodeArray) {
        $node.Size = $node.DirectSize
        foreach ($child in $node.Directories) {
            $node.Size += $child.Size
            if ($child.IsVisible -and $child.HasVisibleContent) {
                $node.HasVisibleContent = $true
            }
        }
        if ($node.HasFilteredFiles) {
            $node.HasVisibleContent = $true
        }

        if ($node.Files.Count -gt 0) {
            $node.Files = @(Group-Items -Items $node.Files `
                -SortBy $TreeConfig.SortBy `
                -SortDescending $TreeConfig.SortDescending)

            if ($TreeConfig.FileLimit -eq 0) {
                $node.Files = @()
            } elseif ($TreeConfig.FileLimit -gt 0 -and $node.Files.Count -gt $TreeConfig.FileLimit) {
                $node.Files = @($node.Files[0..($TreeConfig.FileLimit - 1)])
            }
        }

        if ($TreeConfig.SortFolders -and $node.Directories.Count -gt 0) {
            $property = switch ($TreeConfig.SortBy) {
                "Modification Date" { { $_.Item.LastWriteTime } }
                "Creation Date" { { $_.Item.CreationTime } }
                "Last Access Date" { { $_.Item.LastAccessTime } }
                "Size" { { $_.Size } }
                default { { $_.Item.Name } }
            }
            $node.Directories = @($node.Directories | Sort-Object -Property $property -Descending:$TreeConfig.SortDescending)
        }
    }

    return $root
}
