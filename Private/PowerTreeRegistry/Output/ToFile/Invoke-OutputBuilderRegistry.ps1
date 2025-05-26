function Invoke-OutputBuilderRegistry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [TreeRegistryConfig]$TreeRegistryConfig,
        [bool]$ShowExecutionStats = $true,
        [bool]$ShowConfigurations = $true
    )

    $outputBuilder = New-Object System.Text.StringBuilder
    
    [void]$outputBuilder.AppendLine("# PowerTreeRegistry Output")
    [void]$outputBuilder.AppendLine("# Generated: $(Get-Date)")
    [void]$outputBuilder.AppendLine("# Registry Path: $($TreeRegistryConfig.Path)")
    [void]$outputBuilder.AppendLine("")

    if($ShowConfigurations){
        [void]$outputBuilder.AppendLine("Configuration:")
        [void]$outputBuilder.AppendLine(($TreeRegistryConfig.LineStyle.SingleLine * 13))
        $configData = Get-RegistryConfigurationData -TreeRegistryConfig $TreeRegistryConfig
        foreach ($configLine in $configData) {
            [void]$outputBuilder.AppendLine($configLine)
        }
        [void]$outputBuilder.AppendLine("")
    }

    # Add placeholder for execution stats if needed
    if ($ShowExecutionStats) {
        [void]$outputBuilder.AppendLine("Execution Stats:")
        [void]$outputBuilder.AppendLine(($TreeRegistryConfig.LineStyle.SingleLine * 15))
        [void]$outputBuilder.AppendLine("Append the stats here later!!")
        [void]$outputBuilder.AppendLine("")
    }

    return $outputBuilder
}