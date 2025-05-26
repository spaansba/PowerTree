function Show-PowerTreeRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Path = ".",

        [Parameter()]
        [Alias("o", "of")]
        [string]$OutFile,

        [Parameter()]
        [Alias("nv")]
        [switch]$NoValues,

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
    
    $jsonSettings = Get-SettingsFromJson -Mode "Registry"

    $treeRegistryConfig = New-Object treeRegistryConfig
    $treeRegistryConfig.Path = Get-Path -Path $Path
    $treeRegistryConfig.NoValues = $NoValues
    $treeRegistryConfig.Exclude = $Exclude
    $treeRegistryConfig.Include = $Include
    $treeRegistryConfig.MaxDepth = if ($Depth -ne -1) { $Depth } else { $jsonSettings.MaxDepth }
    $treeRegistryConfig.LineStyle = Build-TreeLineStyle -Style $jsonSettings.LineStyle
    $treeRegistryConfig.DisplayItemCounts = $DisplayItemCounts
    $treeRegistryConfig.SortValuesByType = $SortValuesByType
    $treeRegistryConfig.SortDescending = $SortDescending
    $treeRegistryConfig.UseRegistryDataTypes = $UseRegistryDataTypes
    $treeRegistryConfig.OutFile = Add-DefaultExtension -FilePath $OutFile -IsRegistry $true

    $outputBuilder = $null
    $output = $null
    $registryStats = $null

    $executionResultTime = Measure-Command {
        $hasOutputFile = -not [string]::IsNullOrEmpty($treeRegistryConfig.OutFile)

        if ($hasOutputFile) {
            $outputBuilder = Invoke-OutputBuilderRegistry -TreeRegistryConfig $treeRegistryConfig -ShowConfigurations $jsonSettings.ShowConfigurations
            $output = [System.Collections.Generic.List[string]]::new()
            $registryStats = Get-TreeRegistryView -TreeRegistryConfig $treeRegistryConfig -OutputCollection $output
            
            foreach ($line in $output) {
                [void]$outputBuilder.AppendLine($line)
            }
            
        } else {
            if($jsonSettings.ShowConfigurations){
                Write-ConfigurationToHost -Config $treeRegistryConfig 
            }
            $registryStats = Get-TreeRegistryView -TreeRegistryConfig $treeRegistryConfig
        }
    }

    if ($null -ne $registryStats -and $jsonSettings.ShowExecutionStats) {
        $hasOutputFile = -not [string]::IsNullOrEmpty($treeRegistryConfig.OutFile)
        
        if ($hasOutputFile) {
            [void](Show-RegistryStats -RegistryStats $registryStats -ExecutionTime $executionResultTime -LineStyle $treeRegistryConfig.LineStyle -OutputBuilder $outputBuilder)
            $outputBuilder.ToString() | Out-File -FilePath $treeRegistryConfig.OutFile -Encoding UTF8
        } else {
            Show-RegistryStats -RegistryStats $registryStats -ExecutionTime $executionResultTime -LineStyle $treeRegistryConfig.LineStyle
        }
    } elseif (-not [string]::IsNullOrEmpty($treeRegistryConfig.OutFile)) {
        $outputBuilder.ToString() | Out-File -FilePath $treeRegistryConfig.OutFile -Encoding UTF8
    }

    if (-not [string]::IsNullOrEmpty($treeRegistryConfig.OutFile)) {
        $fullOutputPath = Resolve-Path $treeRegistryConfig.OutFile -ErrorAction SilentlyContinue
        if ($null -eq $fullOutputPath) {
            $fullOutputPath = $treeRegistryConfig.OutFile
        }
        Write-Host ""
        Write-Host "Output saved to: $($fullOutputPath)" -ForegroundColor Cyan
        Write-Host ""
    }
}
