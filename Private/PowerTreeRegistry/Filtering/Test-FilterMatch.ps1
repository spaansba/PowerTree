function Test-FilterMatch {
    param (
        [string]$ItemName,
        [string[]]$Patterns
    )
    
    if (-not $Patterns -or $Patterns.Count -eq 0) {
        return $false
    }
    
    foreach ($pattern in $Patterns) {
        if ($ItemName -like $pattern) {
            return $true
        }
    }
    
    return $false
}