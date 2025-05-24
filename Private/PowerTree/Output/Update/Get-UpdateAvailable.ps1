function Get-UpdateAvailable {
    [CmdletBinding()]
    param()
    
    # Get installed version
    $installedVersion = $null
    $module = Get-InstalledModule -Name PowerTree -ErrorAction SilentlyContinue
    if ($module) {
        $installedVersion = $module.Version
    }
    else {
        Write-Error "Error getting installed version of PowerTree"
        return $null
    }

    # Get latest version from gallery
    try {
        $galleryModule = Find-Module -Name PowerTree -ErrorAction Stop
        if ($galleryModule) {
            $galleryVersion = $galleryModule.Version
        }
        else {
            Write-Error "Error getting latest version of PowerTree"
            return $null
        }
    }
    catch {
        Write-Error "Error connecting to PowerShell Gallery: $_"
        return $null
    }
    
    # Compare versions and return results
    $updateAvailable = [System.Version]$galleryVersion -gt [System.Version]$installedVersion
    
    return @{
        UpdateAvailable = $updateAvailable
        InstalledVersion = $installedVersion
        LatestVersion = $galleryVersion
    }
}