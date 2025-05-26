function Get-Path {
   param (
       [string]$Path
   )
   
   # Remove Computer\ prefix if present
   $Path = $Path -replace '^Computer\\', ''
   
   # Convert full hive names to short forms
   $Path = $Path -replace '^HKEY_LOCAL_MACHINE\\?', 'HKLM:\'
   $Path = $Path -replace '^HKEY_CURRENT_USER\\?', 'HKCU:\'
   $Path = $Path -replace '^HKEY_CLASSES_ROOT\\?', 'HKCR:\'
   $Path = $Path -replace '^HKEY_USERS\\?', 'HKU:\'
   $Path = $Path -replace '^HKEY_CURRENT_CONFIG\\?', 'HKCC:\'
   
   # Ensure path ends with :\ if it's just the hive
   if ($Path -match '^HK[A-Z]+$') {
       $Path += ':\'
   }
    
   if(-not (Test-Path $Path)){
       Write-Error "$Path - Path does not exist"
       exit 1
   }
   if((Get-Item $Path).GetType().Name -ne "RegistryKey"){
       Write-Error "$Path - Path is not a registry key"
       exit 1
   }
 
   return $Path
}