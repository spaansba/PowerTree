function Write-OutputLine {
    param (
        [string]$Line,
        [System.ConsoleColor]$ForegroundColor = $Host.UI.RawUI.ForegroundColor,
        [bool]$Quiet,
        [System.Text.StringBuilder]$OutputBuilder
    )
    if ($Quiet -eq $false) {
        Write-Host $Line -ForegroundColor $ForegroundColor
    }
    if ($null -ne $OutputBuilder) {
        [void]$OutputBuilder.AppendLine($Line)
    }
}