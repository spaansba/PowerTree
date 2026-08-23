$ErrorActionPreference = "Stop"
$modulePath = Join-Path $PSScriptRoot "../PowerTree.psd1"
Import-Module $modulePath -Force

Describe "configuration helpers" {
    InModuleScope PowerTree {
        It "returns and flattens default settings" {
            $defaults = Get-DefaultConfig
            $defaults.Shared.LineStyle | Should -Be "Unicode"
            $defaults.FileSystem.Sorting.By | Should -Be "Name"
            (Get-FlattenedDefaultSettings FileSystem $defaults).Files.FileLimit | Should -Be -1
            (Get-FlattenedDefaultSettings Registry $defaults).MaxDepth | Should -Be -1
        }

        It "returns local and user config candidates" {
            $paths = @(Get-ConfigPaths)
            $paths.Count | Should -Be 5
            $paths[-1] | Should -Match "\.PowerTree[/\\]config\.json$"
        }

        It "loads and merges file-system JSON settings" {
            $path = Join-Path $TestDrive "config.json"
            @{
                Shared = @{ ShowExecutionStats = $false; LineStyle = "ASCII" }
                FileSystem = @{
                    MaxDepth = 2
                    ExcludeDirectories = @("bin")
                    HumanReadableSizes = $false
                    Files = @{ IncludeExtensions = @("ps1"); FileLimit = 3 }
                    Sorting = @{ By = "Size"; SortFolders = $true }
                }
            } | ConvertTo-Json -Depth 5 | Set-Content $path
            $settings = Get-SettingsFromJson FileSystem @($path)
            $settings.LineStyle | Should -Be "ASCII"
            $settings.MaxDepth | Should -Be 2
            $settings.Files.IncludeExtensions | Should -Be @("ps1")
            $settings.Files.FileLimit | Should -Be 3
            $settings.Sorting.SortFolders | Should -BeTrue
        }

        It "uses defaults for malformed JSON" {
            $path = Join-Path $TestDrive "invalid.json"
            Set-Content $path "{invalid"
            $settings = Get-SettingsFromJson Registry @($path) -WarningAction SilentlyContinue
            $settings.MaxDepth | Should -Be -1
            $settings.LineStyle | Should -Be "Unicode"
        }

        It "initializes a missing config and preserves an existing config" {
            $originalHome = $env:HOME
            $originalUserProfile = $env:USERPROFILE
            $env:HOME = Join-Path $TestDrive "home"
            $env:USERPROFILE = $env:HOME
            try {
                Initialize-ConfigFile
                $path = Join-Path $env:HOME ".PowerTree/config.json"
                $path | Should -Exist
                Set-Content $path "sentinel"
                Initialize-ConfigFile
                (Get-Content $path -Raw).TrimEnd() | Should -Be "sentinel"
            } finally {
                $env:HOME = $originalHome
                $env:USERPROFILE = $originalUserProfile
            }
        }
    }
}

Describe "file-system output helpers" {
    InModuleScope PowerTree {
        BeforeEach {
            $script:lineStyle = Build-TreeLineStyle Unicode
            $script:header = Get-HeaderTable $false $false $false $true $false $lineStyle
        }

        It "composes headers and file output lines" {
            $path = Join-Path $TestDrive "file.txt"
            [System.IO.File]::WriteAllBytes($path, [byte[]]::new(12))
            $output = Build-OutputLine $header (Get-Item $path) "└───" $false
            $header.HeaderColumns | Should -Be @("Size", "Hierarchy")
            $output.Line | Should -Match "^12\s+└───file\.txt$"
            $output.SizeColor | Should -Be "Green"
            $output.SizePosition | Should -Be 0
        }

        It "uses recursive size for directory lines" {
            $output = Build-OutputLine $header (Get-Item $TestDrive) "└───" $false 99
            $output.Line | Should -Match "^99\s+└───"
            $output.DirSize | Should -Be 99
            $output.SizeColor | Should -BeNullOrEmpty
        }

        It "writes headers and lines to one builder" {
            $builder = [System.Text.StringBuilder]::new()
            Write-HeaderToOutput $header $builder $lineStyle
            Write-OutputLine "body" $builder
            $builder.ToString() | Should -Match "Size.*Hierarchy"
            $builder.ToString() | Should -Match "body"
        }

        It "formats tree configuration" {
            $config = [pscustomobject]@{
                SortBy = "Size"; SortDescending = $true; HeaderTable = $header
                HumanReadableSize = $true; DirectoryOnly = $false; ShowHiddenFiles = $true
                PruneEmptyFolders = $true; MaxDepth = 2; FileLimit = 4
                ExcludeDirectories = @("bin")
                ChildItemFileParams = @{ Include = @("*.ps1"); Exclude = @("*.tmp") }
                FileSizeBounds = @{ LowerBound = 1KB; UpperBound = 2KB }
            }
            $content = (Get-TreeConfigurationData $config) -join "`n"
            $content | Should -Match "Size Descending"
            $content | Should -Match "Between 1KB and 2KB"
            $content | Should -Match "\*\.ps1"
        }

        It "builds file output with configuration and stats placeholder" {
            $config = [pscustomobject]@{
                OutFile = "tree.txt"; Path = $TestDrive; SortBy = "Name"; SortDescending = $false
                HeaderTable = @{ HeaderColumns = @("Hierarchy") }; HumanReadableSize = $false
                DirectoryOnly = $false; ShowHiddenFiles = $false; PruneEmptyFolders = $false
                MaxDepth = -1; FileLimit = -1; ExcludeDirectories = @()
                ChildItemFileParams = @{}; FileSizeBounds = $null
            }
            $builder = Invoke-OutputBuilder $config $true $true
            $builder.ToString() | Should -Match "# PowerTree Output"
            $builder.ToString() | Should -Match "Sort By"
            $builder.ToString() | Should -Match "Append the stats here later!!"
            $config.OutFile = ""
            Invoke-OutputBuilder $config | Should -BeNullOrEmpty
        }

        It "replaces the tree stats placeholder" {
            $stats = [TreeStats]::new()
            $stats.FilesPrinted = 2
            $stats.FoldersPrinted = 1
            $stats.TotalSize = 12
            $builder = [System.Text.StringBuilder]::new("Append the stats here later!!")
            Show-TreeStats $stats ([timespan]::FromMilliseconds(10)) $builder $lineStyle
            $builder.ToString() | Should -Match "Files\s+Folders"
            $builder.ToString() | Should -Match "2\s+1\s+3"
            $builder.ToString() | Should -Not -Match "Append the stats"
        }

        It "writes piped content and creates parent folders" {
            $path = Join-Path $TestDrive "nested/output.txt"
            @("first", "second") | Write-ToFile -FilePath $path -OpenOutputFileOnFinish $false
            Get-Content $path | Should -Be @("first", "second")
        }

        It "dispatches host configuration formatting" {
            Mock Write-Host
            Mock Get-TreeConfigurationData { @("setting") }
            Write-ConfigurationToHost ([pscustomobject]@{ OutFile = ""; HeaderTable = @{} })
            Should -Invoke Get-TreeConfigurationData -Times 1
            Should -Invoke Write-Host -ParameterFilter { $Object -eq "Configuration" } -Times 1
        }

        It "prints help and examples" {
            Mock Write-Host
            Set-Item Function:Write-CheckForUpdates {}
            Mock Write-CheckForUpdates
            Write-Examples
            Write-Help
            Should -Invoke Write-Host -ParameterFilter { $Object -eq "EXAMPLES:" } -Times 1
            Should -Invoke Write-Host -ParameterFilter { $Object -eq "BASIC OPTIONS:" } -Times 1
            Should -Invoke Write-CheckForUpdates -Times 1
        }
    }
}

Describe "Edit-PowerTreeConfig" {
    InModuleScope PowerTree {
        It "creates the default config and opens it" {
            $originalHome = $env:HOME
            $originalUserProfile = $env:USERPROFILE
            $env:HOME = Join-Path $TestDrive "editor-home"
            $env:USERPROFILE = $env:HOME
            Mock Get-ConfigPaths { @() }
            Mock Start-Process
            try {
                Edit-PowerTreeConfig
                $path = Join-Path $env:HOME ".PowerTree/config.json"
                $path | Should -Exist
                (Get-Content $path -Raw | ConvertFrom-Json).Shared.LineStyle | Should -Be "Unicode"
                Should -Invoke Start-Process -Times 1
            } finally {
                $env:HOME = $originalHome
                $env:USERPROFILE = $originalUserProfile
            }
        }
    }
}
