function Get-TreeView {
    param (
        [Parameter(Mandatory=$true)]
        [TreeConfig]$TreeConfig,
        [Parameter(Mandatory=$true)]
        [hashtable]$ChildItemDirectoryParams,
        [Parameter(Mandatory=$true)]
        [hashtable]$ChildItemFileParams,
        [Parameter(Mandatory=$true)]
        [TreeStats]$TreeStats,
        [string]$CurrentPath = $TreeConfig.Path,
        [string]$TreeIndent = "",
        [bool]$Last = $false,
        [bool]$IsRoot = $true,
        [int]$CurrentDepth = 0,
        [Parameter(Mandatory=$false)]
        [System.Text.StringBuilder]$OutputBuilder = $null,
        [Parameter(Mandatory=$false)]
        [switch]$IsEmptyCheck = $false
    )

    if ($TreeConfig.MaxDepth -ne -1 -and $CurrentDepth -ge $TreeConfig.MaxDepth) {
        return $false
    }

    if ($IsRoot) {
        $TreeStats.MaxDepth += 1
    }
    
    $TreeStats.UpdateMaxDepth($CurrentDepth)

    # Get directories filtering out excluded directories
    $dirItems = Get-ChildItem @ChildItemDirectoryParams -LiteralPath $CurrentPath
    $directories = if ($null -ne $dirItems -and $dirItems.Count -gt 0) {
        $filteredDirs = $dirItems | Where-Object {
            $TreeConfig.ExcludeDirectories.Count -eq 0 -or $TreeConfig.ExcludeDirectories -notcontains $_.Name
        }
        
        if ($null -ne $filteredDirs -and $filteredDirs.Count -gt 0) {
            if ($TreeConfig.SortFolders) {
                Group-Items -Items $filteredDirs -SortBy $TreeConfig.SortBy -SortDescending $TreeConfig.SortDescending
            } else {
                $filteredDirs
            }
        } else {
            @()
        }
    } else {
        @()
    }

    $files = if (-not $TreeConfig.DirectoryOnly) { 
        $fileList = Get-ChildItem -LiteralPath $CurrentPath @ChildItemFileParams 
        
        if ($null -ne $fileList -and $fileList.Count -gt 0) {
            $filteredBySize = Get-FilesByFilteredSize $fileList -FileSizeBounds $TreeConfig.FileSizeBounds
            Group-Items -Items $filteredBySize -SortBy $TreeConfig.SortBy -SortDescending $TreeConfig.SortDescending
        } else {
            @()
        }
    } else { 
        @() 
    }

    # Return true immediately if this is just an empty check and we have files
    if ($IsEmptyCheck -and -not $TreeConfig.DirectoryOnly -and $files.Count -gt 0) {
        return $true
    }

    # If this is just an empty check and we have no files but we do have directories,
    # we need to check if any of those directories are non-empty after filtering
    if ($IsEmptyCheck -and $files.Count -eq 0 -and $directories.Count -gt 0) {
        foreach ($dir in $directories) {
            $dirHasContent = Get-TreeView -TreeConfig $TreeConfig `
                          -TreeStats $TreeStats `
                          -ChildItemDirectoryParams $ChildItemDirectoryParams `
                          -ChildItemFileParams $ChildItemFileParams `
                          -CurrentPath $dir.FullName `
                          -TreeIndent "" `
                          -Last $false `
                          -IsRoot $false `
                          -CurrentDepth ($CurrentDepth + 1) `
                          -OutputBuilder $null `
                          -IsEmptyCheck:$true
                          
            if ($dirHasContent) {
                return $true
            }
        }
        # If we get here, all subdirectories were empty or filtered out
        return $false
    }
    
    # For empty check with no files and no directories, return false
    if ($IsEmptyCheck -and $files.Count -eq 0 -and $directories.Count -eq 0) {
        return $false
    }
    
    # Initialize the hasVisibleContent variable - true if we have visible files
    $hasVisibleContent = (-not $TreeConfig.DirectoryOnly -and $files.Count -gt 0)

    # Filter directories for pruning if enabled
    $visibleDirectories = @()
    if ($directories.Count -gt 0) {
        foreach ($dir in $directories) {
            $skipDir = $false
            if ($TreeConfig.PruneEmptyFolders) {
                $dirHasContent = Get-TreeView -TreeConfig $TreeConfig `
                              -TreeStats $TreeStats `
                              -ChildItemDirectoryParams $ChildItemDirectoryParams `
                              -ChildItemFileParams $ChildItemFileParams `
                              -CurrentPath $dir.FullName `
                              -TreeIndent "" `
                              -Last $false `
                              -IsRoot $false `
                              -CurrentDepth ($CurrentDepth + 1) `
                              -OutputBuilder $null `
                              -IsEmptyCheck:$true
                
                if (-not $dirHasContent) {
                    $skipDir = $true
                }
            }
            
            if (-not $skipDir) {
                $visibleDirectories += $dir
                $hasVisibleContent = $true
            }
        }
    }

    # Calculate total items and process them in the correct order
    $totalItems = $files.Count + $visibleDirectories.Count
    $currentItemIndex = 0

    # Process files first (they appear before directories in tree output)
    if (-not $TreeConfig.DirectoryOnly -and $files.Count -gt 0) {
        foreach ($file in $files) {
            $currentItemIndex++
            $isLastItem = ($currentItemIndex -eq $totalItems)
            
            # Build the tree prefix for files
            $treeBranch = if ($isLastItem) { $TreeConfig.lineStyle.LastBranch } else { $TreeConfig.lineStyle.Branch }
            $treePrefix = if ($IsRoot) { $treeBranch } else { "$TreeIndent$treeBranch" }
            
            $outputInfo = Build-OutputLine -HeaderTable $TreeConfig.HeaderTable `
                                        -Item $file `
                                        -TreePrefix $treePrefix `
                                        -HumanReadableSizes $TreeConfig.HumanReadableSizes

            if ($outputInfo.SizeColor -and $outputInfo.SizePosition -ge 0 -and $outputInfo.SizeLength -gt 0) {
                $before = $outputInfo.Line.Substring(0, $outputInfo.SizePosition)
                $size = $outputInfo.Line.Substring($outputInfo.SizePosition, $outputInfo.SizeLength)
                $after = $outputInfo.Line.Substring($outputInfo.SizePosition + $outputInfo.SizeLength)
                
                if ($null -ne $OutputBuilder) {
                    [void]$OutputBuilder.AppendLine($outputInfo.Line)
                } else {
                    Write-Host $before -NoNewline
                    Write-Host $size -ForegroundColor $outputInfo.SizeColor -NoNewline
                    Write-Host $after
                }
            } else {
                Write-OutputLine -Line $outputInfo.Line `
                                 -OutputBuilder $OutputBuilder
            }
            
            $TreeStats.AddFile($file)
        }
    }

    # Process directories
    foreach ($dir in $visibleDirectories) {
        $currentItemIndex++
        $isLastItem = ($currentItemIndex -eq $totalItems)
      
        # Print connector line to make it look prettier, can be turned on/off in settings
        if($TreeConfig.ShowConnectorLines -and $files.Count -gt 0) {
            $hierarchyPos = $TreeConfig.HeaderTable.Indentations["Hierarchy"]
            $connector = " " * $hierarchyPos + "$TreeIndent$($TreeConfig.lineStyle.Vertical)"
            Write-OutputLine -Line $connector `
                             -OutputBuilder $OutputBuilder 
        }

        # Create the directory prefix with appropriate tree symbols
        $treeBranch = if ($isLastItem) { $TreeConfig.lineStyle.LastBranch } else { $TreeConfig.lineStyle.Branch }
        $treePrefix = if ($IsRoot) { $treeBranch } else { "$TreeIndent$treeBranch" }
        
        # Build and output the directory line
        $outputInfo = Build-OutputLine -HeaderTable $TreeConfig.HeaderTable `
                                    -Item $dir `
                                    -TreePrefix $treePrefix `
                                    -HumanReadableSizes $TreeConfig.HumanReadableSizes

        Write-OutputLine -Line $outputInfo.Line `
                         -OutputBuilder $OutputBuilder
                         
        $TreeStats.FoldersPrinted++
        
        # Use the already calculated folder size for the stats
        if ($outputInfo.DirSize -gt 0) {
            $TreeStats.UpdateLargestFolder($dir.FullName, $outputInfo.DirSize)
        }

        # Calculate the new tree indent for child items
        $newTreeIndent = if ($IsRoot) {
            if ($isLastItem) { $TreeConfig.lineStyle.Space } else { $TreeConfig.lineStyle.VerticalLine }
        } else {
            if ($isLastItem) { "$TreeIndent$($TreeConfig.lineStyle.Space)" } else { "$TreeIndent$($TreeConfig.lineStyle.VerticalLine)" }
        }

        # Recursively process the directory
        Get-TreeView -TreeConfig $TreeConfig `
                     -TreeStats $TreeStats `
                     -ChildItemDirectoryParams $ChildItemDirectoryParams `
                     -ChildItemFileParams $ChildItemFileParams `
                     -CurrentPath $dir.FullName `
                     -TreeIndent $newTreeIndent `
                     -Last $isLastItem `
                     -IsRoot $false `
                     -CurrentDepth ($CurrentDepth + 1) `
                     -OutputBuilder $OutputBuilder
    }
    
    # Return whether this directory has any visible content after filtering
    return $hasVisibleContent
}