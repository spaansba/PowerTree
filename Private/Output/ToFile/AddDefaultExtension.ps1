
# Adds a default .txt extension to a file path if it doesn't already have an extension
function Add-DefaultExtension {
    param (
        [string]$FilePath,
        [bool]$Quiet
    )
    
    if ([string]::IsNullOrEmpty($FilePath)) {
        # If no filepath is set and Quiet is true, use default "PowerTree.txt"
        if ($Quiet) {
            return "PowerTree.txt"
        }
        return $FilePath # meaning no outfile
    }
    
    if ([string]::IsNullOrEmpty([System.IO.Path]::GetExtension($FilePath))) {
        return "$FilePath.txt"
    }
    
    return $FilePath
}