function Write-Info {
    $moduleInfo = Get-Module PowerTree
    if (-not $moduleInfo) {
        $moduleInfo = Get-Module PowerTree -ListAvailable | Select-Object -First 1
    }
    
    if ($moduleInfo) {
        Write-Host ""
        Write-Host "PowerTree Information" -ForegroundColor Cyan
        Write-Host "---------------------" -ForegroundColor Cyan
        Write-Host "Version: $($moduleInfo.Version)" -ForegroundColor White
        Write-Host "Author: $($moduleInfo.Author)" -ForegroundColor White
        
        if (-not [string]::IsNullOrEmpty($moduleInfo.Description)) {
            Write-Host "Description: $($moduleInfo.Description)" -ForegroundColor White
        }
        
        if (-not [string]::IsNullOrEmpty($moduleInfo.LicenseUri)) {
            Write-Host "License: $($moduleInfo.LicenseUri)" -ForegroundColor White
        }
        
        if (-not [string]::IsNullOrEmpty($moduleInfo.ProjectUri)) {
            Write-Host "GitHub Page: $($moduleInfo.ProjectUri)" -ForegroundColor White
        }
        
        Write-Host "PowerShell Version Required: $($moduleInfo.PowerShellVersion)" -ForegroundColor White
        
        if ($moduleInfo.ExportedFunctions.Count -gt 0) {
            Write-Host "Exported Functions:" -ForegroundColor White
            foreach ($function in $moduleInfo.ExportedFunctions.Keys | Sort-Object) {
                Write-Host "  - $function" -ForegroundColor Gray
            }
        }
        
        if ($moduleInfo.ExportedAliases.Count -gt 0) {
            Write-Host "Exported Aliases:" -ForegroundColor White
            foreach ($alias in $moduleInfo.ExportedAliases.Keys | Sort-Object) {
                $targetName = $moduleInfo.ExportedAliases[$alias].ReferencedCommand.Name
                Write-Host "  - $alias -> $targetName" -ForegroundColor Gray
            }
        }
        
        # Show module path
        Write-Host "Module Path: $($moduleInfo.Path)" -ForegroundColor White
        
        # Display PrivateData/PSData if available
        if ($moduleInfo.PrivateData -and $moduleInfo.PrivateData.PSData) {
            $psData = $moduleInfo.PrivateData.PSData
            
            if ($psData.Tags -and $psData.Tags.Count -gt 0) {
                Write-Host "Tags: $($psData.Tags -join ", ")" -ForegroundColor White
            }
        }
        
        Write-Host ""
    } 
    else {
        Write-Error "Could not determine PowerTree information." 
    }
}