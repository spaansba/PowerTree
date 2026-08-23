[CmdletBinding()]
param(
    [string]$ModulePath = (Join-Path $PSScriptRoot "../PowerTree.psd1"),
    [string]$JsonPath,
    [string]$BaselinePath,
    [string]$MarkdownPath,
    [ValidateRange(1, 20)]
    [int]$Iterations = 3
)

$ErrorActionPreference = "Stop"
$resolvedModulePath = (Resolve-Path $ModulePath).Path
$benchmarkRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("powertree-performance-" + [guid]::NewGuid().ToString("N"))
$fixturePath = Join-Path $benchmarkRoot "fixture"
$configPath = Join-Path $benchmarkRoot ".PowerTree/config.json"
$originalHome = $env:HOME
$originalUserProfile = $env:USERPROFILE
$module = $null

function Get-Median {
    param([double[]]$Values)

    $ordered = @($Values | Sort-Object)
    $middle = [math]::Floor($ordered.Count / 2)
    if ($ordered.Count % 2 -eq 1) {
        return $ordered[$middle]
    }
    return ($ordered[$middle - 1] + $ordered[$middle]) / 2
}

function Format-Milliseconds {
    param([double]$Value)

    return [string]::Format([Globalization.CultureInfo]::InvariantCulture, "{0:0.0}", $Value)
}

function Format-Percentage {
    param([double]$Value)

    return [string]::Format([Globalization.CultureInfo]::InvariantCulture, "{0:+0.0;-0.0;0.0}%", $Value)
}

try {
    [void][System.IO.Directory]::CreateDirectory($fixturePath)
    $level = @($fixturePath)
    $extensions = @("txt", "log", "ps1")

    foreach ($depth in 1..5) {
        $nextLevel = [System.Collections.Generic.List[string]]::new()
        foreach ($parent in $level) {
            foreach ($directoryIndex in 1..4) {
                $directory = Join-Path $parent "d${depth}_${directoryIndex}"
                [void][System.IO.Directory]::CreateDirectory($directory)
                $nextLevel.Add($directory)

                foreach ($fileIndex in 1..3) {
                    $extension = $extensions[$fileIndex - 1]
                    $filePath = Join-Path $directory "f${fileIndex}.${extension}"
                    $size = ($depth * 128) + ($directoryIndex * 16) + $fileIndex
                    [System.IO.File]::WriteAllBytes($filePath, [byte[]]::new($size))
                }
            }
        }
        $level = $nextLevel
    }

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
            HumanReadableSizes = $true
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
    $env:HOME = $benchmarkRoot
    $env:USERPROFILE = $benchmarkRoot
    $module = Import-Module $resolvedModulePath -Force -PassThru

    $cases = @(
        @{
            Name = "Default"
            Command = "ptree fixture"
            Parameters = @{}
        }
        @{
            Name = "Display size"
            Command = "ptree fixture -DisplaySize"
            Parameters = @{ DisplaySize = $true }
        }
        @{
            Name = "Size sort"
            Command = "ptree fixture -DisplaySize -SortBySize -Descending"
            Parameters = @{
                DisplaySize = $true
                SortBySize = $true
                Descending = $true
            }
        }
        @{
            Name = "Prune and filter"
            Command = "ptree fixture -PruneEmptyFolders -IncludeExtensions txt"
            Parameters = @{
                PruneEmptyFolders = $true
                IncludeExtensions = @("txt")
            }
        }
    )

    $results = @(
        foreach ($case in $cases) {
            $parameters = @{ LiteralPath = $fixturePath }
            foreach ($entry in $case.Parameters.GetEnumerator()) {
                $parameters[$entry.Key] = $entry.Value
            }

            Show-PowerTree @parameters *> $null
            $samples = @(
                foreach ($iteration in 1..$Iterations) {
                    (Measure-Command { Show-PowerTree @parameters *> $null }).TotalMilliseconds
                }
            )

            [pscustomobject]@{
                Name = $case.Name
                Command = $case.Command
                MedianMilliseconds = [math]::Round((Get-Median $samples), 3)
                MinimumMilliseconds = [math]::Round(($samples | Measure-Object -Minimum).Minimum, 3)
                MaximumMilliseconds = [math]::Round(($samples | Measure-Object -Maximum).Maximum, 3)
                Iterations = $Iterations
            }
        }
    )

    $results | Format-Table Name, MedianMilliseconds, MinimumMilliseconds, MaximumMilliseconds -AutoSize

    if ($JsonPath) {
        $resolvedJsonPath = [System.IO.Path]::GetFullPath($JsonPath)
        [System.IO.File]::WriteAllText($resolvedJsonPath, ($results | ConvertTo-Json -Depth 3))
    }

    if ($MarkdownPath) {
        $lines = [System.Collections.Generic.List[string]]::new()
        $lines.Add("## PowerTree performance")
        $lines.Add("")
        $lines.Add("Fixture: 1,364 directories and 4,092 files. Median of $Iterations measured runs after one warm-up.")
        $lines.Add("")

        $baselineResults = if ($BaselinePath -and (Test-Path $BaselinePath)) {
            @(Get-Content $BaselinePath -Raw | ConvertFrom-Json)
        } else {
            @()
        }

        if ($baselineResults.Count -gt 0) {
            $lines.Add("| Command | Base median | PR median | Change | PR range |")
            $lines.Add("|---|---:|---:|---:|---:|")
            foreach ($result in $results) {
                $baseline = $baselineResults | Where-Object Name -eq $result.Name | Select-Object -First 1
                $change = if ($baseline.MedianMilliseconds -gt 0) {
                    (($result.MedianMilliseconds - $baseline.MedianMilliseconds) / $baseline.MedianMilliseconds) * 100
                } else {
                    0
                }
                $baseMedian = Format-Milliseconds $baseline.MedianMilliseconds
                $prMedian = Format-Milliseconds $result.MedianMilliseconds
                $changeText = Format-Percentage $change
                $minimum = Format-Milliseconds $result.MinimumMilliseconds
                $maximum = Format-Milliseconds $result.MaximumMilliseconds
                $lines.Add("| ``$($result.Command)`` | ${baseMedian} ms | ${prMedian} ms | $changeText | ${minimum}–${maximum} ms |")
            }
        } else {
            $lines.Add("| Command | Median | Range |")
            $lines.Add("|---|---:|---:|")
            foreach ($result in $results) {
                $median = Format-Milliseconds $result.MedianMilliseconds
                $minimum = Format-Milliseconds $result.MinimumMilliseconds
                $maximum = Format-Milliseconds $result.MaximumMilliseconds
                $lines.Add("| ``$($result.Command)`` | ${median} ms | ${minimum}–${maximum} ms |")
            }
        }

        $lines.Add("")
        $lines.Add("Negative change is faster. Results are informational because GitHub-hosted runner performance varies.")
        $markdown = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
        [System.IO.File]::AppendAllText([System.IO.Path]::GetFullPath($MarkdownPath), $markdown)
    }
} finally {
    if ($null -ne $module) {
        Remove-Module $module -Force -ErrorAction Ignore
    }
    $env:HOME = $originalHome
    $env:USERPROFILE = $originalUserProfile
    if ($benchmarkRoot.StartsWith([System.IO.Path]::GetTempPath() + "powertree-performance-")) {
        [System.IO.Directory]::Delete($benchmarkRoot, $true)
    }
}
