$ErrorActionPreference = "Stop"
$modulePath = Join-Path $PSScriptRoot "../PowerTree.psd1"
Import-Module $modulePath -Force

Describe "registry filtering and output" {
    InModuleScope PowerTree {
        It "matches wildcard filters and handles empty patterns" {
            Test-FilterMatch -ItemName "PowerTree" -Patterns @("Power*") | Should -BeTrue
            Test-FilterMatch -ItemName "PowerTree" -Patterns @("Other*") | Should -BeFalse
            Test-FilterMatch -ItemName "PowerTree" -Patterns @() | Should -BeFalse
        }

        It "resets flags and marks only the final item" {
            $items = @(
                [pscustomobject]@{ Name = "a"; IsLast = $true },
                [pscustomobject]@{ Name = "b"; IsLast = $false }
            )
            $result = @(Set-LastItemFlag $items)
            $result[0].IsLast | Should -BeFalse
            $result[1].IsLast | Should -BeTrue
        }

        It "sorts default values, named values, and keys together" {
            $values = @(
                [pscustomobject]@{ TypeName = "String"; Name = "z" },
                [pscustomobject]@{ TypeName = "String"; Name = "(Default)" },
                [pscustomobject]@{ TypeName = "DWord"; Name = "a" }
            )
            $keys = @(
                [pscustomobject]@{ TypeName = "Key"; Name = "Beta" },
                [pscustomobject]@{ TypeName = "Key"; Name = "Alpha" }
            )

            @(Invoke-RegistryItemSorting $values $keys $false $false).Name |
                Should -Be @("(Default)", "a", "z", "Alpha", "Beta")
            @(Invoke-RegistryItemSorting $values $keys $true $false).TypeName |
                Should -Be @("DWord", "Key", "Key", "String", "String")
        }

        It "formats registry configuration" {
            $config = [pscustomobject]@{
                SortValuesByType = $true
                SortDescending = $true
                UseRegistryDataTypes = $true
                NoValues = $true
                DisplayItemCounts = $true
                MaxDepth = 2
                Include = @("Name*")
                Exclude = @("Secret*")
            }
            $content = (Get-RegistryConfigurationData $config) -join "`n"
            $content | Should -Match "Type Descending"
            $content | Should -Match "REG_SZ"
            $content | Should -Match "Name\*"
            $content | Should -Match "Secret\*"
        }

        It "builds registry output and replaces its stats placeholder" {
            $lineStyle = Build-TreeLineStyle Unicode
            $config = [pscustomobject]@{
                Path = "HKCU:\Software"
                LineStyle = $lineStyle
                SortValuesByType = $false
                SortDescending = $false
                UseRegistryDataTypes = $false
                NoValues = $false
                DisplayItemCounts = $false
                MaxDepth = -1
                Include = @()
                Exclude = @()
            }
            $builder = Invoke-OutputBuilderRegistry -TreeRegistryConfig $config `
                -ShowExecutionStats $true -ShowConfigurations $true
            $stats = [RegistryStats]::new()
            $stats.KeysProcessed = 2
            $stats.ValuesProcessed = 3
            $stats.UpdateDepth(2)

            Show-RegistryStats -RegistryStats $stats -ExecutionTime ([timespan]::FromSeconds(1)) `
                -LineStyle $lineStyle -OutputBuilder $builder

            $builder.ToString() | Should -Match "# PowerTreeRegistry Output"
            $builder.ToString() | Should -Match "Configuration:"
            $builder.ToString() | Should -Match "2\s+3\s+5"
            $builder.ToString() | Should -Not -Match "Append the stats"
        }
    }
}

Describe "Windows registry traversal" -Skip:(-not $IsWindows) {
    InModuleScope PowerTree {
        BeforeAll {
            $script:keyName = "PowerTreeTests-" + [guid]::NewGuid().ToString("N")
            $script:registryPath = "HKCU:\Software\$keyName"
            [void](New-Item -Path $registryPath -Force)
            [void](New-Item -Path "$registryPath\Alpha" -Force)
            [void](New-Item -Path "$registryPath\Excluded" -Force)
            New-ItemProperty -Path $registryPath -Name "Name" -Value "PowerTree" -PropertyType String -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name "Number" -Value 42 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $registryPath -Name "SecretValue" -Value "hidden" -PropertyType String -Force | Out-Null
            New-ItemProperty -Path "$registryPath\Alpha" -Name "ChildValue" -Value "child" -PropertyType String -Force | Out-Null
        }

        AfterAll {
            if ($registryPath -match '^HKCU:\\Software\\PowerTreeTests-[a-f0-9]{32}$') {
                Remove-Item -LiteralPath $registryPath -Recurse -Force
            }
        }

        It "normalizes and validates a registry path" {
            $fullPath = "HKEY_CURRENT_USER\Software\$keyName"
            Get-Path $fullPath | Should -Be $registryPath
        }

        It "processes child keys with exclusions and item counts" {
            $keys = @(Get-ProcessedRegistryKeys -RegistryPath $registryPath -Exclude @("Excluded") `
                -HasKeyFilters $true -DisplayItemCounts $true)
            $keys.Count | Should -Be 1
            $keys[0].Name | Should -Be "Alpha"
            $keys[0].ValueCount | Should -Be 1
            $keys[0].SubKeyCount | Should -Be 0
        }

        It "processes values with filters and registry data type names" {
            $regKey = Get-Item -LiteralPath $registryPath
            $typeMap = @{ String = "REG_SZ"; DWord = "REG_DWORD" }
            $values = @(Get-ProcessedRegistryValues -RegKey $regKey -RegistryTypeMap $typeMap `
                -UseRegistryDataTypes $true -Include @("N*") -Exclude @("Secret*") -HasValueFilters $true)

            $values.Name | Should -Be @("Name", "Number")
            $values.TypeName | Should -Be @("REG_SZ", "REG_DWORD")
        }

        It "composes values, child keys, sorting, filtering, and last flags" {
            $items = @(Get-RegistryItems -RegistryPath $registryPath -DisplayItemCounts $true `
                -SortValuesByType $false -UseRegistryDataTypes $false -Exclude @("Secret*", "Excluded"))

            $items.Name | Should -Contain "Name"
            $items.Name | Should -Contain "Number"
            $items.Name | Should -Contain "Alpha"
            $items.Name | Should -Not -Contain "SecretValue"
            $items.Name | Should -Not -Contain "Excluded"
            @($items | Where-Object IsLast).Count | Should -Be 1
            $items[-1].IsLast | Should -BeTrue
        }

        It "renders a recursive registry tree into a collection" {
            $config = [pscustomobject]@{
                Path = $registryPath
                NoValues = $false
                Exclude = @("Secret*", "Excluded")
                Include = @()
                MaxDepth = -1
                LineStyle = Build-TreeLineStyle Unicode
                DisplayItemCounts = $true
                SortValuesByType = $false
                SortDescending = $false
                UseRegistryDataTypes = $false
            }
            $output = [System.Collections.Generic.List[string]]::new()
            $stats = Get-TreeRegistryView -TreeRegistryConfig $config -OutputCollection $output

            $output -join "`n" | Should -Match "Type\s+Hierarchy"
            $output -join "`n" | Should -Match "Alpha"
            $output -join "`n" | Should -Match "ChildValue = child"
            $stats.KeysProcessed | Should -Be 1
            $stats.ValuesProcessed | Should -Be 3
            $stats.MaxDepthReached | Should -Be 1
        }

        It "runs the public registry command with filters and file output" {
            $homePath = Join-Path $TestDrive "registry-home"
            [void][System.IO.Directory]::CreateDirectory((Join-Path $homePath ".PowerTree"))
            $configPath = Join-Path $homePath ".PowerTree/config.json"
            @{
                Shared = @{
                    ShowConnectorLines = $true
                    ShowExecutionStats = $true
                    ShowConfigurations = $false
                    LineStyle = "Unicode"
                    OpenOutputFileOnFinish = $false
                }
                FileSystem = @{}
                Registry = @{ MaxDepth = -1; ExcludeKeys = @() }
            } | ConvertTo-Json -Depth 5 | Set-Content $configPath
            $originalHome = $env:HOME
            $originalUserProfile = $env:USERPROFILE
            $env:HOME = $homePath
            $env:USERPROFILE = $homePath
            try {
                $outputPath = Join-Path $TestDrive "registry.txt"
                Show-PowerTreeRegistry -Path $registryPath -Exclude @("Secret*", "Excluded") `
                    -UseRegistryDataTypes -DisplayItemCounts -OutFile $outputPath *> $null
                $content = [System.IO.File]::ReadAllText($outputPath)
                $content | Should -Match "REG_SZ"
                $content | Should -Match "Alpha"
                $content | Should -Not -Match "SecretValue"
                $content | Should -Match "Keys\s+Values"
            } finally {
                $env:HOME = $originalHome
                $env:USERPROFILE = $originalUserProfile
            }
        }
    }
}
