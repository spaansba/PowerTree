function Get-SortingMethod{
    param(
        [boolean]$SortBySize,
        [boolean]$SortByName,
        [boolean]$SortByModificationDate,
        [boolean]$SortByCreationDate,
        [boolean]$SortByLastAccessDate,
        [ValidateSet("size", "name", "md", "cd", "la", "")]
        [string]$Sort,
        [ValidateScript({ $script:ValidSortOptions -contains $_ })]
        [string]$DefaultSort
    )

    if ($Sort) {
        switch ($Sort) {
            "size" { $SortBySize = $true }
            "name" { $SortByName = $true }
            "md" { $SortByModificationDate = $true }
            "cd" { $SortByCreationDate = $true }
            "la" { $SortByLastAccessDate = $true }
        }
    }

    $sortBy = $DefaultSort # Default sorting from psTree.config.json
    if ($SortByModificationDate) { $sortBy = "Modification Date" }
    elseif($SortByCreationDate) {$sortBy = "Creation Date"}
    elseif($SortByLastAccessDate) {$sortBy = "Last Access Date"}
    elseif ($SortBySize) { $sortBy = "Size" }
    elseif ($SortByName) { $sortBy = "Name" }
    
    return $sortBy
}

# Function to sort items based on specified criteria
function Group-Items {
    param (
        [Parameter(Mandatory=$false)]
        [System.Object[]]$Items,
        
        [Parameter(Mandatory=$true)]
        [string]$SortBy,
        
        [Parameter()]
        [bool]$SortDescending = $false
    )
    
    if ($null -eq $Items -or $Items.Count -eq 0) {
        return @()
    }
    
    $property = switch ($SortBy) {
        "Modification Date" { "LastWriteTime" }
        "Creation Date" { "CreationTime" }
        "Last Access Date" { "LastAccessTime" }
        "Size" { "Length" }
        default { "Name" }
    }

    return $Items | Sort-Object -Property $property -Descending:$SortDescending
}
