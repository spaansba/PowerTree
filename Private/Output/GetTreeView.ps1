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
        [System.Text.StringBuilder]$OutputBuilder = $null
    )

    if ($TreeConfig.MaxDepth -ne -1 -and $CurrentDepth -ge $TreeConfig.MaxDepth) {
        return
    }

    if ($IsRoot) {
        $TreeStats.MaxDepth += 1
    }
    
    $TreeStats.UpdateMaxDepth($CurrentDepth)

    # Get directories filtering out excluded directories
    $dirItems = Get-ChildItem @ChildItemDirectoryParams -Path $CurrentPath
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
        $fileList = Get-ChildItem -Path "$CurrentPath\*" @ChildItemFileParams 
        
        if ($null -ne $fileList -and $fileList.Count -gt 0) {
            $filteredBySize = Get-FilesByFilteredSize $fileList -FileSizeBounds $TreeConfig.FileSizeBounds
            Group-Items -Items $filteredBySize -SortBy $TreeConfig.SortBy -SortDescending $TreeConfig.SortDescending
        } else {
            @()
        }
    } else { 
        @() 
    }
    
    # Helper function to write output to both console and file
    function Write-OutputLine {
        param (
            [string]$Line,
            [System.ConsoleColor]$ForegroundColor = [System.ConsoleColor]::White,
            [bool]$Quiet,
            [System.Text.StringBuilder]$OutputBuilder
        )
        if ($Quiet -eq $false) {
            Write-Host $Line -ForegroundColor $ForegroundColor
        }
        if ($null -ne $OutputBuilder) {
            [void]$OutputBuilder.AppendLine($Line)
        }
    }

    if (-not $TreeConfig.DirectoryOnly -and $files.Count -gt 0) {
        foreach ($file in $files) {
            $treePrefix = if ($IsRoot) { "|   " } else { "$TreeIndent|   " }
            $outputInfo = Build-OutputLine -HeaderTable $TreeConfig.HeaderTable -Item $file -TreePrefix $treePrefix
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
    
    $dirCount = $directories.Count
    $currentDir = 0
    
    foreach ($dir in $directories) {
        $currentDir++
        $isLast = ($currentDir -eq $dirCount)
        
        # Print connector line to make it look prettier, can be turned on/off in settings
        if($TreeConfig.ShowConnectorLines) {
            $hierarchyPos = $TreeConfig.HeaderTable.Indentations["Hierarchy"]
            $connector = " " * $hierarchyPos + "$TreeIndent|"
            Write-OutputLine -Line $connector `
                             -Quiet $TreeConfig.Quiet `
                             -OutputBuilder $OutputBuilder 
        }

        # Create the directory prefix with appropriate tree symbols
        $dirPrefix = if ($IsRoot) { "" } else { $TreeIndent }
        $treeBranch = if ($Last) { "\----" } else { "+----" }
        $treePrefix = "$dirPrefix$treeBranch "
        
        # Build and output the directory line
        $outputInfo = Build-OutputLine -HeaderTable $TreeConfig.HeaderTable -Item $dir -TreePrefix $treePrefix
        Write-OutputLine -Line $outputInfo.Line `
                         -Quiet $TreeConfig.Quiet `
                         -OutputBuilder $OutputBuilder
                         
        $TreeStats.FoldersPrinted++

        $newTreeIndent = if ($isLast) { "$dirPrefix    " } else { "$dirPrefix|   " }
        
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
}