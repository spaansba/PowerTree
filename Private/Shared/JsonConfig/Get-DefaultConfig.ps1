function Get-DefaultConfig {
    [CmdletBinding()]
    param()
    
    return @{
        Shared = @{
            ShowConnectorLines = $true
            ShowExecutionStats = $true
            ShowConfigurations = $true
            LineStyle = "Unicode"
            OpenOutputFileOnFinish = $true
        }
        FileSystem = @{
            MaxDepth = -1 # -1 means no depth limit
            ExcludeDirectories = @()
            Files = @{
                ExcludeExtensions = @()
                IncludeExtensions = @()
                FileSizeMinimum = "-1kb"
                FileSizeMaximum = "-1kb"
            }
            Sorting = @{
                By = "Name"
                SortFolders = $false
            }
            HumanReadableSizes = $true
        }
        Registry = @{
            MaxDepth = -1 # -1 means no depth limit
            ExcludeKeys = @()
        }
    }
}