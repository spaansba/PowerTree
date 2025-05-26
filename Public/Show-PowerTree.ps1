function Show-PowerTree {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]$LiteralPath = ".",

        [Parameter()]
        [Alias("l", "level")]
        [int]$Depth = -1,

        [Parameter()]
        [Alias("h", "?")]
        [switch]$Help,

        [Parameter()]
        [Alias("i", "info")]
        [switch]$ModuleInfo,

        [Parameter()]
        [Alias("ex", "example")]
        [switch]$Examples,
    
        [Parameter()]
        [Alias("prune", "p")]
        [switch]$PruneEmptyFolders,

        [Parameter()]
        [Alias("da")]
        [switch]$DisplayAll,

        [Parameter()]
        [Alias("dm", "m")]
        [switch]$DisplayMode,
                
        [Parameter()]
        [Alias("s", "size")]
        [switch]$DisplaySize,

        [Parameter()]
        [Alias("dmd")]
        [switch]$DisplayModificationDate,

        [Parameter()]
        [Alias("dcd")]
        [switch]$DisplayCreationDate,

        [Parameter()]
        [Alias("dla")]
        [switch]$DisplayLastAccessDate,

        [Parameter()]
        [Alias("d", "dir")]
        [switch]$DirectoryOnly,
    
        [Parameter()]
        [Alias("e", "exclude")]
        [string[]]$ExcludeDirectories = @(),
    
        [Parameter()]
        [ValidateSet("size", "name", "md", "cd", "la")]
        [string]$Sort,

        [Parameter()]
        [Alias("smd")]
        [switch]$SortByModificationDate,

        [Parameter()]
        [Alias("scd")]
        [switch]$SortByCreationDate,

        [Parameter()]
        [Alias("sla", "sld")]
        [switch]$SortByLastAccessDate,
    
        [Parameter()]
        [Alias("ss")]
        [switch]$SortBySize,
    
        [Parameter()]
        [Alias("sn")]
        [switch]$SortByName,

        [Parameter()]
        [Alias("des", "desc")]
        [switch]$Descending,

        [Parameter()]
        [ValidateScript({
            # Validate format of lower bound size filter
            $_ -match '^\d+(?:\.\d+)?(b|kb|mb|gb|tb)?$'
        })]
        [Alias('fsmi')]
        [string]$FileSizeMinimum = "-1kb",
   
        [Parameter()]
        [ValidateScript({
            # Validate format of upper bound size filter
            $_ -match '^\d+(?:\.\d+)?(b|kb|mb|gb|tb)?$'
        })]
        [Alias('fsma')]
        [string]$FileSizeMaximum = "-1kb",
    
        [Alias('fs', 'filesize')]
        [string]$FileSizeFilter,
    
        [Parameter()]
        [Alias("ef")]
        [string[]]$ExcludeExtensions = @(),
    
        [Parameter()]
        [Alias("if")]
        [string[]]$IncludeExtensions = @(),

        [Parameter()]
        [Alias("force")]
        [switch]$ShowHiddenFiles,

        [Parameter()]
        [Alias("o", "of")]
        [string]$OutFile
    )

    if ($Help) {
        Write-Help
        return
    }

    if($ModuleInfo){
        Write-Info
        return
    }

    if ($Examples) {
        Write-Examples
        return
    }

    if($DisplayAll){
        $DisplayCreationDate = $true
        $DisplayLastAccessDate = $true
        $DisplayModificationDate = $true
        $DisplaySize = $true
        $DisplayMode= $true
    }

    $treeStats = New-Object TreeStats
    $jsonSettings = Get-SettingsFromJson -Mode "FileSystem"

    $treeConfig = New-Object TreeConfig
    $treeConfig.Path = $LiteralPath
    $treeConfig.LineStyle = Build-TreeLineStyle -Style $jsonSettings.LineStyle
    $treeConfig.DirectoryOnly = $DirectoryOnly
    $treeConfig.ExcludeDirectories = Build-ExcludedDirectoryParams -CommandLineExcludedDir $ExcludeDirectories `
                                                                   -Settings $jsonSettings
    $treeConfig.SortBy = Get-SortingMethod -SortBySize $SortBySize `
                                           -SortByName $SortByName `
                                           -SortByCreationDate $SortByCreationDate `
                                           -SortByLastAccessDate $SortByLastAccessDate `
                                           -SortByModificationDate $SortByModificationDate `
                                           -DefaultSort $jsonSettings.Sorting.By `
                                           -Sort $Sort
    $treeConfig.SortDescending = $Descending
    $treeConfig.SortFolders = $jsonSettings.Sorting.SortFolders
    $treeConfig.HeaderTable = Get-HeaderTable -DisplayCreationDate $DisplayCreationDate `
                                              -DisplayLastAccessDate $DisplayLastAccessDate `
                                              -DisplayModificationDate $DisplayModificationDate `
                                              -DisplaySize $DisplaySize `
                                              -DisplayMode $DisplayMode `
                                              -LineStyle $treeConfig.LineStyle

    $treeConfig.ShowConnectorLines = $jsonSettings.ShowConnectorLines
    $treeConfig.ShowHiddenFiles = $ShowHiddenFiles
    $treeConfig.MaxDepth = if ($Depth -ne -1) { $Depth } else { $jsonSettings.MaxDepth }
    $treeConfig.FileSizeBounds = Build-FileSizeParams -CommandLineMaxSize $FileSizeMaximum `
                                                      -CommandlineMinSize $FileSizeMinimum `
                                                      -SettingsLineMaxSize $jsonSettings.Files.FileSizeMaximum `
                                                      -SettingsLineMinSize $jsonSettings.Files.FileSizeMinimum
    $treeConfig.OutFile = Add-DefaultExtension -FilePath $OutFile `
                                                -IsRegistry $false
                                                
    $treeConfig.PruneEmptyFolders = $PruneEmptyFolders
    $treeConfig.HumanReadableSizes = $jsonSettings.HumanReadableSizes
    
    $outputBuilder = Invoke-OutputBuilder -TreeConfig $treeConfig -ShowExecutionStats $jsonSettings.ShowExecutionStats

    # Main entry point
    $executionResultTime = Measure-Command {
        try {
            if (-not (Test-Path $LiteralPath)) {
                throw "Cannot find path '$LiteralPath'"
            }
            
            $ChildItemDirectoryParams = Build-ChildItemDirectoryParams $ShowHiddenFiles
            $ChildItemFileParams = Build-ChildItemFileParams -ShowHiddenFiles $ShowHiddenFiles `
                                                            -CommandLineIncludeExt $IncludeExtensions `
                                                            -CommandLineExcludeExt $ExcludeExtensions `
                                                            -FileSettings $jsonSettings.Files

            Write-ConfigurationToHost -Config $treeConfig 

            Write-HeaderToOutput -HeaderTable $treeConfig.HeaderTable `
                              -OutputBuilder $outputBuilder `
                              -LineStyle $treeConfig.LineStyle

            Get-TreeView -TreeConfig $treeConfig `
                         -TreeStats $treeStats `
                         -ChildItemDirectoryParams $ChildItemDirectoryParams `
                         -ChildItemFileParams $ChildItemFileParams `
                         -OutputBuilder $outputBuilder
        
        } catch {
            Write-Error "Details: $($_.Exception.Message)"
            Write-Error "Location: $($_.InvocationInfo.ScriptLineNumber), $($_.InvocationInfo.PositionMessage)"
            Write-Verbose "Exception details: $($_ | Format-List * -Force | Out-String)"
        }
    }

    if($jsonSettings.ShowExecutionStats) {
        Show-TreeStats -TreeStats $treeStats -ExecutionTime $executionResultTime -OutputBuilder $outputBuilder -LineStyle $treeConfig.LineStyle -DisplaySize $DisplaySize
    }

    if($null -ne $outputBuilder) {
        $outputBuilder.ToString() | Write-ToFile -FilePath $treeConfig.OutFile -OpenOutputFileOnFinish $jsonSettings.Files.OpenOutputFileOnFinish

        $fullOutputPath = Resolve-Path $treeConfig.OutFile -ErrorAction SilentlyContinue
        if ($null -eq $fullOutputPath) {
            $fullOutputPath = $treeConfig.OutFile
        }

        Write-Host ""
        Write-Host "Output saved to: $($fullOutputPath)" -ForegroundColor Cyan
    }

    Write-Host ""
}