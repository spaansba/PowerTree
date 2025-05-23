function Show-PowerTreeRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Path = ".",

        [Parameter()]
        [Alias("s")]
        [switch]$ShowSubKeys,

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

   $treeRegistryConfig = [TreeRegistryConfig]::new()
   $treeRegistryConfig.Path = Get-Path -Path $Path
   $treeRegistryConfig.ShowSubKeys = $ShowSubKeys
   $treeRegistryConfig.ExcludedKeys = $Path
   $treeRegistryConfig.IncludedKeys = $Path
   $treeRegistryConfig.MaxDepth = $Depth

   Get-TreeRegistryView -TreeRegistryConfig $treeRegistryConfig
}

Show-PowerTreeRegistry -Path "HKLM:\SOFTWARE\Policies"
# Show-PowerTreeRegistry @args