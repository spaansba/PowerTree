function Get-DefaultConfig {
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
        HumanReadableSizes = $true 
    }
}
