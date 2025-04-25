
function Build-OutputLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$HeaderTable,
        
        [Parameter(Mandatory=$true)]
        [System.IO.FileSystemInfo]$Item,
        
        [Parameter(Mandatory=$false)]
        [string]$TreePrefix = "",

        [Parameter(Mandatory=$true)]
        [bool]$HumanReadableSizes = $true
    )
    
    $dirSize = 0
    
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
            $columnPosition = $HeaderTable.Indentations[$column]
            $content = ""
            
           
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
                # for folders get the the size of all folders recursively
                # for files get the size of the file
                "Size" {
                    if ($Item -is [System.IO.FileInfo]) {
                        if($HumanReadableSizes){
                            $content = Get-HumanReadableSize -Bytes $Item.Length -Format "Padded"
                        } else {
                            $content = $Item.Length
                        }
                        # Set to zero for files
                        $dirSize = 0
                    } else {
                        # Calculate directory size
                        $dirSize = (Get-ChildItem $Item.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                                    Measure-Object -Property Length -Sum).Sum
                         if($HumanReadableSizes){
                            $content = Get-HumanReadableSize -Bytes $dirSize -Format "Padded"
                        } else {
                            $content = $dirSize
                        }
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
        DirSize = if ($Item -isnot [System.IO.FileInfo]) {
            $dirSize
        } else {
            0
        }
    }
}