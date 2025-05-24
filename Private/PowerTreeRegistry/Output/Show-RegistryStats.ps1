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
    
    # Define headers for registry statistics table
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
    
    # Build the table header
    $headerLine = ""
    foreach ($header in $headers) {
        $headerLine += $header + $spacing
    }
    
    # Build the separator line
    $underscoreLine = ""
    foreach ($header in $headers) {
        $underscoreLine += ($LineStyle.SingleLine * $header.Length) + $spacing
    }
    
    # Build the values line
    $valuesLine = ""
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $value = $values[$i].ToString()
        $valuesLine += $value.PadRight($headers[$i].Length) + $spacing
    }
    
    # Display table
    Write-Host ""
    Write-Host $headerLine -ForegroundColor Cyan
    Write-Host $underscoreLine -ForegroundColor DarkCyan
    Write-Host $valuesLine
    Write-Host ""
}