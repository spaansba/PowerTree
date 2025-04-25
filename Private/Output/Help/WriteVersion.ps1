function Write-Version {
    $moduleInfo = Get-Module PowerTree
    Write-Host $moduleInfo
    if ($moduleInfo) {
        Write-Host "PowerTree version $($moduleInfo.Version)" -ForegroundColor Cyan
    } else {
       Write-Error "Could not determine PowerTree information." 
    }
}