function Get-ConfigPaths {
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
