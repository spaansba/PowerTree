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