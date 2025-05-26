function Show-TreeStats {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [object]$TreeStats,
        
        [Parameter(Mandatory=$true)]
        [System.TimeSpan]$ExecutionTime,
        
        [Parameter(Mandatory=$false)]
        [System.Text.StringBuilder]$OutputBuilder = $null,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$LineStyle = @{ SingleLine = '-' },
        
        [Parameter(Mandatory=$false)]
        [bool]$DisplaySize = $false
    )
    
    $formattedTime = Format-ExecutionTime -ExecutionTime $ExecutionTime
    
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
    
    $largestFilePath = if ($null -ne $TreeStats.LargestFile) { $TreeStats.LargestFile.FullName } else { "None" }
    $largestFileSize = if ($null -ne $TreeStats.LargestFile) { Get-HumanReadableSize -Bytes $TreeStats.LargestFile.Length -Format "Padded" } else { "0 B" }
    $largestFolderSize = Get-HumanReadableSize -Bytes $TreeStats.LargestFolderSize -Format "Padded"
    
    if ($null -ne $OutputBuilder) {
        $placeholderText = "Append the stats here later!!"
        
        $statsContent = @"
$headerLine
$underscoreLine
$valuesLine

"@
        
        if ($DisplaySize) {
            $statsContent += @"

Largest File: $largestFileSize $largestFilePath
Largest Folder: $largestFolderSize $($TreeStats.LargestFolder)

"@
        }
        
        [void]$OutputBuilder.Replace($placeholderText, $statsContent)
    }else {
        Write-Host ""
        Write-Host $headerLine -ForegroundColor Cyan
        Write-Host $underscoreLine -ForegroundColor DarkCyan
        Write-Host $valuesLine
        
        if ($DisplaySize) {
            Write-Host ""
            Write-Host "Largest File:" -NoNewline -ForegroundColor Cyan
            Write-Host " $largestFileSize $largestFilePath"
            
            Write-Host "Largest Folder:" -NoNewline -ForegroundColor Cyan
            Write-Host " $largestFolderSize $($TreeStats.LargestFolder)"
        }
    }
}