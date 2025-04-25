function Display-TreeStats {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [object]$TreeStats,
        
        [Parameter(Mandatory=$true)]
        [System.TimeSpan]$ExecutionTime,
        
        [Parameter(Mandatory=$false)]
        [System.Text.StringBuilder]$OutputBuilder = $null,
        
        [Parameter(Mandatory=$false)]
        [bool]$Quiet = $false,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$LineStyle = @{ SingleLine = '-' },
        
        [Parameter(Mandatory=$false)]
        [bool]$DisplaySize = $false
    )
    
    $formattedTime = switch ($ExecutionTime) {
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
    
    # Define headers for statistics table
    $headers = @(
        "Files",
        "Folders",
        "Total Items",
        "Depth",
        "Total Size",
        "Execution Time"
    )
    
    $totalItemsPrinted = $TreeStats.FilesPrinted + $TreeStats.FoldersPrinted
    
    $values = @(
        $TreeStats.FilesPrinted,
        $TreeStats.FoldersPrinted,
        $totalItemsPrinted,
        $TreeStats.MaxDepth,
        $(Get-HumanReadableSize -Bytes $TreeStats.TotalSize -Format "Padded"),
        $formattedTime
    )
    
    $spacing = "    "
    
    # Build the table header
    $headerLine = ""
    foreach ($header in $headers) {
        $headerLine += $header + $spacing
    }
    
    # Build the separator line
    $underscoreLine = ""
    foreach ($header in $headers) {
        $underscoreLine += $LineStyle.SingleLine * $header.Length + $spacing
    }
    
    # Build the values line
    $valuesLine = ""
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $value = $values[$i].ToString()
        $valuesLine += $value.PadRight($headers[$i].Length) + $spacing
    }
    
    # Get largest file and folder info
    $largestFilePath = if ($null -ne $TreeStats.LargestFile) { $TreeStats.LargestFile.FullName } else { "None" }
    $largestFileSize = if ($null -ne $TreeStats.LargestFile) { Get-HumanReadableSize -Bytes $TreeStats.LargestFile.Length -Format "Padded" } else { "0 B" }
    $largestFolderSize = Get-HumanReadableSize -Bytes $TreeStats.LargestFolderSize -Format "Padded"
    
    if (-not $Quiet) {
        # Display table
        Write-Host ""
        Write-Host $headerLine -ForegroundColor Cyan
        Write-Host $underscoreLine -ForegroundColor DarkCyan
        Write-Host $valuesLine
        
        # Only display largest file and folder if DisplaySize is enabled
        if ($DisplaySize) {
            # Display largest file and folder info
            Write-Host ""
            Write-Host "Largest File:" -NoNewline -ForegroundColor Cyan
            Write-Host " $largestFileSize $largestFilePath"
            
            Write-Host "Largest Folder:" -NoNewline -ForegroundColor Cyan
            Write-Host " $largestFolderSize $($TreeStats.LargestFolder)"
        }
    }
    
    # If OutputBuilder is provided, prepare the stats for file output
    if ($null -ne $OutputBuilder) {
        $statsBuilder = New-Object System.Text.StringBuilder
        [void]$statsBuilder.AppendLine("# Execution Statistics")
        [void]$statsBuilder.AppendLine($headerLine)
        [void]$statsBuilder.AppendLine($underscoreLine)
        [void]$statsBuilder.AppendLine($valuesLine)
        
        # Only include largest file/folder info if DisplaySize is enabled
        if ($DisplaySize) {
            [void]$statsBuilder.AppendLine("")
            [void]$statsBuilder.AppendLine("Largest File: $largestFileSize $largestFilePath")
            [void]$statsBuilder.AppendLine("Largest Folder: $largestFolderSize $($TreeStats.LargestFolder)")
        }
        
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