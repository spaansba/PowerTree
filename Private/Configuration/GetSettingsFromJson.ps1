function Get-PowerTreeSettingsFromJson {
    [CmdletBinding()]
    param(
        [string[]]$ConfigPaths = (Get-PowerTreeConfigPaths)
    )
    
    $defaultSettings = Get-PowerTreeDefaultConfig
    
    try {
        Write-Verbose "Searching for configuration files in the following locations:"
        foreach ($path in $ConfigPaths) {
            Write-Verbose "  - $path"
            
            if (Test-Path $path) {
                $fileContent = Get-Content -Path $path -Raw -ErrorAction Stop
                $settings = $fileContent | ConvertFrom-Json -ErrorAction Stop
                
                Write-Verbose "Settings loaded from $path"
                
                $settingsHashtable = @{
                    ExcludeDirectories = if ($settings.ExcludeDirectories -is [array]) { $settings.ExcludeDirectories } else { @() }
                    Sorting = @{
                        By = $settings.Sorting.By
                        SortFolders = $settings.Sorting.SortFolders
                    }
                    Files = @{
                        ExcludeExtensions = if ($settings.Files.ExcludeExtensions -is [array]) { $settings.Files.ExcludeExtensions } else { @() }
                        IncludeExtensions = if ($settings.Files.IncludeExtensions -is [array]) { $settings.Files.IncludeExtensions } else { @() }
                        FileSizeMinimum = if ($settings.Files.FileSizeMinimum) { $settings.Files.FileSizeMinimum } else { "-1kb" }
                        FileSizeMaximum = if ($settings.Files.FileSizeMaximum) { $settings.Files.FileSizeMaximum } else { "-1kb" }
                        OpenOutputFileOnFinish = if ($null -ne $settings.Files.OpenOutputFileOnFinish) { $settings.Files.OpenOutputFileOnFinish } else { $true }
                    }
                    ShowConnectorLines = if ($null -ne $settings.ShowConnectorLines) { $settings.ShowConnectorLines } else { $true }
                    ShowExecutionStats = if ($null -ne $settings.ShowExecutionStats) { $settings.ShowExecutionStats } else { $true }
                    MaxDepth = if ($null -ne $settings.MaxDepth) { $settings.MaxDepth } else { -1 }
                    LineStyle = if ($settings.LineStyle) { $settings.LineStyle } else { "Unicode" }
                }
                
                # Debugging: Log the parsed settings
                Write-Verbose ("Parsed Settings: " + ($settingsHashtable | ConvertTo-Json -Depth 5))
                
                return $settingsHashtable
            }
        }
        
        Write-Verbose "Config file not found in any of the potential locations. Using default settings."
        return $defaultSettings
    } catch {
        Write-Warning "Error loading settings file: $($_.Exception.Message)"
        Write-Verbose "Using default settings instead."
        return $defaultSettings
    }
}

function Get-PowerTreeDefaultConfig {
    [CmdletBinding()]
    param()
    
    return @{
        ExcludeDirectories = @()
        Sorting = @{
            By = "Name"
            SortFolders = $false
        }
        Files = @{
            ExcludeExtensions = @()
            IncludeExtensions = @()
            FileSizeMinimum = "-1kb"
            FileSizeMaximum = "-1kb"
            OpenOutputFileOnFinish = $true
        }
        ShowConnectorLines = $true
        ShowExecutionStats = $true
        MaxDepth = -1 # -1 means no depth limit
        LineStyle = "Unicode"
    }
}

function Get-PowerTreeConfigPaths {
    [CmdletBinding()]
    param()
    
    return @(
        "$PSScriptRoot\PowerTree.config.json",
        "$PSScriptRoot\..\PowerTree.config.json",
        "$PSScriptRoot\..\..\PowerTree.config.json",
        "$env:USERPROFILE\.PowerTree\config.json",
        "$env:HOME\.PowerTree\config.json"
    )
}
