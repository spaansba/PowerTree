# Install-Fixed-PowerTree.ps1
# This script installs the fixed version of PowerTree that works in both PowerShell 5+ and 7+
# and handles a variety of file size formats including spaces between numbers and units

# Ensure we're running with administrative privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning "This script needs to be run as Administrator to install the module properly."
    Write-Host "Please restart PowerShell as Administrator and run this script again."
    return
}

# Define variables
$ModuleName = "PowerTree"
$ModuleVersion = "1.1.0"
$SourcePath = $PSScriptRoot
$BackupFolder = Join-Path -Path $SourcePath -ChildPath "Backup-$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Create backup folder
New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null
Write-Host "Created backup folder: $BackupFolder" -ForegroundColor Cyan

# Backup original files
Write-Host "Backing up original files..." -ForegroundColor Cyan
Copy-Item -Path "$SourcePath\Public\PowerTree.ps1" -Destination "$BackupFolder\PowerTree.ps1" -Force
Copy-Item -Path "$SourcePath\Private\Size\GetHumanReadableSize.ps1" -Destination "$BackupFolder\GetHumanReadableSize.ps1" -Force
if (Test-Path "$SourcePath\Private\Size\Conversion\ConvertToBytes.ps1") {
    Copy-Item -Path "$SourcePath\Private\Size\Conversion\ConvertToBytes.ps1" -Destination "$BackupFolder\ConvertToBytes.ps1" -Force
}
Copy-Item -Path "$SourcePath\Private\Configuration\ParamHelpers\BuildFileSizeParam.ps1" -Destination "$BackupFolder\BuildFileSizeParam.ps1" -Force

# Apply fixes
Write-Host "Applying fixes..." -ForegroundColor Green

# 1. Replace PowerTree.ps1 with fixed version
Copy-Item -Path "$SourcePath\Public\PowerTree-Fixed.ps1" -Destination "$SourcePath\Public\PowerTree.ps1" -Force
Write-Host "  ✓ Updated PowerTree.ps1 to handle spaces in file size specifications" -ForegroundColor Green

# 2. Fix the GetHumanReadableSize.ps1 function to not use semicolons
$humanReadableContent = Get-Content -Path "$SourcePath\Private\Size\GetHumanReadableSize.ps1" -Raw
$fixedHumanReadableContent = $humanReadableContent -replace '\$formattedValue = \$formattedValue\.Replace\("\."\, ";\"\)', '# $formattedValue = $formattedValue.Replace(".", ";") # Commented to fix display issues'
Set-Content -Path "$SourcePath\Private\Size\GetHumanReadableSize.ps1" -Value $fixedHumanReadableContent
Write-Host "  ✓ Fixed GetHumanReadableSize.ps1 to display proper decimal points" -ForegroundColor Green

# 3. Ensure Conversion directory exists
if (-not (Test-Path "$SourcePath\Private\Size\Conversion")) {
    New-Item -Path "$SourcePath\Private\Size\Conversion" -ItemType Directory -Force | Out-Null
}

# 4. Copy fixed ConvertToBytes functions
Copy-Item -Path "$SourcePath\Private\Size\Conversion\ConvertToBytes-Fixed.ps1" -Destination "$SourcePath\Private\Size\Conversion\ConvertToBytes.ps1" -Force
Write-Host "  ✓ Installed ConvertToBytes.ps1 for proper file size conversions" -ForegroundColor Green

# 5. Fix BuildFileSizeParam.ps1 to use string parameters instead of long
$buildFileSizeContent = Get-Content -Path "$SourcePath\Private\Configuration\ParamHelpers\BuildFileSizeParam.ps1" -Raw
$fixedBuildFileSizeContent = $buildFileSizeContent -replace 'function Build-FileSizeParams \{\s+param \(\s+\[long\]\$CommandLineMaxSize,\s+\[long\]\$CommandLineMinSize,\s+\[long\]\$SettingsLineMaxSize,\s+\[long\]\$SettingsLineMinSize\s+\)', @'
function Build-FileSizeParams {
    param (
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [string]$CommandLineMaxSize,
        
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [string]$CommandLineMinSize,
        
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [string]$SettingsLineMaxSize,
        
        [Parameter(Mandatory=$false)]
        [AllowNull()]
        [string]$SettingsLineMinSize
    )
    
    # Convert string values to bytes
    $cmdMaxBytes = ConvertTo-Bytes -SizeString $CommandLineMaxSize
    $cmdMinBytes = ConvertTo-Bytes -SizeString $CommandLineMinSize
    $settingsMaxBytes = ConvertTo-Bytes -SizeString $SettingsLineMaxSize
    $settingsMinBytes = ConvertTo-Bytes -SizeString $SettingsLineMinSize
'@

$fix