function Write-RegistryConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [TreeRegistryConfig]$TreeRegistryConfig
    )

    # Don't show configuration if we're outputting to a file
    if (-not [string]::IsNullOrEmpty($TreeRegistryConfig.OutFile)) {
        return
    }
    
    Write-Host ""
    Write-Host "Configuration" -ForegroundColor Magenta
    Write-Host ($TreeRegistryConfig.LineStyle.SingleLine * 13)
    Write-Verbose "Some settings might be sourced from the .config.json file"
    
    # Get shared configuration data and display it
    $configData = Get-RegistryConfigurationData -TreeRegistryConfig $TreeRegistryConfig
    
    foreach ($configLine in $configData) {
        Write-Host $configLine -ForegroundColor Green
    }
    
    Write-Host ""
}
