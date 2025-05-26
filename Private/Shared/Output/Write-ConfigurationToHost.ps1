function Write-ConfigurationToHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [object]$Config
    )

    # Determine config type and get OutFile property
    $outFile = $null
    $configData = @()
    
    if ($Config -is [TreeRegistryConfig]) {
        $outFile = $Config.OutFile
        $configData = Get-RegistryConfigurationData -TreeRegistryConfig $Config
        $lineStyle = $Config.LineStyle.SingleLine
    } elseif ($Config -is [TreeConfig]) {
        $outFile = $Config.OutFile
        $configData = Get-TreeConfigurationData -TreeConfig $Config
        $lineStyle = "─"
    } else {
        Write-Error "Invalid configuration type. Expected TreeConfig or TreeRegistryConfig."
        return
    }

    # Don't show configuration if we're outputting to a file
    if (-not [string]::IsNullOrEmpty($outFile)) {
        return
    }
    
    Write-Host ""
    Write-Host "Configuration" -ForegroundColor Magenta
    Write-Host ($lineStyle * 13) -ForegroundColor Magenta
    Write-Verbose "Some settings might be sourced from the .config.json file"
    
    # Display configuration data
    foreach ($configLine in $configData) {
        Write-Host $configLine -ForegroundColor Green
    }
    
    Write-Host ""
}