function Get-FolderSize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path,
        
        [Parameter()]
        [switch]$Recurse,
        
        [Parameter()]
        [switch]$HumanReadable
    )
    
    $folders = if ($Recurse) {
        Get-ChildItem -Path $Path -Directory -Recurse
    } else {
        Get-ChildItem -Path $Path -Directory
    }
    
    $results = foreach ($folder in $folders) {
        $size = (Get-ChildItem $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                Measure-Object -Property Length -Sum).Sum
        
        $readableSize = if ($HumanReadable) {
            # Convert to human-readable format
            $sizes = @(' B', 'KB', 'MB', 'GB', 'TB')
            $order = 0
            $value = $size
            
            while ($value -ge 1024 -and $order -lt 4) {
                $order++
                $value /= 1024.0
            }
            
            "{0:0.##}{1}" -f $value, $sizes[$order]
        } else {
            $size
        }
        
        [PSCustomObject]@{
            Folder = $folder.FullName
            Size = $size
            ReadableSize = $readableSize
        }
    }
    
    return $results | Sort-Object Size -Descending
}