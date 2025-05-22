function Write-OutputLine {
    param (
        [string]$Line,
        [bool]$Quiet,
        [System.Text.StringBuilder]$OutputBuilder
    )
    if ($Quiet -eq $false) {
        Write-Host $Line
    }
    if ($null -ne $OutputBuilder) {
        [void]$OutputBuilder.AppendLine($Line)
    }
}