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
    $needPostProcessing = $needFullSizes -or $TreeConfig.PruneEmptyFolders
    $sortDirection = if ($TreeConfig.SortDescending) { -1 } else { 1 }
    $sortBy = $TreeConfig.SortBy
    $fileComparison = [System.Comparison[System.IO.FileInfo]] {
        param($left, $right)

        $comparison = switch ($sortBy) {
            "Modification Date" { [datetime]::Compare($left.LastWriteTime, $right.LastWriteTime) }
            "Creation Date" { [datetime]::Compare($left.CreationTime, $right.CreationTime) }
            "Last Access Date" { [datetime]::Compare($left.LastAccessTime, $right.LastAccessTime) }
            "Size" { $left.Length.CompareTo($right.Length) }
            default { [StringComparer]::CurrentCultureIgnoreCase.Compare($left.Name, $right.Name) }
        }
        return $comparison * $sortDirection
    }
    $directoryComparison = [System.Comparison[object]] {
        param($left, $right)

        $comparison = switch ($sortBy) {
            "Modification Date" { [datetime]::Compare($left.Item.LastWriteTime, $right.Item.LastWriteTime) }
            "Creation Date" { [datetime]::Compare($left.Item.CreationTime, $right.Item.CreationTime) }
            "Last Access Date" { [datetime]::Compare($left.Item.LastAccessTime, $right.Item.LastAccessTime) }
            "Size" { $left.Size.CompareTo($right.Size) }
            default { [StringComparer]::CurrentCultureIgnoreCase.Compare($left.Item.Name, $right.Item.Name) }
        }
        return $comparison * $sortDirection
    }
    $nodes = $null
    if ($needPostProcessing) {
        $nodes = [System.Collections.Generic.List[object]]::new()
    }
    $pending = [System.Collections.Generic.Stack[object]]::new()
    $pending.Push($root)

    while ($pending.Count -gt 0) {
        $node = $pending.Pop()
        if ($needPostProcessing) {
            $nodes.Add($node)
        }

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

                if ($needFullSizes) {
                    $node.DirectSize += $item.Length
                }
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

        if ($files.Count -gt 1) {
            $files.Sort($fileComparison)
        }
        if ($TreeConfig.FileLimit -eq 0) {
            $files.Clear()
        } elseif ($TreeConfig.FileLimit -gt 0 -and $files.Count -gt $TreeConfig.FileLimit) {
            $files.RemoveRange($TreeConfig.FileLimit, $files.Count - $TreeConfig.FileLimit)
        }
        if ($TreeConfig.SortFolders -and $TreeConfig.SortBy -ne "Size" -and $directories.Count -gt 1) {
            $directories.Sort($directoryComparison)
        }

        $node.Files = $files.ToArray()
        $node.Directories = $directories.ToArray()
    }

    if (-not $needPostProcessing) {
        return $root
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

        if ($TreeConfig.SortFolders -and $TreeConfig.SortBy -eq "Size" -and $node.Directories.Count -gt 1) {
            $directories = [System.Collections.Generic.List[object]]::new()
            $directories.AddRange($node.Directories)
            $directories.Sort($directoryComparison)
            $node.Directories = $directories.ToArray()
        }
    }

    return $root
}
