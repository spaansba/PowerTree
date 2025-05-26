
function Write-HeaderToOutput {
    [CmdletBinding()]
    param(
        [hashtable]$HeaderTable,
        [System.Text.StringBuilder]$OutputBuilder,
        [hashtable]$LineStyle
    )
    
    if ($null -ne $OutputBuilder) {
        [void]$OutputBuilder.AppendLine($HeaderTable.HeaderLine)
        [void]$OutputBuilder.AppendLine($HeaderTable.UnderscoreLine)
    }else {
        Write-Host $HeaderTable.HeaderLine -ForegroundColor Magenta
        Write-Host $HeaderTable.UnderscoreLine
    }
}
