function Get-HeaderTable {
    [CmdletBinding()]
    param(
        [bool]$DisplayCreationDate,
        [bool]$DisplayLastAccessDate,
        [bool]$DisplayModificationDate,
        [bool]$DisplaySize,
        [bool]$DisplayMode,
        [hashtable]$LineStyle
    )

    $headerTable = @{
        Indentations = @{}
        HeaderLine = ""
        UnderscoreLine = ""
        HeaderColumns = @()
    }
    $regularSpacing = "   "
    
    $headerConfigs = @(
        @{
            Condition = $DisplayMode
            HeaderString = "Mode"
            ExtraSpacing = "  "
        },
        @{
            Condition = $DisplayCreationDate
            HeaderString = "Creation Date"
            ExtraSpacing = " " * ("Modification Date".Length - "Creation Date".Length)
        },
        @{
            Condition = $DisplayLastAccessDate
            HeaderString = "Last Access Date"
            ExtraSpacing = " " * ("Modification Date".Length - "Last Access Date".Length)
        },
        @{
            Condition = $DisplayModificationDate
            HeaderString = "Modification Date"
            ExtraSpacing = ""
        },
        @{
            Condition = $DisplaySize
            HeaderString = "Size"
            ExtraSpacing = "      " 
        }
    )
    
    # Add headers based on display flags
    foreach ($config in $headerConfigs) {
        if ($config.Condition) {
            $headerString = $config.HeaderString
            $extraSpacing = $config.ExtraSpacing
            
            $headerTable.Indentations[$headerString] = $headerTable.HeaderLine.Length
            
            $headerTable.HeaderLine += "$headerString$regularSpacing$extraSpacing"
            $headerTable.UnderscoreLine += "$($LineStyle.SingleLine * ($headerString.Length + $extraSpacing.Length))$regularSpacing"
            
            $headerTable.HeaderColumns += $headerString
        }
    }
    
  
    $hierarchyHeader = "Hierarchy"
    $headerTable.Indentations[$hierarchyHeader] = $headerTable.HeaderLine.Length
    $headerTable.HeaderLine += $hierarchyHeader
    $headerTable.UnderscoreLine += $LineStyle.SingleLine * $hierarchyHeader.Length
    $headerTable.HeaderColumns += $hierarchyHeader
 
    return $headerTable
}
