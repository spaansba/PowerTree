
function Write-ToFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Content,
        
        [Parameter(Mandatory=$true)]
        [bool]$OpenOutputFileOnFinish
    )
    
    begin {
        try {
            # Ensure the directory exists
            $directory = Split-Path -Path $FilePath -Parent
            if (-not [string]::IsNullOrEmpty($directory) -and -not (Test-Path -Path $directory)) {
                New-Item -Path $directory -ItemType Directory -Force | Out-Null
                Write-Verbose "Created directory: $directory"
            }
            
            # Create or clear the file
            if (Test-Path -Path $FilePath) {
                Clear-Content -Path $FilePath
                Write-Verbose "Cleared existing file: $FilePath"
            } else {
                New-Item -Path $FilePath -ItemType File -Force | Out-Null
                Write-Verbose "Created new file: $FilePath"
            }
        } catch {
            Write-Error "Failed to initialize output file: $_"
            throw
        }
    }
    
    process {
        try {
            $Content | Add-Content -Path $FilePath
        } catch {
            Write-Error "Failed to write to output file: $_"
            throw
        }
    }
    
    end {
        Write-Verbose "Successfully wrote output to $FilePath"
        
        # Open the file after writing if requested
        if ($OpenOutputFileOnFinish) {
            try {
                # Try to resolve the path to handle relative paths
                $resolvedPath = Resolve-Path $FilePath -ErrorAction Stop
                Write-Verbose "Opening file: $resolvedPath"
                
                # Use the appropriate method to open the file based on OS
                if ($IsWindows -or $null -eq $IsWindows) {
                    # On Windows or PowerShell 5.1 where $IsWindows is not defined
                    Start-Process $resolvedPath
                } elseif ($IsMacOS) {
                    # On macOS
                    Start-Process "open" -ArgumentList $resolvedPath
                } elseif ($IsLinux) {
                    # On Linux, try xdg-open first
                    try {
                        Start-Process "xdg-open" -ArgumentList $resolvedPath
                    } catch {
                        # If xdg-open fails, try other common utilities
                        try { Start-Process "nano" -ArgumentList $resolvedPath } catch { 
                            Write-Verbose "Could not open file with xdg-open or nano" 
                        }
                    }
                }
            } catch {
                Write-Warning "Could not open file after writing: $_"
            }
        }
    }
}