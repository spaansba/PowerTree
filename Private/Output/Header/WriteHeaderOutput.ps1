
function Write-HeaderToOutput {
    [CmdletBinding()]
    param(
        [hashtable]$HeaderTable,
        [System.Text.StringBuilder]$OutputBuilder,
        [bool]$Quiet,
        [hashtable]$LineStyle
    )
    
    if ($Quiet) {
        return
    }

    Write-Host $HeaderTable.HeaderLine -ForegroundColor Magenta
    Write-Host $HeaderTable.UnderscoreLine
    
    if ($null -ne $OutputBuilder) {
        [void]$OutputBuilder.AppendLine($HeaderTable.HeaderLine)
        [void]$OutputBuilder.AppendLine($HeaderTable.UnderscoreLine)
    }
}
