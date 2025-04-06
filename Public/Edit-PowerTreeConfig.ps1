function Edit-PowerTreeConfig {
    [CmdletBinding()]
    param()
    
    $configPaths = Get-ConfigPaths
    $existingConfig = $configPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if ($existingConfig) {
        $configPath = $existingConfig
    } else {
        if ($IsWindows -or $null -eq $IsWindows) {
            $configDir = Join-Path -Path $env:USERPROFILE -ChildPath ".PowerTree"
        } else {
            $configDir = Join-Path -Path $env:HOME -ChildPath ".PowerTree"
        }
        
        if (-not (Test-Path -Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
            Write-Host "Created directory: $configDir" -ForegroundColor Cyan
        }
        
        $configPath = Join-Path -Path $configDir -ChildPath "config.json"
    }
    
    $configExists = Test-Path -Path $configPath
    
    if (-not $configExists) {
        try {
            $configDir = Split-Path -Parent $configPath
            if (-not (Test-Path -Path $configDir)) {
                New-Item -Path $configDir -ItemType Directory -Force | Out-Null
                Write-Host "Created directory: $configDir" -ForegroundColor Cyan
            }
            
            $defaultConfig = Get-DefaultConfig
            $defaultConfig | ConvertTo-Json -Depth 4 | Out-File -FilePath $configPath -Encoding utf8
            
            Write-Host "Created new config file at: $configPath" -ForegroundColor Green
        } catch {
            Write-Error "Failed to create config file: $_"
            return
        }
    } else {
        Write-Host "Using existing config file: $configPath" -ForegroundColor Cyan
    }
    
    try {
        $resolvedPath = Resolve-Path $configPath -ErrorAction Stop
        
        if ($IsWindows -or $null -eq $IsWindows) {
            Start-Process $resolvedPath
        } elseif ($IsMacOS) {
            Start-Process "open" -ArgumentList $resolvedPath
        } elseif ($IsLinux) {
            $editors = @("xdg-open", "nano", "vim", "vi")
            $editorOpened = $false
            
            foreach ($editor in $editors) {
                try {
                    Start-Process $editor -ArgumentList $resolvedPath -ErrorAction Stop
                    $editorOpened = $true
                    break
                } catch {
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