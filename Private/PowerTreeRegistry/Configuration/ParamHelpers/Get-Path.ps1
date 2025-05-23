function Get-Path {
   param (
       [string]$Path
   )
    
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