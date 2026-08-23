function Get-TreeView {
    param (
        [Parameter(Mandatory=$true)]
        [object]$TreeConfig,
        [Parameter(Mandatory=$true)]
        [hashtable]$ChildItemFileParams,
        [Parameter(Mandatory=$true)]
        [object]$TreeStats,
        [System.Text.StringBuilder]$OutputBuilder = $null
    )

    $TreeStats.MaxDepth = 1
    $snapshot = Get-TreeSnapshot -TreeConfig $TreeConfig -ChildItemFileParams $ChildItemFileParams
    Write-TreeSnapshot -Node $snapshot `
        -TreeConfig $TreeConfig `
        -TreeStats $TreeStats `
        -OutputBuilder $OutputBuilder
}
