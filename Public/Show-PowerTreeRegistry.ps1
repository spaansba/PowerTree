function Show-PowerTreeRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$Path = ".",

        [Parameter()]
        [Alias("ds")]
        [switch]$DisplaySubKeys,

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

    # Load all your modules...
    . .\Private\Shared\DataModel\Classes.ps1
    . .\Private\PowerTreeRegistry\Configuration\ParamHelpers\Get-Path.ps1
    . .\Private\PowerTreeRegistry\Output\Get-TreeRegistryView.ps1
    . .\Private\PowerTreeRegistry\Filtering\Get-RegistryItems.ps1
    . .\Private\Shared\JsonConfig\Get-SettingsFromJson.ps1
    . .\Private\Shared\JsonConfig\Get-DefaultConfig.ps1
    . .\Private\Shared\JsonConfig\Get-ConfigPaths.ps1
    . .\Private\Shared\Build-TreeLineStyle.ps1
    . .\Private\PowerTreeRegistry\Filtering\Test-FilterMatch.ps1
    . .\Private\PowerTreeRegistry\Filtering\Get-ProcessedRegistryKeys.ps1
    . .\Private\PowerTreeRegistry\Filtering\Get-ProcessedRegistryValues.ps1
    . .\Private\PowerTreeRegistry\Filtering\Set-LastItemFlag.ps1
    . .\Private\PowerTreeRegistry\Sorting\Invoke-RegistryItemSorting.ps1
    . .\Private\PowerTreeRegistry\Configuration\Write-RegistryConfiguration.ps1
    . .\Private\Shared\Output\Add-DefaultExtension.ps1
    . .\Private\PowerTreeRegistry\Output\ToFile\Invoke-OutputBuilderRegistry.ps1
    . .\Private\PowerTreeRegistry\Output\Get-RegistryConfigurationData.ps1
    . .\Private\PowerTreeRegistry\Output\Show-RegistryStats.ps1

    $jsonSettings = Get-SettingsFromJson -Mode "Registry"

    $treeRegistryConfig = New-Object treeRegistryConfig
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
    $treeRegistryConfig.OutFile = Add-DefaultExtension -FilePath $OutFile -Quiet $false -IsRegistry $true

    # Initialize variables for results
    $outputBuilder = $null
    $output = $null
    $registryStats = $null

    $executionResultTime = Measure-Command {
        # Check if we have an output file
        $hasOutputFile = -not [string]::IsNullOrEmpty($treeRegistryConfig.OutFile)

        if ($hasOutputFile) {
            # File output mode
            $outputBuilder = Invoke-OutputBuilderRegistry -TreeRegistryConfig $treeRegistryConfig -ShowConfigurations $jsonSettings.ShowConfigurations
            
            if ($null -eq $outputBuilder) {
                Write-Error "OutputBuilder is null! Check Invoke-OutputBuilderRegistry function."
                return
            }
            
            $output = [System.Collections.Generic.List[string]]::new()
            
            # Collect the tree output and stats
            $registryStats = Get-TreeRegistryView -TreeRegistryConfig $treeRegistryConfig -OutputCollection $output
            
            # Add tree output to the builder
            foreach ($line in $output) {
                [void]$outputBuilder.AppendLine($line)
            }
            
            # Save to file
            $outputBuilder.ToString() | Out-File -FilePath $treeRegistryConfig.OutFile -Encoding UTF8
            
        } else {
            # Console output mode
            if($jsonSettings.ShowConfigurations){
                Write-RegistryConfiguration -TreeRegistryConfig $treeRegistryConfig 
            }
            $registryStats = Get-TreeRegistryView -TreeRegistryConfig $treeRegistryConfig
        }
    }

    # Display results after execution
    if (-not [string]::IsNullOrEmpty($treeRegistryConfig.OutFile)) {
        # Show success message for file output
        $fullOutputPath = Resolve-Path $treeRegistryConfig.OutFile -ErrorAction SilentlyContinue
        if ($null -eq $fullOutputPath) {
            $fullOutputPath = $treeRegistryConfig.OutFile
        }
        Write-Host "Output saved to: $($fullOutputPath)" -ForegroundColor Cyan
    }

    # Show registry statistics
    if ($null -ne $registryStats -and $jsonSettings.ShowExecutionStats) {
        Show-RegistryStats -RegistryStats $registryStats -ExecutionTime $executionResultTime -LineStyle $treeRegistryConfig.LineStyle
    }
}

Show-PowerTreeRegistry -Path "HKLM:\SOFTWARE\Policies\Microsoft"