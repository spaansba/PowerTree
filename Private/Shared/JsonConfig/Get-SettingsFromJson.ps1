function Get-SettingsFromJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("FileSystem", "Registry")]
        [string]$Mode,
        
        [string[]]$ConfigPaths = (Get-ConfigPaths)
    )
    
    $defaultSettings = Get-DefaultConfig
    
    try {
        Write-Verbose "Searching for configuration files in the following locations:"
        foreach ($path in $ConfigPaths) {
            Write-Verbose "  - $path"
            
            if (Test-Path $path) {
                $fileContent = Get-Content -Path $path -Raw -ErrorAction Stop
                $settings = $fileContent | ConvertFrom-Json -ErrorAction Stop
                
                Write-Verbose "Settings loaded from $path"
                
                # Base hashtable with shared settings
                $settingsHashtable = @{
                    ShowConnectorLines = if ($null -ne $settings.Shared.ShowConnectorLines) { $settings.Shared.ShowConnectorLines } else { $defaultSettings.Shared.ShowConnectorLines }
                    ShowExecutionStats = if ($null -ne $settings.Shared.ShowExecutionStats) { $settings.Shared.ShowExecutionStats } else { $defaultSettings.Shared.ShowExecutionStats }
                    ShowConfigurations = if ($null -ne $settings.Shared.ShowConfigurations) { $settings.Shared.ShowConfigurations } else { $defaultSettings.Shared.ShowConfigurations }
                    LineStyle = if ($settings.Shared.LineStyle) { $settings.Shared.LineStyle } else { $defaultSettings.Shared.LineStyle }
                    OpenOutputFileOnFinish = if ($null -ne $settings.Shared.OpenOutputFileOnFinish) { $settings.Shared.OpenOutputFileOnFinish } else { $defaultSettings.Shared.OpenOutputFileOnFinish }
                }
                
                # Add mode-specific settings
                switch ($Mode) {
                    "FileSystem" {
                        $settingsHashtable += @{
                            MaxDepth = if ($null -ne $settings.FileSystem.MaxDepth) { $settings.FileSystem.MaxDepth } else { $defaultSettings.FileSystem.MaxDepth }
                            ExcludeDirectories = if ($settings.FileSystem.ExcludeDirectories -is [array]) { $settings.FileSystem.ExcludeDirectories } else { $defaultSettings.FileSystem.ExcludeDirectories }
                            HumanReadableSizes = if ($null -ne $settings.FileSystem.HumanReadableSizes) { $settings.FileSystem.HumanReadableSizes } else { $defaultSettings.FileSystem.HumanReadableSizes }
                            Files = @{
                                ExcludeExtensions = if ($settings.FileSystem.Files.ExcludeExtensions -is [array]) { $settings.FileSystem.Files.ExcludeExtensions } else { $defaultSettings.FileSystem.Files.ExcludeExtensions }
                                IncludeExtensions = if ($settings.FileSystem.Files.IncludeExtensions -is [array]) { $settings.FileSystem.Files.IncludeExtensions } else { $defaultSettings.FileSystem.Files.IncludeExtensions }
                                FileSizeMinimum = if ($settings.FileSystem.Files.FileSizeMinimum) { $settings.FileSystem.Files.FileSizeMinimum } else { $defaultSettings.FileSystem.Files.FileSizeMinimum }
                                FileSizeMaximum = if ($settings.FileSystem.Files.FileSizeMaximum) { $settings.FileSystem.Files.FileSizeMaximum } else { $defaultSettings.FileSystem.Files.FileSizeMaximum }
                            }
                            Sorting = @{
                                By = if ($settings.FileSystem.Sorting.By) { $settings.FileSystem.Sorting.By } else { $defaultSettings.FileSystem.Sorting.By }
                                SortFolders = if ($null -ne $settings.FileSystem.Sorting.SortFolders) { $settings.FileSystem.Sorting.SortFolders } else { $defaultSettings.FileSystem.Sorting.SortFolders }
                            }
                        }
                    }
                    "Registry" {
                        $settingsHashtable += @{
                            MaxDepth = if ($null -ne $settings.Registry.MaxDepth) { $settings.Registry.MaxDepth } else { $defaultSettings.Registry.MaxDepth }
                            ExcludeKeys = if ($settings.Registry.ExcludeKeys -is [array]) { $settings.Registry.ExcludeKeys } else { $defaultSettings.Registry.ExcludeKeys }
                        }
                    }
                }
                
                Write-Verbose ("Parsed $Mode Settings: " + ($settingsHashtable | ConvertTo-Json -Depth 5))
                return $settingsHashtable
            }
        }
        
        Write-Verbose "Config file not found in any of the potential locations. Using default settings."
        return Get-FlattenedDefaultSettings -Mode $Mode -DefaultSettings $defaultSettings
        
    } catch {
        Write-Warning "Error loading settings file: $($_.Exception.Message)"
        Write-Verbose "Using default settings instead."
        return Get-FlattenedDefaultSettings -Mode $Mode -DefaultSettings $defaultSettings
    }
}

function Get-FlattenedDefaultSettings {
    param(
        [string]$Mode,
        [hashtable]$DefaultSettings
    )
    
    $flattened = @{
        ShowConnectorLines = $DefaultSettings.Shared.ShowConnectorLines
        ShowExecutionStats = $DefaultSettings.Shared.ShowExecutionStats
        LineStyle = $DefaultSettings.Shared.LineStyle
        Sorting = $DefaultSettings.Shared.Sorting
    }
    
    switch ($Mode) {
        "FileSystem" {
            $flattened += @{
                MaxDepth = $DefaultSettings.FileSystem.MaxDepth
                ExcludeDirectories = $DefaultSettings.FileSystem.ExcludeDirectories
                HumanReadableSizes = $DefaultSettings.FileSystem.HumanReadableSizes
                Files = $DefaultSettings.FileSystem.Files
            }
        }
        "Registry" {
            $flattened += @{
                MaxDepth = $DefaultSettings.Registry.MaxDepth
                DisplayValues = $DefaultSettings.Registry.DisplayValues
                ExcludeKeys = $DefaultSettings.Registry.ExcludeKeys
                ValueTypes = $DefaultSettings.Registry.ValueTypes
                EscapeWildcards = $DefaultSettings.Registry.EscapeWildcards
            }
        }
    }
    
    return $flattened
}