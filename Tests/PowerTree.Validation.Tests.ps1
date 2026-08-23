$ErrorActionPreference = "Stop"

Describe "terminating validation" {
    BeforeAll {
        $modulePath = (Resolve-Path (Join-Path $PSScriptRoot "../PowerTree.psd1")).Path
        $pwshPath = Join-Path $PSHOME $(if ($IsWindows) { "pwsh.exe" } else { "pwsh" })

        function Invoke-PowerTreeSubprocess {
            param([string]$Body)

            $escapedModulePath = $modulePath.Replace("'", "''")
            $script = "Import-Module '$escapedModulePath' -Force`n$Body"
            $output = & $pwshPath -NoLogo -NoProfile -Command $script 2>&1

            return @{
                ExitCode = $LASTEXITCODE
                Output = $output -join "`n"
            }
        }
    }

    It "exits when maximum file size is smaller than minimum file size" {
        $result = Invoke-PowerTreeSubprocess @'
& (Get-Module PowerTree) {
    Build-FileSizeParams -CommandLineMaxSize '1kb' -CommandLineMinSize '2kb' `
        -SettingsLineMaxSize '-1kb' -SettingsLineMinSize '-1kb'
}
'@

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match "Maximum file size cannot be smaller"
    }

    It "exits for missing and non-registry paths" {
        $missingResult = Invoke-PowerTreeSubprocess @'
& (Get-Module PowerTree) { Get-Path '__powertree_missing_path__' }
'@
        $escapedFilePath = $PSCommandPath.Replace("'", "''")
        $fileResult = Invoke-PowerTreeSubprocess "& (Get-Module PowerTree) { Get-Path '$escapedFilePath' }"

        $missingResult.ExitCode | Should -Be 1
        $missingResult.Output | Should -Match "Path does not exist"
        $fileResult.ExitCode | Should -Be 1
        $fileResult.Output | Should -Match "Path is not a registry key"
    }

    It "exits when registry output is requested outside Windows" -Skip:$IsWindows {
        $result = Invoke-PowerTreeSubprocess "Show-PowerTreeRegistry"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match "can only be run on Windows"
    }
}
