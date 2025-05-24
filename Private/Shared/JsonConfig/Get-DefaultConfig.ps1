function Get-DefaultConfig {
    [CmdletBinding()]
    param()
    
    return @{
        Shared = @{
            ShowConnectorLines = $true
            ShowExecutionStats = $true
            ShowConfigurations = $true
            LineStyle = "Unicode"
            Sorting = @{
                By = "Name"
                SortFolders = $false
            }
        }
        FileSystem = @{
            MaxDepth = -1 # -1 means no depth limit
            ExcludeDirectories = @()
            Files = @{
                ExcludeExtensions = @()
                IncludeExtensions = @()
                FileSizeMinimum = "-1kb"
                FileSizeMaximum = "-1kb"
                OpenOutputFileOnFinish = $true
            }
            HumanReadableSizes = $true
        }
        Registry = @{
            MaxDepth = -1 # -1 means no depth limit
            ExcludeKeys = @()
            ValueTypes = @("String", "DWord", "QWord", "Binary", "MultiString", "ExpandString")
            EscapeWildcards = $true
        }
    }
}