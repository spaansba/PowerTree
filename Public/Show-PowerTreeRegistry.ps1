function Show-PowerTreeRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Path = ".",

        [Parameter()]
        [Alias("ds")]
        [switch]$DisplaySubKeys,

        [Parameter()]
        [Alias("nv")]
        [switch]$NoValues,

        # [Parameter()]
        # [Alias("nv")]
        # [switch]$No,

        [Parameter()]
        [Alias("st")]
        [switch]$SortValuesByType,

        [Parameter()]   
        [Alias("dt", "types", "rdt")]
        [switch]$UseRegistryDataTypes,

        [Parameter()]
        [Alias("des", "desc", "descending")]
        [switch]$SortDescending,

        [Parameter()]
        [Alias("dic")]
        [switch]$DisplayItemCounts,

        [Parameter()]
        [Alias("e","exc")]
        [string[]]$Exclude = @(),

        [Parameter()]
        [Alias("i", "inc")]
        [string[]]$Include = @(),

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
   . .\Private\Shared\Build-TreeLineStyle.ps1
   . .\Private\PowerTreeRegistry\Filtering\Test-FilterMatch.ps1

   $jsonSettings = Get-SettingsFromJson -Mode "Registry"

   $treeRegistryConfig = [TreeRegistryConfig]::new()
   $treeRegistryConfig.Path = Get-Path -Path $Path
   $treeRegistryConfig.DisplaySubKeys = $DisplaySubKeys
   $treeRegistryConfig.NoValues = $NoValues
   $treeRegistryConfig.Exclude = $Exclude
   $treeRegistryConfig.Include = $Include
   $treeRegistryConfig.MaxDepth = if ($Depth -ne -1) { $Depth } else { $jsonSettings.MaxDepth }
   $treeRegistryConfig.LineStyle = Build-TreeLineStyle -Style $jsonSettings.LineStyle
   $treeRegistryConfig.DisplayItemCounts = $DisplayItemCounts
   $treeRegistryConfig.SortValuesByType = $SortValuesByType
   $treeRegistryConfig.SortDescending = $SortDescending
   $treeRegistryConfig.UseRegistryDataTypes = $UseRegistryDataTypes

   Get-TreeRegistryView -TreeRegistryConfig $treeRegistryConfig
}

Show-PowerTreeRegistry -Path "HKLM:\SOFTWARE\Policies\Microsoft" -dic -desc  -e "Windows ??"
# Show-PowerTreeRegistry @args