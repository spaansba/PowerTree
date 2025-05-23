$script:ModuleRoot = $PSScriptRoot

# Import classes first to ensure they are available to all functions
$ClassFiles = @(Get-ChildItem -Path "$PSScriptRoot\Private\DataModel\Classes.ps1" -ErrorAction SilentlyContinue)
foreach ($import in $ClassFiles) {
    try {
        . $import.FullName
        Write-Verbose "Imported class definitions from $($import.FullName)"
    }
    catch {
        Write-Error "Failed to import class definitions from $($import.FullName): $_"
    }
}

$Private = @(Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -Recurse -ErrorAction SilentlyContinue | 
             Where-Object { $_.FullName -ne "$PSScriptRoot\Private\DataModel\Classes.ps1" })
foreach ($import in $Private) {
    try {
        . $import.FullName
        Write-Verbose "Imported private function from $($import.FullName)"
    }
    catch {
        Write-Error "Failed to import private function $($import.FullName): $_"
    }
}

$Public = @(Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue)
foreach ($import in $Public) {
    try {
        . $import.FullName
        Write-Verbose "Imported public function from $($import.FullName)"
    }
    catch {
        Write-Error "Failed to import public function $($import.FullName): $_"
    }
}

$Aliases = @{
    'ptree' = 'Show-PowerTree'
    'Start-PowerTree' = 'Show-PowerTree'
    'PowerTree' = 'Show-PowerTree'
    'Edit-PtreeConfig' = 'Edit-PowerTreeConfig'
    'Edit-Ptree' = 'Edit-PowerTreeConfig'
    'Edit-PowerTree' = 'Edit-PowerTreeConfig'
    'ptreer' = 'Show-PowerTreeRegistry'
}

foreach ($alias in $Aliases.GetEnumerator()) {
    New-Alias -Name $alias.Key -Value $alias.Value -Force
}

Export-ModuleMember -Function $Public.BaseName -Alias $Aliases.Keys