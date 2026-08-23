$ErrorActionPreference = "Stop"
$modulePath = Join-Path $PSScriptRoot "../PowerTree.psd1"
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("powertree-tests-" + [guid]::NewGuid().ToString("N"))
$fixturePath = Join-Path $testRoot "fixture"
$configPath = Join-Path $testRoot ".PowerTree/config.json"
$originalHome = $env:HOME
$originalUserProfile = $env:USERPROFILE
$passed = 0

function Assert-Match {
    param([string]$Content, [string]$Pattern, [string]$Name)

    if ($Content -notmatch $Pattern) {
        throw "$Name failed: expected '$Pattern'"
    }
    $script:passed++
}

function Assert-NotMatch {
    param([string]$Content, [string]$Pattern, [string]$Name)

    if ($Content -match $Pattern) {
        throw "$Name failed: did not expect '$Pattern'"
    }
    $script:passed++
}

function Invoke-TestTree {
    param([string]$Name, [hashtable]$Parameters = @{})

    $outputPath = Join-Path $testRoot "$Name.txt"
    Show-PowerTree -LiteralPath $fixturePath -OutFile $outputPath @Parameters *> $null
    return [System.IO.File]::ReadAllText($outputPath)
}

try {
    [void][System.IO.Directory]::CreateDirectory((Join-Path $fixturePath "alpha/empty"))
    [void][System.IO.Directory]::CreateDirectory((Join-Path $fixturePath "beta/nested"))
    [void][System.IO.Directory]::CreateDirectory((Join-Path $fixturePath "empty"))
    [System.IO.File]::WriteAllBytes((Join-Path $fixturePath "root.md"), [byte[]]::new(2))
    $hiddenFilePath = Join-Path $fixturePath ".secret.txt"
    [System.IO.File]::WriteAllBytes($hiddenFilePath, [byte[]]::new(4))
    if ($IsWindows) {
        [System.IO.File]::SetAttributes($hiddenFilePath, [System.IO.FileAttributes]::Hidden)
    }
    [System.IO.File]::WriteAllBytes((Join-Path $fixturePath "alpha/a.txt"), [byte[]]::new(1))
    [System.IO.File]::WriteAllBytes((Join-Path $fixturePath "beta/b.log"), [byte[]]::new(3))
    [System.IO.File]::WriteAllBytes((Join-Path $fixturePath "beta/nested/c.txt"), [byte[]]::new(5))

    $config = @{
        Shared = @{
            ShowConnectorLines = $true
            ShowExecutionStats = $false
            ShowConfigurations = $false
            LineStyle = "Unicode"
            OpenOutputFileOnFinish = $false
        }
        FileSystem = @{
            MaxDepth = -1
            ExcludeDirectories = @()
            HumanReadableSizes = $false
            Files = @{
                ExcludeExtensions = @()
                IncludeExtensions = @()
                FileSizeMinimum = "-1kb"
                FileSizeMaximum = "-1kb"
                FileLimit = -1
            }
            Sorting = @{
                By = "Name"
                SortFolders = $true
            }
        }
        Registry = @{
            MaxDepth = -1
            ExcludeKeys = @()
        }
    }
    [void][System.IO.Directory]::CreateDirectory((Split-Path $configPath -Parent))
    [System.IO.File]::WriteAllText($configPath, ($config | ConvertTo-Json -Depth 5))
    $env:HOME = $testRoot
    $env:USERPROFILE = $testRoot
    Import-Module $modulePath -Force

    $defaultOutput = Invoke-TestTree "default"
    Assert-Match $defaultOutput "root\.md" "default files"
    Assert-Match $defaultOutput "alpha" "default directories"
    Assert-NotMatch $defaultOutput "\.secret\.txt" "hidden files"

    $hiddenOutput = Invoke-TestTree "hidden" @{ ShowHiddenFiles = $true }
    Assert-Match $hiddenOutput "\.secret\.txt" "show hidden files"

    $depthOutput = Invoke-TestTree "depth" @{ Depth = 1 }
    Assert-Match $depthOutput "alpha" "depth directories"
    Assert-NotMatch $depthOutput "a\.txt" "depth files"

    $filteredOutput = Invoke-TestTree "filtered" @{
        IncludeExtensions = @("txt")
        PruneEmptyFolders = $true
    }
    Assert-Match $filteredOutput "a\.txt" "included extension"
    Assert-Match $filteredOutput "c\.txt" "included nested extension"
    Assert-NotMatch $filteredOutput "b\.log" "excluded extension"
    Assert-NotMatch $filteredOutput "root\.md" "non-included extension"
    Assert-NotMatch $filteredOutput "(?m)[^a-z]empty\r?$" "pruned empty directories"

    $excludedOutput = Invoke-TestTree "excluded" @{ ExcludeDirectories = @("beta") }
    Assert-NotMatch $excludedOutput "beta" "excluded directory"
    Assert-NotMatch $excludedOutput "c\.txt" "excluded subtree"

    $limitedOutput = Invoke-TestTree "limited" @{ FileLimit = 0 }
    Assert-NotMatch $limitedOutput "root\.md" "zero file limit"

    $sizeOutput = Invoke-TestTree "size" @{
        DisplaySize = $true
        SortBySize = $true
        Descending = $true
    }
    Assert-Match $sizeOutput "(?m)^8\s+.*beta\r?$" "cached folder size"
    if ($sizeOutput.IndexOf("beta") -gt $sizeOutput.IndexOf("alpha")) {
        throw "folder size sorting failed"
    }
    $passed++

    Import-Module $modulePath -Force
    $reloadOutput = Invoke-TestTree "reload" @{ Depth = 1 }
    Assert-Match $reloadOutput "root\.md" "same-session module reload"

    "Passed $passed integration assertions"
} finally {
    Remove-Module PowerTree -ErrorAction Ignore
    $env:HOME = $originalHome
    $env:USERPROFILE = $originalUserProfile
    if ($testRoot.StartsWith([System.IO.Path]::GetTempPath() + "powertree-tests-")) {
        [System.IO.Directory]::Delete($testRoot, $true)
    }
}
