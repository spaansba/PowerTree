$ErrorActionPreference = "Stop"
$modulePath = Join-Path $PSScriptRoot "../PowerTree.psd1"
Import-Module $modulePath -Force

Describe "file-system traversal" {
    InModuleScope PowerTree {
        BeforeAll {
            $script:fixture = Join-Path $TestDrive "fixture"
            [void][System.IO.Directory]::CreateDirectory((Join-Path $fixture "alpha/nested"))
            [void][System.IO.Directory]::CreateDirectory((Join-Path $fixture "beta"))
            [void][System.IO.Directory]::CreateDirectory((Join-Path $fixture "empty"))
            [System.IO.File]::WriteAllBytes((Join-Path $fixture "root.txt"), [byte[]]::new(4))
            [System.IO.File]::WriteAllBytes((Join-Path $fixture "root.log"), [byte[]]::new(8))
            [System.IO.File]::WriteAllBytes((Join-Path $fixture "alpha/small.txt"), [byte[]]::new(1))
            [System.IO.File]::WriteAllBytes((Join-Path $fixture "alpha/large.txt"), [byte[]]::new(6))
            [System.IO.File]::WriteAllBytes((Join-Path $fixture "alpha/nested/deep.txt"), [byte[]]::new(3))
            [System.IO.File]::WriteAllBytes((Join-Path $fixture "beta/ignored.txt"), [byte[]]::new(10))
        }

        BeforeEach {
            $script:lineStyle = Build-TreeLineStyle Unicode
            $script:header = Get-HeaderTable -DisplayCreationDate $false -DisplayLastAccessDate $false `
                -DisplayModificationDate $false -DisplaySize $true -DisplayMode $false -LineStyle $lineStyle
            $script:config = [pscustomobject]@{
                Path = $fixture
                DirectoryOnly = $false
                ExcludeDirectories = @()
                SortBy = "Name"
                SortDescending = $false
                SortFolders = $true
                HeaderTable = $header
                ShowConnectorLines = $true
                ShowHiddenFiles = $true
                MaxDepth = -1
                FileSizeBounds = @{ LowerBound = -1; UpperBound = -1; ShouldFilter = $false }
                FileLimit = -1
                PruneEmptyFolders = $false
                LineStyle = $lineStyle
                HumanReadableSizes = $false
            }
        }

        It "scans, filters, limits, and sorts one snapshot" {
            $config.ExcludeDirectories = @("beta")
            $config.SortBy = "Size"
            $config.SortDescending = $true
            $config.FileLimit = 1
            $config.FileSizeBounds = @{ LowerBound = 2; UpperBound = 8; ShouldFilter = $true }
            $params = Build-ChildItemFileParams -ShowHiddenFiles $true -CommandLineIncludeExt @("txt")

            $snapshot = Get-TreeSnapshot -TreeConfig $config -ChildItemFileParams $params
            $alpha = $snapshot.Directories | Where-Object { $_.Item.Name -eq "alpha" }
            $beta = $snapshot.Directories | Where-Object { $_.Item.Name -eq "beta" }

            $snapshot.Files.Name | Should -Be @("root.txt")
            $alpha.Files.Name | Should -Be @("large.txt")
            $alpha.Size | Should -Be 10
            $beta.IsVisible | Should -BeFalse
            $snapshot.Size | Should -Be 32
        }

        It "prunes empty directories when snapshot and writer are composed" {
            $config.PruneEmptyFolders = $true
            $params = Build-ChildItemFileParams -ShowHiddenFiles $true -CommandLineIncludeExt @("txt")
            $snapshot = Get-TreeSnapshot -TreeConfig $config -ChildItemFileParams $params
            $stats = [TreeStats]::new()
            $builder = [System.Text.StringBuilder]::new()

            Write-TreeSnapshot -Node $snapshot -TreeConfig $config -TreeStats $stats -OutputBuilder $builder

            $builder.ToString() | Should -Match "root\.txt"
            $builder.ToString() | Should -Match "deep\.txt"
            $builder.ToString() | Should -Not -Match "(?m)empty$"
            $stats.FilesPrinted | Should -Be 5
            $stats.FoldersPrinted | Should -Be 3
            $stats.TotalSize | Should -Be 24
            $stats.MaxDepth | Should -Be 2
        }

        It "honors directory-only and depth together" {
            $config.DirectoryOnly = $true
            $config.MaxDepth = 1
            $config.HeaderTable = Get-HeaderTable -DisplayCreationDate $false -DisplayLastAccessDate $false `
                -DisplayModificationDate $false -DisplaySize $false -DisplayMode $false -LineStyle $lineStyle
            $stats = [TreeStats]::new()
            $builder = [System.Text.StringBuilder]::new()

            Get-TreeView -TreeConfig $config -ChildItemFileParams @{ File = $true } `
                -TreeStats $stats -OutputBuilder $builder

            $builder.ToString() | Should -Match "alpha"
            $builder.ToString() | Should -Match "beta"
            $builder.ToString() | Should -Not -Match "nested"
            $builder.ToString() | Should -Not -Match "root\.txt"
            $stats.FilesPrinted | Should -Be 0
        }

        It "sorts folders by their cached recursive size" {
            $config.SortBy = "Size"
            $config.SortDescending = $true
            $snapshot = Get-TreeSnapshot -TreeConfig $config -ChildItemFileParams @{ File = $true }
            @($snapshot.Directories | ForEach-Object { $_.Item.Name }) | Should -Be @("beta", "alpha", "empty")
        }
    }
}

Describe "Show-PowerTree combinations" {
    BeforeEach {
        $script:fixture = Join-Path $TestDrive "public-fixture"
        $script:homePath = Join-Path $TestDrive "home"
        [void][System.IO.Directory]::CreateDirectory((Join-Path $fixture "src/empty"))
        [void][System.IO.Directory]::CreateDirectory((Join-Path $fixture "logs"))
        [System.IO.File]::WriteAllBytes((Join-Path $fixture "src/a.ps1"), [byte[]]::new(4))
        [System.IO.File]::WriteAllBytes((Join-Path $fixture "src/b.txt"), [byte[]]::new(2))
        [System.IO.File]::WriteAllBytes((Join-Path $fixture "logs/app.log"), [byte[]]::new(8))
        [void][System.IO.Directory]::CreateDirectory((Join-Path $homePath ".PowerTree"))
        $script:configPath = Join-Path $homePath ".PowerTree/config.json"
        @{
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
                Sorting = @{ By = "Name"; SortFolders = $true }
            }
            Registry = @{ MaxDepth = -1; ExcludeKeys = @() }
        } | ConvertTo-Json -Depth 5 | Set-Content $configPath
        $script:originalHome = $env:HOME
        $script:originalUserProfile = $env:USERPROFILE
        $env:HOME = $homePath
        $env:USERPROFILE = $homePath
    }

    AfterEach {
        $env:HOME = $originalHome
        $env:USERPROFILE = $originalUserProfile
    }

    It "combines extension filters, pruning, size display, sorting, and output" {
        $outputPath = Join-Path $TestDrive "result"
        Show-PowerTree -LiteralPath $fixture -IncludeExtensions @("ps1", "txt") `
            -PruneEmptyFolders -DisplaySize -SortBySize -Descending -OutFile $outputPath *> $null

        $savedPath = "$outputPath.txt"
        $content = [System.IO.File]::ReadAllText($savedPath)
        $content | Should -Match "a\.ps1"
        $content | Should -Match "b\.txt"
        $content | Should -Not -Match "app\.log"
        $content | Should -Not -Match "(?m)empty$"
        $content | Should -Match "(?m)^6\s+.*src$"
    }

    It "combines directory exclusion, depth, and a zero file limit" {
        $outputPath = Join-Path $TestDrive "limited.txt"
        Show-PowerTree -LiteralPath $fixture -ExcludeDirectories @("logs") -Depth 1 `
            -FileLimit 0 -OutFile $outputPath *> $null

        $content = [System.IO.File]::ReadAllText($outputPath)
        $content | Should -Match "src"
        $content | Should -Not -Match "logs"
        $content | Should -Not -Match "a\.ps1"
        $content | Should -Not -Match "b\.txt"
    }
}
