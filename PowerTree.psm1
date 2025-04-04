# Define script-level variables
$script:ModuleRoot = $PSScriptRoot
New-Alias -Name "ptree" -Value "PowerTree"
New-Alias -Name "Edit-PtreeConfig" -Value "Edit-PowerTreeConfig"

# Import all private functions (recursively)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue)
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
Export-ModuleMember -Function $Public.BaseName -Alias "ptree", "Edit-PtreeConfig"