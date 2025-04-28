
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
    
    # Don't replace the decimal point with semicolon anymore
    # $formattedValue = $formattedValue.Replace(".", ";")
    
    # Pad the formatted value to ensure consistent width
    $paddedValue = $formattedValue.PadRight(7)
    $result = "$paddedValue$($sizes[$order].PadRight(3))"
    return $result
}
