function Invoke-OutputBuilderRegistry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [TreeRegistryConfig]$TreeRegistryConfig,
        [boolean]$ShowExecutionStats = $false
    )

    # Only create OutputBuilder if we need to save to a file
    if ([string]::IsNullOrEmpty($TreeRegistryConfig.OutFile)) {
        return $null
    }

    $outputBuilder = New-Object System.Text.StringBuilder
    
    # Add header information
    [void]$outputBuilder.AppendLine("# PowerTreeRegistry Output")
    [void]$outputBuilder.AppendLine("# Generated: $(Get-Date)")
    [void]$outputBuilder.AppendLine("# Registry Path: $($TreeRegistryConfig.Path)")
    [void]$outputBuilder.AppendLine("# Output File: $($TreeRegistryConfig.OutFile)")
    [void]$outputBuilder.AppendLine("")

    # Display configuration
    [void]$outputBuilder.AppendLine("Configuration:")
    [void]$outputBuilder.AppendLine("─────────────")

    # Basic display options
    if ($TreeRegistryConfig.DisplaySubKeys) {
        [void]$outputBuilder.AppendLine("Display Sub Keys: True")
    }

    if ($TreeRegistryConfig.NoValues) {
        [void]$outputBuilder.AppendLine("Show Values: False (NoValues enabled)")
    }

    if ($TreeRegistryConfig.DisplayItemCounts) {
        [void]$outputBuilder.AppendLine("Display Item Counts: True")
    }

    # Data type display
    $dataTypeText = if ($TreeRegistryConfig.UseRegistryDataTypes) { "Registry Types (REG_SZ, REG_DWORD, etc.)" } else { "PowerShell Types (String, DWord, etc.)" }
    [void]$outputBuilder.AppendLine("Data Types: $dataTypeText")

    # Depth control
    if ($TreeRegistryConfig.MaxDepth -ne -1) {
        [void]$outputBuilder.AppendLine("Max Depth: $($TreeRegistryConfig.MaxDepth)")
    } else {
        [void]$outputBuilder.AppendLine("Max Depth: Unlimited")
    }

    # Sorting configuration
    $sortingDetails = @()
    
    if ($TreeRegistryConfig.SortValuesByType) {
        $sortingDetails += "Sort by Type"
    } else {
        $sortingDetails += "Natural Registry Order (Default first, then alphabetical)"
    }
    
    if ($TreeRegistryConfig.SortDescending) {
        $sortingDetails += "Descending"
    } else {
        $sortingDetails += "Ascending"
    }
    
    [void]$outputBuilder.AppendLine("Sorting: $($sortingDetails -join ', ')")

    # Filtering configuration
    if ($TreeRegistryConfig.Include -and $TreeRegistryConfig.Include.Count -gt 0) {
        [void]$outputBuilder.AppendLine("Include Patterns (Values only): $($TreeRegistryConfig.Include -join ', ')")
    }

    if ($TreeRegistryConfig.Exclude -and $TreeRegistryConfig.Exclude.Count -gt 0) {
        [void]$outputBuilder.AppendLine("Exclude Patterns (Keys & Values): $($TreeRegistryConfig.Exclude -join ', ')")
    }

    # Line style
    if ($TreeRegistryConfig.LineStyle) {
        $lineStyleName = switch ($TreeRegistryConfig.LineStyle.Vertical) {
            "│" { "ASCII" }
            "┃" { "Unicode Heavy" }
            "|" { "Simple" }
            default { "Custom" }
        }
        [void]$outputBuilder.AppendLine("Line Style: $lineStyleName")
    }

    [void]$outputBuilder.AppendLine("")

    # Add placeholder for execution stats if needed
    if ($ShowExecutionStats) {
        [void]$outputBuilder.AppendLine("Execution Stats:")
        [void]$outputBuilder.AppendLine("───────────────")
        [void]$outputBuilder.AppendLine("# Stats will be appended here after execution")
        [void]$outputBuilder.AppendLine("")
    }

    return $outputBuilder
}

function Write-RegistryConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [TreeRegistryConfig]$TreeRegistryConfig
    )

    if ($TreeRegistryConfig.Quiet) {
        return
    }
    
    # Validate registry path
    try {
        $regKey = Get-Item -LiteralPath $TreeRegistryConfig.Path -ErrorAction Stop
        $absolutePath = $TreeRegistryConfig.Path
    }
    catch {
        Write-Host "Registry path not found: $($TreeRegistryConfig.Path)" -ForegroundColor Red
        return
    }
    
    # Sorting configuration
    $sortByText = if ($TreeRegistryConfig.SortValuesByType) { "Type" } else { "Registry Order" }
    $direction = if ($TreeRegistryConfig.SortDescending) { "Descending" } else { "Ascending" }
    $sortDisplay = "$sortByText $direction"
    
    # Display configuration
    $displayItems = @()
    
    if ($TreeRegistryConfig.DisplaySubKeys) {
        $displayItems += "Sub Keys"
    }
    
    if (-not $TreeRegistryConfig.NoValues) {
        $displayItems += "Values"
    }
    
    if ($TreeRegistryConfig.DisplayItemCounts) {
        $displayItems += "Item Counts"
    }
    
    $displayText = if ($displayItems.Count -gt 0) { $displayItems -join ", " } else { "Keys Only" }
    
    Write-Host ""
    Write-Verbose "Some settings might be sourced from the .config.json file" 
    Write-Host "Sort By: $sortDisplay" -ForegroundColor Green
    Write-Host "Display: $displayText" -ForegroundColor Green
    
    # Data type display
    if ($TreeRegistryConfig.UseRegistryDataTypes) {
        Write-Host "Data Types: Registry Types (REG_SZ, REG_DWORD, etc.)" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "Data Types: PowerShell Types (String, DWord, etc.)"
    }

    # Quiet mode
    if ($TreeRegistryConfig.Quiet -ne $true) {
        Write-Verbose "Quiet: False" 
    }

    # Display sub keys
    if ($TreeRegistryConfig.DisplaySubKeys) {
        Write-Verbose "DisplaySubKeys: True"
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "DisplaySubKeys: False"
    }
    
    # No values option
    if ($TreeRegistryConfig.NoValues) {
        Write-Host "NoValues: True" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "NoValues: False"
    }
    
    # Display item counts
    if ($TreeRegistryConfig.DisplayItemCounts) {
        Write-Verbose "DisplayItemCounts: True"
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "DisplayItemCounts: False"
    }
    
    # Sort values by type
    if ($TreeRegistryConfig.SortValuesByType) {
        Write-Verbose "SortValuesByType: True"
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "SortValuesByType: False"
    }

    # Max depth
    if ($TreeRegistryConfig.MaxDepth -ne -1) {
        Write-Host "Max Depth: $($TreeRegistryConfig.MaxDepth)" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "MaxDepth: -1 (no limit)"
    }
    
    # Include patterns (values only)
    if ($TreeRegistryConfig.Include -and $TreeRegistryConfig.Include.Count -gt 0) {
        Write-Host "Include Patterns (Values): $($TreeRegistryConfig.Include -join ', ')" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "No include patterns specified"
    }
    
    # Exclude patterns (keys and values)
    if ($TreeRegistryConfig.Exclude -and $TreeRegistryConfig.Exclude.Count -gt 0) {
        Write-Host "Exclude Patterns (Keys & Values): $($TreeRegistryConfig.Exclude -join ', ')" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "No exclude patterns specified"
    }
    
    # Output file handling
    if (-not [string]::IsNullOrEmpty($TreeRegistryConfig.OutFile)) {
        Write-Host "Output File: $($TreeRegistryConfig.OutFile)" -ForegroundColor Green
    } elseif ($VerbosePreference -ne 'SilentlyContinue') {
        Write-Verbose "No output file specified"
    }
    
    Write-Host ""
}