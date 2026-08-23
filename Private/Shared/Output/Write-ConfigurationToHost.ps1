function Write-ConfigurationToHost {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [object]$Config
    )

    $outFile = $Config.OutFile
    $configData = @()

    # Don't show configuration if we're outputting to a file
    if (-not [string]::IsNullOrEmpty($outFile)) {
        return
    }
    
    if ($null -ne $Config.PSObject.Properties["NoValues"]) {
        $configData = Get-RegistryConfigurationData -TreeRegistryConfig $Config
        $lineStyle = $Config.LineStyle.SingleLine
    } elseif ($null -ne $Config.PSObject.Properties["HeaderTable"]) {
        $configData = Get-TreeConfigurationData -TreeConfig $Config
        $lineStyle = "─"
    } else {
        Write-Error "Invalid configuration type. Expected TreeConfig or TreeRegistryConfig."
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
