class TreeConfig {
    [string]$Path
    [bool]$DirectoryOnly
    [string[]]$ExcludeDirectories
    [string]$SortBy
    [bool]$SortDescending
    [bool]$SortFolders
    [hashtable]$ChildItemDirectoryParams
    [hashtable]$ChildItemFileParams
    [hashtable]$HeaderTable
    [bool]$ShowConnectorLines
    [bool]$ShowHiddenFiles
    [int]$MaxDepth
    [hashtable]$FileSizeBounds
    [string]$OutFile
    [bool]$Quiet
    [bool]$PruneEmptyFolders
    [hashtable]$LineStyle
}

class TreeStats {
    [long]$FilesPrinted = 0
    [long]$FoldersPrinted = 0
    [int]$MaxDepth = 0
    [long]$TotalSize = 0
    
    [void] AddFile([System.IO.FileInfo]$file) {
        $this.FilesPrinted++
        $this.TotalSize += $file.Length
    }
    
    [void] UpdateMaxDepth([int]$depth) {
        if ($depth -gt $this.MaxDepth) {
            $this.MaxDepth = $depth
        }
    }

  
    [void] DisplaySummary([System.TimeSpan]$executionResultTime, [System.Text.StringBuilder]$OutputBuilder, [bool]$Quiet, [hashtable]$LineStyle) {
    
        $formattedTime = switch ($executionResultTime) {
            { $_.TotalMinutes -gt 1 } {
                '{0} min, {1} sec' -f [math]::Floor($_.Minutes), $_.Seconds
                break
            }
            { $_.TotalSeconds -gt 1 } {
                '{0:0.00} sec' -f $_.TotalSeconds
                break
            }
            default {
                '{0:N0} ms' -f $_.TotalMilliseconds
            }
        }
        
        # Define headers for statistics
        $headers = @(
            "Files",
            "Folders",
            "Total Items",
            "Depth",
            "Total Size",
            "Execution Time"
        )
        
        $totalItemsPrinted = $this.FilesPrinted + $this.FoldersPrinted

        $values = @(
            $this.FilesPrinted,
            $this.FoldersPrinted,
            $totalItemsPrinted,
            $this.MaxDepth,
            $(Get-HumanReadableSize -Bytes $this.TotalSize -Format "Padded"),
            $formattedTime
        )
        
        $spacing = "    "
        
        $headerLine = ""
        foreach ($header in $headers) {
            $headerLine += $header + $spacing
        }
        
        $underscoreLine = ""
        foreach ($header in $headers) {
            $underscoreLine += $LineStyle.SingleLine * $header.Length + $spacing
        }
        
        $valuesLine = ""
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $value = $values[$i].ToString()
            $valuesLine += $value.PadRight($headers[$i].Length) + $spacing
        }
        if($Quiet -eq $false) {
            Write-Host ""
            Write-Host $headerLine -ForegroundColor Cyan
            Write-Host $underscoreLine -ForegroundColor DarkCyan
            Write-Host $valuesLine
        }

        
        # If OutputBuilder is provided, prepare the stats
        if ($null -ne $OutputBuilder) {
            $statsBuilder = New-Object System.Text.StringBuilder
            [void]$statsBuilder.AppendLine("# Execution Statistics")
            [void]$statsBuilder.AppendLine($headerLine)
            [void]$statsBuilder.AppendLine($underscoreLine)
            [void]$statsBuilder.AppendLine($valuesLine)
            
            $content = $OutputBuilder.ToString()
            
            $placeholderText = "Append the stats here later!!"
            $placeholderIndex = $content.IndexOf($placeholderText)
            
            if ($placeholderIndex -ge 0) {
                # Replace the placeholder with the stats
                $newContent = $content.Replace($placeholderText, $statsBuilder.ToString())
                
                # Clear and rebuild OutputBuilder
                $OutputBuilder.Clear()
                [void]$OutputBuilder.Append($newContent)
            } else {
                # Fallback: just append at the end
                [void]$OutputBuilder.AppendLine("")
                [void]$OutputBuilder.Append($statsBuilder.ToString())
            }
        }
    }
}