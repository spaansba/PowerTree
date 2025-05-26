function Show-RegistryStats {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [RegistryStats]$RegistryStats,
        
        [Parameter(Mandatory=$true)]
        [System.TimeSpan]$ExecutionTime,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$LineStyle = @{ SingleLine = '-' }
    )
    
    $formattedTime = Format-ExecutionTime -ExecutionTime $ExecutionTime
    
    $headers = @(
        "Keys",
        "Values", 
        "Total Items",
        "Max Depth",
        "Execution Time"
    )
    
    $totalItems = $RegistryStats.KeysProcessed + $RegistryStats.ValuesProcessed
    
    $values = @(
        $RegistryStats.KeysProcessed,
        $RegistryStats.ValuesProcessed,
        $totalItems,
        $RegistryStats.MaxDepthReached,
        $formattedTime
    )
    
    $spacing = "    "
    
    $headerLine = ""
    foreach ($header in $headers) {
        $headerLine += $header + $spacing
    }
    
    $underscoreLine = ""
    foreach ($header in $headers) {
        $underscoreLine += ($LineStyle.SingleLine * $header.Length) + $spacing
    }
    
    $valuesLine = ""
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $value = $values[$i].ToString()
        $valuesLine += $value.PadRight($headers[$i].Length) + $spacing
    }
    
    Write-Host ""
    Write-Host $headerLine -ForegroundColor Cyan
    Write-Host $underscoreLine -ForegroundColor DarkCyan
    Write-Host $valuesLine
    Write-Host ""
}