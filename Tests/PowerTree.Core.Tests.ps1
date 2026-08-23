$ErrorActionPreference = "Stop"
$modulePath = Join-Path $PSScriptRoot "../PowerTree.psd1"
Import-Module $modulePath -Force

Describe "PowerTree module" {
    It "exports every public command and primary alias" {
        (Get-Command Show-PowerTree).CommandType | Should -Be "Function"
        (Get-Command Show-PowerTreeRegistry).CommandType | Should -Be "Function"
        (Get-Command Edit-PowerTreeConfig).CommandType | Should -Be "Function"
        (Get-Alias ptree).Definition | Should -Be "Show-PowerTree"
        (Get-Alias ptreer).Definition | Should -Be "Show-PowerTreeRegistry"
    }

    It "loads every declared script function" {
        $declared = Get-ChildItem (Join-Path $PSScriptRoot "../Public"), (Join-Path $PSScriptRoot "../Private") -Filter "*.ps1" -Recurse |
            Where-Object Name -ne "Classes.ps1" |
            ForEach-Object {
                [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$null).
                    FindAll({ param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true).Name
            } | Sort-Object -Unique
        $loaded = & (Get-Module PowerTree) { (Get-Command -CommandType Function).Name }
        $declared | ForEach-Object { $_ | Should -BeIn $loaded }
    }
}

Describe "data models" {
    InModuleScope PowerTree {
        It "tracks file and folder statistics" {
            $path = Join-Path $TestDrive "large.bin"
            [System.IO.File]::WriteAllBytes($path, [byte[]]::new(12))
            $stats = [TreeStats]::new()
            $stats.AddFile((Get-Item $path))
            $stats.UpdateLargestFolder("folder", 20)
            $stats.UpdateLargestFolder("smaller", 10)
            $stats.UpdateMaxDepth(3)
            $stats.UpdateMaxDepth(2)
            $stats.FilesPrinted | Should -Be 1
            $stats.TotalSize | Should -Be 12
            $stats.LargestFile.Name | Should -Be "large.bin"
            $stats.LargestFolder | Should -Be "folder"
            $stats.MaxDepth | Should -Be 3
        }

        It "tracks registry depth" {
            $stats = [RegistryStats]::new()
            $stats.UpdateDepth(4)
            $stats.UpdateDepth(2)
            $stats.MaxDepthReached | Should -Be 4
        }

        It "initializes tree nodes" {
            $directory = [System.IO.DirectoryInfo]::new($TestDrive)
            $node = [TreeNode]::new($directory, 2)
            $node.Item.FullName | Should -Be $directory.FullName
            $node.Depth | Should -Be 2
            $node.Files.Count | Should -Be 0
        }
    }
}

Describe "formatting helpers" {
    InModuleScope PowerTree {
        It "builds ASCII and Unicode tree styles" {
            (Build-TreeLineStyle ASCII).Branch | Should -Be "+----"
            (Build-TreeLineStyle Unicode).LastBranch | Should -Be "└───"
        }

        It "normalizes file extensions" {
            @(Format-FileExtensions @(" PS1 ", ".MD", "*.JSON", "*txt", " ")) |
                Should -Be @("*.ps1", "*.md", "*.json", "*.txt")
        }

        It "converts supported byte sizes" {
            ConvertTo-Bytes "1.5kb" | Should -Be 1536
            ConvertTo-Bytes "2 MB" | Should -Be 2MB
            ConvertTo-Bytes "1,5kb" | Should -Be 1536
            ConvertTo-Bytes "42" | Should -Be 42
            ConvertTo-Bytes "-1kb" | Should -Be -1
            ConvertTo-Bytes $null | Should -Be -1
        }

        It "rejects invalid byte sizes" {
            ConvertTo-Bytes "large" -WarningVariable warning | Should -Be -1
            $warning.Message | Should -Match "Invalid size format"
        }

        It "formats byte sizes" {
            Get-HumanReadableSize 1536 Compact | Should -Match "^1[.,]5KB$"
            (Get-HumanReadableSize 1536 Padded).Length | Should -Be 10
            Get-HumanReadableSize 1TB Compact | Should -Be "1TB"
        }

        It "selects colors at every size boundary" {
            Get-SizeColor 1 | Should -Be "Green"
            Get-SizeColor 100KB | Should -Be "Cyan"
            Get-SizeColor 1MB | Should -Be "Blue"
            Get-SizeColor 10MB | Should -Be "DarkYellow"
            Get-SizeColor 100MB | Should -Be "Red"
        }

        It "formats execution durations" {
            Format-ExecutionTime ([timespan]::FromMilliseconds(250)) | Should -Match "250.*ms"
            Format-ExecutionTime ([timespan]::FromSeconds(2.5)) | Should -Match "^2[.,]50 sec$"
            Format-ExecutionTime ([timespan]::FromSeconds(65)) | Should -Be "1 min, 5 sec"
        }

        It "adds a default extension only when needed" {
            Add-DefaultExtension "report" $false | Should -Be "report.txt"
            Add-DefaultExtension "report.md" $false | Should -Be "report.md"
            Add-DefaultExtension "" $true | Should -Be ""
        }
    }
}

Describe "parameter builders" {
    InModuleScope PowerTree {
        It "merges configured and command-line directory exclusions" {
            $result = @(Build-ExcludedDirectoryParams @("obj", "node_modules") @{ ExcludeDirectories = @("bin", "obj") })
            $result | Should -Be @("bin", "obj", "node_modules")
        }

        It "prefers command-line file filters and includes hidden files" {
            $settings = @{ IncludeExtensions = @("json"); ExcludeExtensions = @("tmp") }
            $result = Build-ChildItemFileParams $true @("ps1") @() $settings
            $result.File | Should -BeTrue
            $result.Force | Should -BeTrue
            $result.Include | Should -Be @("*.ps1")
            $result.Exclude | Should -Be @("*.tmp")
        }

        It "combines converted command-line and configured file-size bounds" {
            $result = Build-FileSizeParams $null "2kb" "8kb" "1kb"
            $result.LowerBound | Should -Be 2KB
            $result.UpperBound | Should -Be 8KB
            $result.ShouldFilter | Should -BeTrue
            (Build-FileSizeParams "-1kb" "-1kb" "-1kb" "-1kb").ShouldFilter | Should -BeFalse
        }
    }
}

Describe "sorting helpers" {
    InModuleScope PowerTree {
        It "resolves consolidated, switch, and default sorting" {
            Get-SortingMethod -Sort size -DefaultSort Name | Should -Be "Size"
            Get-SortingMethod -SortByCreationDate $true -DefaultSort Name | Should -Be "Creation Date"
            Get-SortingMethod -DefaultSort "Modification Date" | Should -Be "Modification Date"
        }
    }
}
