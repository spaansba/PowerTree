function Write-CheckForUpdates {
    Write-Host "Check for updates:" -ForegroundColor Cyan
    $updateInfo = Get-UpdateAvailable
    if($updateInfo.UpdateAvailable){
        write-host "Installed Version: " $update.InstalledVersion -ForegroundColor Green
        write-host "Latest Version: " $update.LatestVersion -ForegroundColor Green
    } else {
        write-host "PowerTree is up-to-date" -ForegroundColor Yellow
    }
}
