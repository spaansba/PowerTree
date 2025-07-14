function Initialize-ConfigFile {
    [CmdletBinding()]
    param()
    
    $configPaths = Get-ConfigPaths
    $existingConfig = $configPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if ($existingConfig) {
        Write-Verbose "Using existing config file: $existingConfig"
        return
    }
    
    # No config file exists, create one
    if ($IsWindows -or $null -eq $IsWindows) {
        $configDir = Join-Path -Path $env:USERPROFILE -ChildPath ".PowerTree"
    } else {
        $configDir = Join-Path -Path $env:HOME -ChildPath ".PowerTree"
    }
    
    if (-not (Test-Path -Path $configDir)) {
        New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        Write-Verbose "Created directory: $configDir"
    }
    
    $configPath = Join-Path -Path $configDir -ChildPath "config.json"
    
    try {
        $defaultConfig = Get-DefaultConfig
        $defaultConfig | ConvertTo-Json -Depth 4 | Out-File -FilePath $configPath -Encoding utf8
        Write-Verbose "Created new config file at: $configPath"
    } catch {
        Write-Warning "Failed to create config file: $_"
    }
}