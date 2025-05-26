function Invoke-OutputBuilder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [TreeConfig]$TreeConfig,
        [bool]$ShowExecutionStats
    )

    # Only create OutputBuilder if we need to save to a file
    if ([string]::IsNullOrEmpty($TreeConfig.OutFile)) {
        return $null
    }

    $outputBuilder = New-Object System.Text.StringBuilder
    
    # Add file header
    [void]$outputBuilder.AppendLine("# PowerTree Output")
    [void]$outputBuilder.AppendLine("# Generated: $(Get-Date)")
    [void]$outputBuilder.AppendLine("# Path: $($TreeConfig.Path)")
    if (-not [string]::IsNullOrEmpty($TreeConfig.OutFile)) {
        [void]$outputBuilder.AppendLine("# Output File: $($TreeConfig.OutFile)")
    }
    
    # Get configuration lines for file output
    $configLines = Get-TreeConfigurationData -TreeConfig $TreeConfig
    
    foreach ($line in $configLines) {
        [void]$outputBuilder.AppendLine($line)
    }
    
    if ($ShowExecutionStats) {
        [void]$outputBuilder.AppendLine("Append the stats here later!!")
    }

    return $outputBuilder
}