# Define script-level variables
$script:ModuleRoot = $PSScriptRoot
Set-Alias -Name "ptree" -Value "Show-PowerTree"
Set-Alias -Name "PowerTree" -Value "Show-PowerTree"
Set-Alias -Name "Start-PowerTree" -Value "Show-PowerTree"
Set-Alias -Name "Edit-PtreeConfig" -Value "Edit-PowerTreeConfig"
Set-Alias -Name "Edit-Ptree" -Value "Edit-PowerTreeConfig"
Set-Alias -Name "Edit-PowerTree" -Value "Edit-PowerTreeConfig"
Set-Alias -Name "ptreer" -Value "Show-PowerTreeRegistry"
Set-Alias -Name "PowerRegistry" -Value "Show-PowerTreeRegistry"

$classPath = Join-Path $PSScriptRoot "Private/Shared/DataModel/Classes.ps1"
try {
    . $classPath
} catch {
    Write-Error "Failed to import class definitions from $classPath`: $_"
}

# Import all remaining private functions (recursively)
$Private = @(Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -ne $classPath })
foreach ($import in $Private) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import private function $($import.FullName): $_"
    }
}

# Import all public functions
$Public = @(Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue)
foreach ($import in $Public) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error "Failed to import public function $($import.FullName): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $Public.BaseName
Export-ModuleMember -Function $Public.BaseName -Alias "ptree", "PowerTree", "Start-PowerTree", "Edit-PtreeConfig", "Edit-Ptree", "Edit-PowerTree", "ptreer", "PowerRegistry"
