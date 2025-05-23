function Format-FileExtensions {
    param (
        [string[]]$Extensions
    )
    
    $formattedExtensions = @()
    
    foreach ($ext in $Extensions) {
        if ([string]::IsNullOrWhiteSpace($ext)) { continue }
        
        $extension = $ext.Trim().ToLower()
        
        if ($extension.StartsWith("*.")) {
            # Already in correct format (*.ext)
            $formattedExtensions += $extension
        }
        elseif ($extension.StartsWith(".")) {
            # If it starts with a dot, prepend *
            $formattedExtensions += "*$extension"
        }
        elseif ($extension.StartsWith("*")) {
            # If it starts with * but not with *., insert a dot after *
            $formattedExtensions += "*.$($extension.Substring(1))"
        }
        else {
            # Otherwise, prepend "*."
            $formattedExtensions += "*.$extension"
        }
    }
    
    return $formattedExtensions
}
