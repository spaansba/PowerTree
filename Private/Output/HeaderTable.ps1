function Get-HeaderTable {
    [CmdletBinding()]
    param(
        [bool]$DisplayCreationDate,
        [bool]$DisplayLastAccessDate,
        [bool]$DisplayModificationDate,
        [bool]$DisplaySize,
        [bool]$DisplayMode
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
            $headerTable.UnderscoreLine += "$("-" * ($headerString.Length + $extraSpacing.Length))$regularSpacing"
            
            $headerTable.HeaderColumns += $headerString
        }
    }
    
  
    $hierarchyHeader = "Hierarchy"
    $headerTable.Indentations[$hierarchyHeader] = $headerTable.HeaderLine.Length
    $headerTable.HeaderLine += $hierarchyHeader
    $headerTable.UnderscoreLine += "-" * $hierarchyHeader.Length
    $headerTable.HeaderColumns += $hierarchyHeader
 
    return $headerTable
}

function Write-HeaderToOutput {
    [CmdletBinding()]
    param(
        [hashtable]$HeaderTable,
        [System.Text.StringBuilder]$OutputBuilder,
        [bool]$Quiet
    )
    
    if ($Quiet) {
        return
    }

    # Display the headers and underlines in console
    Write-Host $HeaderTable.HeaderLine -ForegroundColor Magenta
    Write-Host $HeaderTable.UnderscoreLine
    
    # Write to OutputBuilder if it exists
    if ($null -ne $OutputBuilder) {
        [void]$OutputBuilder.AppendLine($HeaderTable.HeaderLine)
        [void]$OutputBuilder.AppendLine($HeaderTable.UnderscoreLine)
    }
}

function Build-OutputLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$HeaderTable,
        
        [Parameter(Mandatory=$true)]
        [System.IO.FileSystemInfo]$Item,
        
        [Parameter(Mandatory=$false)]
        [string]$TreePrefix = ""
    )
    
    # Create a line with enough space for all columns
    $outputLine = " " * $HeaderTable.HeaderLine.Length
    
    # Process each column and place content at the correct position
    foreach ($column in $HeaderTable.HeaderColumns) {
        if ($column -eq "Hierarchy") {
            # Handle hierarchy column separately (it contains the tree structure and filename)
            $hierarchyPosition = $HeaderTable.Indentations[$column]
            $content = "$TreePrefix$($Item.Name)"
            
            # Replace characters at the hierarchy position with the content
            if ($hierarchyPosition -lt $outputLine.Length) {
                $outputLine = $outputLine.Remove($hierarchyPosition)
            } else {
                $outputLine = $outputLine.PadRight($hierarchyPosition)
            }
            $outputLine = $outputLine + $content
        } else {
            # For all other columns
            $columnPosition = $HeaderTable.Indentations[$column]
            $content = ""
            
            # Get the appropriate content based on column type
            switch ($column) {
                "Mode" {
                    $content = $Item.Mode.ToString()
                }
                "Creation Date" {
                    $content = $Item.CreationTime.ToString("yyyy-MM-dd HH:mm")
                }
                "Modification Date" {
                    $content = $Item.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
                }
                "Last Access Date" {
                    $content = $Item.LastAccessTime.ToString("yyyy-MM-dd HH:mm")
                }
                "Size" {
                    if ($Item -is [System.IO.FileInfo]) {
                        $content = Get-HumanReadableSize -Bytes $Item.Length -Format "Padded"
                    } else {
                        $content = "        "
                    }
                }
            }
            
            # Replace characters at the column position with the content
            if ($columnPosition -lt $outputLine.Length) {
                # Calculate how many characters we can safely replace
                $replaceLength = [Math]::Min($content.Length, [Math]::Max(0, $outputLine.Length - $columnPosition))
                
                if ($replaceLength -gt 0) {
                    $outputLine = $outputLine.Remove($columnPosition, $replaceLength)
                }
                
                # Make sure we have enough space before using Substring
                if ($columnPosition -lt $outputLine.Length) {
                    $remainingLength = [Math]::Max(0, $outputLine.Length - ($columnPosition + $content.Length))
                    if ($remainingLength -gt 0) {
                        $outputLine = $outputLine.Substring(0, $columnPosition) + $content + $outputLine.Substring($columnPosition + $content.Length)
                    } else {
                        $outputLine = $outputLine.Substring(0, $columnPosition) + $content
                    }
                } else {
                    $outputLine = $outputLine.PadRight($columnPosition) + $content
                }
            } else {
                # Handle case where column position is beyond string length
                $outputLine = $outputLine.PadRight($columnPosition) + $content
            }
        }
    }
    
    return @{
        Line = $outputLine
        SizeColor = if (($Item -is [System.IO.FileInfo]) -and ($HeaderTable.HeaderColumns -contains "Size")) {
            Get-SizeColor -Bytes $Item.Length
        } else {
            $null
        }
        SizePosition = if ($HeaderTable.HeaderColumns -contains "Size") {
            $HeaderTable.Indentations["Size"]
        } else {
            -1
        }
        SizeLength = if (($Item -is [System.IO.FileInfo]) -and ($HeaderTable.HeaderColumns -contains "Size")) {
            (Get-HumanReadableSize -Bytes $Item.Length -Format "Padded").Length
        } else {
            0
        }
    }
}