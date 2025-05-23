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
    
    $sorted = switch ($SortBy) {
        "Modification Date" {
            $Items | Sort-Object -Property LastWriteTime
        }
        "Creation Date" {
            $Items | Sort-Object -Property CreationTime
        }
        "Last Access Date" {
            $Items | Sort-Object -Property LastAccessTime
        }
        "Name" {
            $Items | Sort-Object -Property Name
        }
        "Size" {
            $Items | Sort-Object -Property { if ($_ -is [System.IO.DirectoryInfo]) {
                # For directories, calculate total size of contents
                (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            } else {
                # For files, use file length
                $_.Length
            }}
        }

        Default {
            $Items | Sort-Object -Property Name
        }
    }
    
    if ($SortDescending) {
        # When sorting in descending order, we need to be specific about the property
        switch ($SortBy) {
            "Modification Date" { return $Items | Sort-Object -Property LastWriteTime -Descending }
            "Creation Date" { return $Items | Sort-Object -Property CreationTime -Descending }
            "Last Access Date" { return $Items | Sort-Object -Property LastAccessTime -Descending }
            "Name" { return $Items | Sort-Object -Property Name -Descending }
            "Size" { 
                return $Items | Sort-Object -Property { 
                    if ($_ -is [System.IO.DirectoryInfo]) {
                        (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                            Measure-Object -Property Length -Sum).Sum
                    } else {
                        $_.Length
                    }
                } -Descending 
            }

            Default { return $Items | Sort-Object -Property Name -Descending }
        }
    } else {
        return $sorted
    }
}