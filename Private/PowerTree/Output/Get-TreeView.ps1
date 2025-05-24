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

    # Process files in normal (non-empty-check) mode
    if (-not $TreeConfig.DirectoryOnly -and $files.Count -gt 0) {
        $hasVisibleContent = $true
        foreach ($file in $files) {
            $treePrefix = if ($IsRoot) { $TreeConfig.LineStyle.VerticalLine } else { "$TreeIndent$($TreeConfig.lineStyle.VerticalLine)" }
            $outputInfo = Build-OutputLine -HeaderTable $TreeConfig.HeaderTable `
                                        -Item $file `
                                        -TreePrefix $treePrefix `
                                        -HumanReadableSizes $TreeConfig.HumanReadableSizes

            if ($outputInfo.SizeColor -and $outputInfo.SizePosition -ge 0 -and $outputInfo.SizeLength -gt 0) {
                $before = $outputInfo.Line.Substring(0, $outputInfo.SizePosition)
                $size = $outputInfo.Line.Substring($outputInfo.SizePosition, $outputInfo.SizeLength)
                $after = $outputInfo.Line.Substring($outputInfo.SizePosition + $outputInfo.SizeLength)
                
                if($TreeConfig.Quiet -ne $true){
                    Write-Host $before -NoNewline
                    Write-Host $size -ForegroundColor $outputInfo.SizeColor -NoNewline
                    Write-Host $after
                }
                
                if ($null -ne $OutputBuilder) {
                    [void]$OutputBuilder.AppendLine($outputInfo.Line)
                }
            } else {
                Write-OutputLine -Line $outputInfo.Line `
                                 -Quiet $TreeConfig.Quiet `
                                 -OutputBuilder $OutputBuilder
            }
            
            $TreeStats.AddFile($file)
        }
    }

    # Regular processing for directories (non-empty-check calls)
    $dirCount = $directories.Count
    $currentDir = 0
    
    foreach ($dir in $directories) {
        $currentDir++
        $isLast = ($currentDir -eq $dirCount)
        
        # If pruning is enabled, check if this directory would be empty after applying filters
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
        
        # Skip this directory if it would be empty after filtering
        if ($skipDir) {
            continue
        }

        # We have a non-empty directory, so mark content as visible
        $hasVisibleContent = $true
      
        # Print connector line to make it look prettier, can be turned on/off in settings
        if($TreeConfig.ShowConnectorLines) {
            $hierarchyPos = $TreeConfig.HeaderTable.Indentations["Hierarchy"]
            $connector = " " * $hierarchyPos + "$TreeIndent$($TreeConfig.lineStyle.Vertical)"
            Write-OutputLine -Line $connector `
                             -Quiet $TreeConfig.Quiet `
                             -OutputBuilder $OutputBuilder 
        }

        # Create the directory prefix with appropriate tree symbols
        $dirPrefix = if ($IsRoot) { "" } else { $TreeIndent }
        $treeBranch = if ($isLast) { $TreeConfig.lineStyle.LastBranch } else { $TreeConfig.lineStyle.Branch }
        $treePrefix = "$dirPrefix$treeBranch"
        
        # Build and output the directory line
        $outputInfo = Build-OutputLine -HeaderTable $TreeConfig.HeaderTable `
                                    -Item $dir `
                                    -TreePrefix $treePrefix `
                                    -HumanReadableSizes $TreeConfig.HumanReadableSizes

        Write-OutputLine -Line $outputInfo.Line `
                         -Quiet $TreeConfig.Quiet `
                         -OutputBuilder $OutputBuilder
                         
        $TreeStats.FoldersPrinted++
        
        # Use the already calculated folder size for the stats
        if ($outputInfo.DirSize -gt 0) {
            $TreeStats.UpdateLargestFolder($dir.FullName, $outputInfo.DirSize)
        }

        if ($isLast) {
            $newTreeIndent = "$dirPrefix$($TreeConfig.lineStyle.Space)"
        } else {
            $newTreeIndent = "$dirPrefix$($TreeConfig.lineStyle.VerticalLine)"
        }
        

        Get-TreeView -TreeConfig $TreeConfig `
                     -TreeStats $TreeStats `
                     -ChildItemDirectoryParams $ChildItemDirectoryParams `
                     -ChildItemFileParams $ChildItemFileParams `
                     -CurrentPath $dir.FullName `
                     -TreeIndent $newTreeIndent `
                     -Last $isLast `
                     -IsRoot $false `
                     -CurrentDepth ($CurrentDepth + 1) `
                     -OutputBuilder $OutputBuilder
    }
    
    # Return whether this directory has any visible content after filtering
    return $hasVisibleContent
}