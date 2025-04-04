function Edit-PowerTreeConfig {
    [CmdletBinding()]
    param()
    
    # Determine the config file path
    $configPaths = Get-PowerTreeConfigPaths
    $existingConfig = $configPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if ($existingConfig) {
        $configPath = $existingConfig
    } else {
        # No existing config found, create in user profile
        if ($IsWindows -or $null -eq $IsWindows) {
            $configDir = Join-Path -Path $env:USERPROFILE -ChildPath ".PowerTree"
        } else {
            $configDir = Join-Path -Path $env:HOME -ChildPath ".PowerTree"
        }
        
        # Ensure directory exists
        if (-not (Test-Path -Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
            Write-Host "Created directory: $configDir" -ForegroundColor Cyan
        }
        
        $configPath = Join-Path -Path $configDir -ChildPath "config.json"
    }
    
    $configExists = Test-Path -Path $configPath
    
    # Create config file if it doesn't exist
    if (-not $configExists) {
        try {
            # Ensure directory exists
            $configDir = Split-Path -Parent $configPath
            if (-not (Test-Path -Path $configDir)) {
                New-Item -Path $configDir -ItemType Directory -Force | Out-Null
                Write-Host "Created directory: $configDir" -ForegroundColor Cyan
            }
            
            # Create the config file with default settings
            $defaultConfig = Get-PowerTreeDefaultConfig
            $defaultConfig | ConvertTo-Json -Depth 4 | Out-File -FilePath $configPath -Encoding utf8
            
            Write-Host "Created new config file at: $configPath" -ForegroundColor Green
        } catch {
            Write-Error "Failed to create config file: $_"
            return
        }
    } else {
        Write-Host "Using existing config file: $configPath" -ForegroundColor Cyan
    }
    
    # Open the config file
    try {
        # Try to resolve the path to handle relative paths
        $resolvedPath = Resolve-Path $configPath -ErrorAction Stop
        
        # Use the appropriate method to open the file based on OS
        if ($IsWindows -or $null -eq $IsWindows) {
            # On Windows or PowerShell 5.1 where $IsWindows is not defined
            Start-Process $resolvedPath
        } elseif ($IsMacOS) {
            # On macOS
            Start-Process "open" -ArgumentList $resolvedPath
        } elseif ($IsLinux) {
            # On Linux, try various editors in order
            $editors = @("xdg-open", "nano", "vim", "vi")
            $editorOpened = $false
            
            foreach ($editor in $editors) {
                try {
                    Start-Process $editor -ArgumentList $resolvedPath -ErrorAction Stop
                    $editorOpened = $true
                    break
                } catch {
                    # Try next editor
                    continue
                }
            }
            
            if (-not $editorOpened) {
                Write-Warning "Could not open editor. Please manually edit: $resolvedPath"
            }
        }
    } catch {
        Write-Warning "Could not open file: $_"
    }
}

Export-ModuleMember -Function Get-PowerTreeSettingsFromJson, Edit-PowerTreeConfig