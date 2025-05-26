
# Adds a default .txt extension to a file path if it doesn't already have an extension
function Add-DefaultExtension {
    param (
        [string]$FilePath,
        [bool]$IsRegistry
    )
    
    if ([string]::IsNullOrEmpty($FilePath)) {
        return $FilePath
    }
    
    if ([string]::IsNullOrEmpty([System.IO.Path]::GetExtension($FilePath))) {
        return "$FilePath.txt"
    }
    
    return $FilePath
}