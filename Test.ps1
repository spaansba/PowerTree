# Get the script's directory
$ScriptRoot = $PSScriptRoot
Write-Host "Script root path: $ScriptRoot" -ForegroundColor Cyan

# First load all the private functions
Write-Host "Loading private functions..." -ForegroundColor Yellow
$privateFunctionsPath = Join-Path -Path $ScriptRoot -ChildPath "Private"
if (Test-Path -Path $privateFunctionsPath) {
    # Get all PS1 files from the Private directory and its subdirectories
    $privateFiles = Get-ChildItem -Path $privateFunctionsPath -Filter "*.ps1" -Recurse
    
    # Sort files to ensure dependencies are loaded in the right order
    # Files in DataModel should come first, then Configuration, etc.
    $orderedFiles = $privateFiles | Sort-Object -Property {
        $priority = switch -Regex ($_.DirectoryName) {
            '\\DataModel$' { 1 }
            '\\Configuration$' { 2 }
            '\\Filtering$' { 3 }
            '\\Size$' { 4 }
            '\\Output$' { 5 }
            '\\Sorting$' { 6 }
            default { 100 } # Other directories come last
        }
        return $priority
    }
    
    # Dot source each file
    foreach ($file in $orderedFiles) {
        try {
            . $file.FullName
            Write-Verbose "Loaded: $($file.FullName)"
        }
        catch {
            Write-Warning "Failed to load: $($file.FullName). Error: $_"
        }
    }
} else {
    Write-Warning "Private functions directory not found: $privateFunctionsPath"
}

# Load the public functions
Write-Host "Loading public functions..." -ForegroundColor Yellow
$publicFunctionsPath = Join-Path -Path $ScriptRoot -ChildPath "Public"
if (Test-Path -Path $publicFunctionsPath) {
    $publicFiles = Get-ChildItem -Path $publicFunctionsPath -Filter "*.ps1"
    foreach ($file in $publicFiles) {
        try {
            . $file.FullName
            Write-Verbose "Loaded: $($file.FullName)"
        }
        catch {
            Write-Warning "Failed to load: $($file.FullName). Error: $_"
        }
    }
} else {
    Write-Warning "Public functions directory not found: $publicFunctionsPath"
}

# Create a new alias for this test session
if (Get-Command -Name "PowerTree" -ErrorAction SilentlyContinue) {
    New-Alias -Name "ptree" -Value "PowerTree" -Scope Script -Force
    
    # Run PowerTree with all arguments
    Write-Host "Running PowerTree with arguments: $args" -ForegroundColor Yellow
    & PowerTree @args
} else {
    Write-Error "PowerTree function not found. Cannot continue."
}

Write-Host "`nTesting complete!" -ForegroundColor Green