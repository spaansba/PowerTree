function Write-Version {
    Write-Host "Checking version:" -ForegroundColor Cyan
    $updateInfo = Get-UpdateAvailable
    if ($updateInfo.UpdateAvailable) {
        Write-Host "Installed Version: $($updateInfo.InstalledVersion)" -ForegroundColor Yellow
        Write-Host "Latest Version: $($updateInfo.LatestVersion)" -ForegroundColor Green
        Write-Host "To update, run: Update-Module PowerTree" -ForegroundColor Cyan
    } else {
        Write-Host "PowerTree Version: $($updateInfo.InstalledVersion)" -ForegroundColor Green
        Write-Host "PowerTree is up-to-date" -ForegroundColor Green
    }
}