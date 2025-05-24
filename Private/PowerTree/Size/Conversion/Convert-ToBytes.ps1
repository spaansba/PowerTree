function ConvertTo-Bytes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$SizeString = "-1"
    )

    if ($null -eq $SizeString -or $SizeString -eq "") {
        return -1
    }

    # Check for special case of negative values with units (like "-1kb") - these are used for default/inactive values
    if ($SizeString -match "^-\d+\s*(b|kb|mb|gb|tb)$") {
        return -1
    }

    # Check for special case of just a negative number (like -1)
    if ($SizeString -match "^-\d+$") {
        return [long]$SizeString
    }

    # Normalize any decimal separator to a period first
    $normalizedSizeString = $SizeString -replace '[,;]', '.'

    # Try to match a pattern for size with unit
    # Format is a number (possibly with decimal) followed by an optional unit (b, kb, mb, gb, tb)
    if ($normalizedSizeString -match '^\s*(\d+(?:\.\d+)?)\s*(b|kb|mb|gb|tb)?\s*$') {
        $value = [double]$Matches[1]
        
        # Default unit is bytes
        $unit = if ($Matches.Count -gt 2 -and $Matches[2]) { $Matches[2].ToLower() } else { "b" }
        
        # Calculate size in bytes based on unit
        switch ($unit) {
            "b"  { $value = $value }
            "kb" { $value = $value * 1KB }
            "mb" { $value = $value * 1MB }
            "gb" { $value = $value * 1GB }
            "tb" { $value = $value * 1TB }
        }
        
        return [long]$value
    }
    
    # If no match, return -1 (invalid format)
    Write-Warning "Invalid size format: '$SizeString'. Expected format is a number followed by optional unit (B, KB, MB, GB, TB)."
    return -1
}
