# Function to get appropriate color for file size
function Get-SizeColor {
    param (
        [Parameter(Mandatory=$true)]
        [long]$Bytes
    )
    
    switch ($true) {
        ($Bytes -ge 100MB) { return "Red" }        # Large files (>= 100 MB)
        ($Bytes -ge 10MB) { return "DarkYellow" }      # Medium-large files (10-100 MB)
        ($Bytes -ge 1MB) { return "Blue" }         # Medium files (1-10 MB)
        ($Bytes -ge 100KB) { return "Cyan" }      # Small-medium files (100 KB-1 MB)
        default { return "Green" }                  # Small files (< 100 KB)
    }
}

function Get-HumanReadableSize {
    param ( 
        [Parameter(Mandatory=$true)]
        [long]$Bytes,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Compact", "Padded")]
        [string]$Format = "Padded"
    )
    
    $sizes = @(' B', 'KB', 'MB', 'GB', 'TB')
    $order = 0
    $value = $Bytes
    
    while ($value -ge 1024 -and $order -lt 4) {
        $order++
        $value /= 1024.0
    }
    
    $formattedValue = "{0:0.##}" -f $value
    
    if ($Format -eq "Compact") {
        return "$formattedValue$($sizes[$order])"
    }
    
    $formattedValue = $formattedValue.Replace(".", ";")
    
    # Pad the formatted value to ensure consistent width
    $paddedValue = $formattedValue.PadRight(7)
    $result = "$paddedValue$($sizes[$order].PadRight(4))"
    return $result
}

function Get-FilesByFilteredSize {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo[]]$Files,
        [Parameter(Mandatory=$true)]
        [hashtable]$FileSizeBounds
    )

    # If filtering is not needed, return all files
    if (-not $FileSizeBounds.ShouldFilter) {
        return $Files
    }

    # Filter files based on size bounds
    $filteredFiles = $Files | Where-Object {
        $fileSizeInBytes = $_.Length
        
        # Check lower bound
        $lowerBoundCheck = if ($FileSizeBounds.LowerBound -ge 0) {
            $fileSizeInBytes -ge $FileSizeBounds.LowerBound
        } else { $true }
        
        # Check upper bound
        $upperBoundCheck = if ($FileSizeBounds.UpperBound -ge 0) {
            $fileSizeInBytes -le $FileSizeBounds.UpperBound
        } else { $true }
        
        # Return true only if both conditions are met
        $lowerBoundCheck -and $upperBoundCheck
    }

    return $filteredFiles
}