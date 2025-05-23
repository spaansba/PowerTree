function Get-RegistrySubKeys {
    param (
        [string]$RegistryPath,
        [TreeRegistryConfig]$TreeRegistryConfig
    )
    
    $subKeys = @()
    
    try {
        $registryKey = Get-Item -Path $RegistryPath -ErrorAction Stop
        $subKeyNames = $registryKey.GetSubKeyNames()
        
        foreach ($subKeyName in $subKeyNames) {
            $subKeyPath = Join-Path $RegistryPath $subKeyName
            
            # Apply filtering logic
            if (Test-RegistryKeyFilter -KeyName $subKeyName -TreeRegistryConfig $TreeRegistryConfig) {
                $subKeys += [PSCustomObject]@{
                    Name = $subKeyName
                    FullPath = $subKeyPath
                }
            }
        }
    }
    catch {
        Write-Verbose "Error accessing registry key '$RegistryPath': $($_.Exception.Message)"
        return @()
    }
    
    return $subKeys
}

function Test-RegistryKeyFilter {
    param (
        [string]$KeyName,
        [TreeRegistryConfig]$TreeRegistryConfig
    )
    
    # Check excluded keys
    if ($TreeRegistryConfig.ExcludedKeys -and $TreeRegistryConfig.ExcludedKeys.Count -gt 0) {
        foreach ($excludedKey in $TreeRegistryConfig.ExcludedKeys) {
            if ($KeyName -like $excludedKey) {
                return $false
            }
        }
    }
    
    # Check included keys (if specified, only include matching keys)
    if ($TreeRegistryConfig.IncludedKeys -and $TreeRegistryConfig.IncludedKeys.Count -gt 0) {
        $matchesInclude = $false
        foreach ($includedKey in $TreeRegistryConfig.IncludedKeys) {
            if ($KeyName -like $includedKey) {
                $matchesInclude = $true
                break
            }
        }
        return $matchesInclude
    }
    
    return $true
}

function Get-RegistryValues {
    param (
        [string]$RegistryPath
    )
    
    $values = @()
    
    try {
        $registryKey = Get-Item -Path $RegistryPath -ErrorAction Stop
        $registryValueNames = $registryKey.GetValueNames()
        
        if ($registryValueNames -and $registryValueNames.Count -gt 0) {
            foreach ($valueName in $registryValueNames) {
                $valueDisplayName = if ([string]::IsNullOrEmpty($valueName)) { "(Default)" } else { $valueName }
                
                try {
                    $value = $registryKey.GetValue($valueName)
                    $valueType = $registryKey.GetValueKind($valueName)
                    $valueString = Get-RegistryValueString -Value $value -ValueType $valueType
                    
                    $values += [PSCustomObject]@{
                        Name = $valueDisplayName
                        Value = $valueString
                        Type = $valueType
                        Error = $null
                    }
                }
                catch {
                    $values += [PSCustomObject]@{
                        Name = $valueDisplayName
                        Value = "[Unable to read value]"
                        Type = "Error"
                        Error = $_.Exception.Message
                    }
                }
            }
        }
    }
    catch {
        Write-Verbose "Error reading registry values from '$RegistryPath': $($_.Exception.Message)"
    }
    
    return $values
}