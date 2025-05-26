# Define script-level variables
$script:ModuleRoot = $PSScriptRoot
New-Alias -Name "ptree" -Value "Show-PowerTree"
New-Alias -Name "PowerTree" -Value "Show-PowerTree"
New-Alias -Name "Start-PowerTree" -Value "Show-PowerTree"
New-Alias -Name "Edit-PtreeConfig" -Value "Edit-PowerTreeConfig"
New-Alias -Name "Edit-Ptree" -Value "Edit-PowerTreeConfig"
New-Alias -Name "Edit-PowerTree" -Value "Edit-PowerTreeConfig"
New-Alias -Name "ptreer" -Value "Show-PowerTreeRegistry"
New-Alias -Name "PowerRegistry" -Value "Show-PowerTreeRegistry"

# Import classes first to ensure they are available to all functions
$ClassFiles = @(Get-ChildItem -Path "$PSScriptRoot\Private\Shared\DataModel\Classes.ps1" -ErrorAction SilentlyContinue)
foreach ($import in $ClassFiles) {
    try {
        . $import.FullName
        Write-Verbose "Imported class definitions from $($import.FullName)"
    }
    catch {
        Write-Error "Failed to import class definitions from $($import.FullName): $_"
    }
}

# Import all remaining private functions (recursively)
$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue | 
             Where-Object { $_.FullName -ne "$PSScriptRoot\Private\Shared\DataModel\Classes.ps1" })
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