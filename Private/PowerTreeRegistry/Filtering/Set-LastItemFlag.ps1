
function Set-LastItemFlag {
    param (
        [array]$Items
    )
    
    if ($Items.Count -gt 0) {
        # Reset all IsLast flags
        foreach ($item in $Items) {
            $item.IsLast = $false
        }
        # Set the last item
        $Items[-1].IsLast = $true
    }
    
    return $Items
}