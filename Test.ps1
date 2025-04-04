# Get the script's directory
$ScriptRoot = $PSScriptRoot
Write-Host "Script root path: $ScriptRoot" -ForegroundColor Cyan

# First, let's load all functions in order
$PrivateFiles = @(
    # Data model
    "$ScriptRoot\Private\DataModel\Classes.ps1",
    
    # Configuration
    "$ScriptRoot\Private\Configuration\Constants.ps1",
    "$ScriptRoot\Private\Configuration\GetSettingsFromJson.ps1",
    "$ScriptRoot\Private\Configuration\ParamHelpers.ps1",
    "$ScriptRoot\Private\Configuration\WriteConfiguration.ps1",
    
    # Filtering
    "$ScriptRoot\Private\Filtering\FilterHelpers.ps1",
    "$ScriptRoot\Private\Filtering\SizeHelpers.ps1",
    
    # Output
    "$ScriptRoot\Private\Output\Help.ps1",
    "$ScriptRoot\Private\Output\HeaderTable.ps1",
    "$ScriptRoot\Private\Output\WriteToFile.ps1",
    "$ScriptRoot\Private\Output\GetTreeView.ps1",
    
    # Sorting
    "$ScriptRoot\Private\Sorting\Sorting.ps1"
)

# Source each file in the correct order
foreach ($file in $PrivateFiles) {
    if (Test-Path $file) {
        . $file
        Write-Verbose "Loaded: $file"
    } else {
        Write-Warning "Could not find: $file"
    }
}

# Load the main function last
. "$ScriptRoot\Public\PowerTree.ps1"

# Create a new alias for this test session
New-Alias -Name "ptree" -Value "PowerTree" -Scope Script

# Run PowerTree with all arguments
Write-Host "Running PowerTree with arguments: $args" -ForegroundColor Yellow
& PowerTree @args

Write-Host "`nTesting complete!" -ForegroundColor Green