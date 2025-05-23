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
