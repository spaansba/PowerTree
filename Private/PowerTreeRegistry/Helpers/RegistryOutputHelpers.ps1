function Write-RegistryOutputLine {
    param (
        [string]$Line,
        [bool]$Quiet = $false,
        [System.Text.StringBuilder]$OutputBuilder = $null
    )
    
    if (-not $Quiet) {
        Write-Host $Line
    }
    
    if ($null -ne $OutputBuilder) {
        [void]$OutputBuilder.AppendLine($Line)
    }
}

function Get-RegistryValueString {
    param (
        [object]$Value,
        [Microsoft.Win32.RegistryValueKind]$ValueType
    )
    
    if ($null -eq $Value) {
        return "(null)"
    }
    
    switch ($ValueType) {
        "String" { return "`"$Value`"" }
        "ExpandString" { return "`"$Value`" (expandable)" }
        "DWord" { return "0x$($Value.ToString('X8')) ($Value)" }
        "QWord" { return "0x$($Value.ToString('X16')) ($Value)" }
        "Binary" { 
            if ($Value -is [byte[]]) {
                $hexString = ($Value | ForEach-Object { $_.ToString('X2') }) -join ' '
                if ($hexString.Length -gt 50) {
                    $hexString = $hexString.Substring(0, 47) + "..."
                }
                return "[$hexString]"
            }
            return "[Binary data]"
        }
        "MultiString" { 
            if ($Value -is [string[]]) {
                $joinedString = $Value -join '; '
                if ($joinedString.Length -gt 100) {
                    $joinedString = $joinedString.Substring(0, 97) + "..."
                }
                return "[$joinedString]"
            }
            return "[Multi-string data]"
        }
        default { 
            $stringValue = $Value.ToString()
            if ($stringValue.Length -gt 100) {
                $stringValue = $stringValue.Substring(0, 97) + "..."
            }
            return $stringValue
        }
    }
}

function Get-RegistryLineStyle {
    return @{
        Branch = "├── "
        LastBranch = "└── "
        Vertical = "│   "
        Space = "    "
        VerticalLine = "│"
    }
}