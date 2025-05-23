function Show-PowerTreeRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Path = ".",

        [Parameter()]
        [Alias("s")]
        [switch]$DisplaySubKeys,

        [Parameter()]
        [Alias("v")]
        [switch]$DisplayValues,

        [Parameter()]
        [Alias("ek", "exclude")]
        [string[]]$ExcludedKeys = @(),

        [Parameter()]
        [Alias("ik", "include")]
        [string[]]$IncludeKeys = @(),

        [Parameter()]
        [Alias("l", "level")]
        [int]$Depth = -1

    )
    
   if (-not $IsWindows) {
        Write-Error "This script can only be run on Windows."
        exit 1 
    }

   . .\Private\Shared\DataModel\Classes.ps1
   . .\Private\PowerTreeRegistry\Configuration\ParamHelpers\Get-Path.ps1
   . .\Private\PowerTreeRegistry\Output\Get-TreeRegistryView.ps1
   . .\Private\PowerTreeRegistry\Filtering\Get-RegistryItems.ps1
   . .\Private\Shared\JsonConfig\Get-SettingsFromJson.ps1
   . .\Private\Shared\JsonConfig\Get-DefaultConfig.ps1
   . .\Private\Shared\JsonConfig\Get-ConfigPaths.ps1
   $jsonSettings = Get-SettingsFromJson
   write-host $jsonSettings
   $treeRegistryConfig = [TreeRegistryConfig]::new()
   $treeRegistryConfig.Path = Get-Path -Path $Path
   $treeRegistryConfig.DisplaySubKeys = $DisplaySubKeys
   $treeRegistryConfig.DisplayValues = $DisplayValues
   $treeRegistryConfig.ExcludedKeys = $Path
   $treeRegistryConfig.IncludedKeys = $Path
   $treeRegistryConfig.MaxDepth = $Depth
  
   Get-TreeRegistryView -TreeRegistryConfig $treeRegistryConfig
}

Show-PowerTreeRegistry -Path "HKLM:\SOFTWARE\Policies" -DisplayValues
# Show-PowerTreeRegistry @args