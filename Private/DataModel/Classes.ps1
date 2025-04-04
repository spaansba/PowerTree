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

  
    [void] DisplaySummary([System.TimeSpan]$executionResultTime, [System.Text.StringBuilder]$OutputBuilder, [bool]$Quiet) {
    
        $formattedTime = if ($executionResultTime.TotalSeconds -lt 1) {
            "$($executionResultTime.TotalMilliseconds.ToString('0.00')) ms"
        } elseif ($executionResultTime.TotalMinutes -lt 1) {
            "$($executionResultTime.TotalSeconds.ToString('0.00')) sec"
        } else {
            "$($executionResultTime.Minutes) min, $($executionResultTime.Seconds) sec"
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

        # Define values corresponding to each header
        $values = @(
            $this.FilesPrinted,
            $this.FoldersPrinted,
            $totalItemsPrinted,
            $this.MaxDepth,
            $(Get-HumanReadableSize -Bytes $this.TotalSize -Format "Padded"),
            $formattedTime
        )
        
        # Define fixed spacing between columns
        $spacing = "    "
        
        # Build the header line
        $headerLine = ""
        foreach ($header in $headers) {
            $headerLine += $header + $spacing
        }
        
        # Build the underscore line
        $underscoreLine = ""
        foreach ($header in $headers) {
            $underscoreLine += "-" * $header.Length + $spacing
        }
        
        # Build the values line
        $valuesLine = ""
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $value = $values[$i].ToString()
            
            # Add padding to align with header if value is shorter than header
            if ($value.Length -lt $headers[$i].Length) {
                $padding = " " * ($headers[$i].Length - $value.Length)
                $value = $value + $padding
            }
            
            $valuesLine += $value + $spacing
        }
        
        if($Quiet -eq $false) {
            Write-Host ""
            Write-Host $headerLine -ForegroundColor Cyan
            Write-Host $underscoreLine -ForegroundColor DarkCyan
            Write-Host $valuesLine
        }

        
        # If OutputBuilder is provided, prepare the stats
        if ($null -ne $OutputBuilder) {
            # Create stats content
            $statsBuilder = New-Object System.Text.StringBuilder
            [void]$statsBuilder.AppendLine("# Execution Statistics")
            [void]$statsBuilder.AppendLine($headerLine)
            [void]$statsBuilder.AppendLine($underscoreLine)
            [void]$statsBuilder.AppendLine($valuesLine)
            
            # Get the content as a string
            $content = $OutputBuilder.ToString()
            
            # Look for the placeholder text
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