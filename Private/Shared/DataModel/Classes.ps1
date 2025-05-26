class TreeConfig {
    [string]$Path
    [bool]$DirectoryOnly
    [string[]]$ExcludeDirectories
    [string]$SortBy
    [bool]$SortDescending
    [bool]$SortFolders
    [hashtable]$ChildItemDirectoryParams
    [hashtable]$ChildItemFileParams
    [hashtable]$HeaderTable
    [bool]$ShowConnectorLines
    [bool]$ShowHiddenFiles
    [int]$MaxDepth
    [hashtable]$FileSizeBounds
    [string]$OutFile
    [bool]$PruneEmptyFolders
    [hashtable]$LineStyle
    [bool]$HumanReadableSizes
}

class TreeRegistryConfig {
    [string]$Path
    [bool]$NoValues
    [string[]]$Exclude
    [string[]]$Include
    [int]$MaxDepth
    [hashtable]$LineStyle
    [bool]$DisplayItemCounts
    [bool]$SortValuesByType
    [bool]$SortDescending
    [bool]$UseRegistryDataTypes
    [string]$OutFile
}

class RegistryStats {
    [int]$KeysProcessed = 0
    [int]$ValuesProcessed = 0
    [int]$MaxDepthReached = 0
    
    [void] UpdateDepth([int]$depth) {
        if ($depth -gt $this.MaxDepthReached) {
            $this.MaxDepthReached = $depth
        }
    }
}

class TreeStats {
    [long]$FilesPrinted = 0
    [long]$FoldersPrinted = 0
    [int]$MaxDepth = 0
    [long]$TotalSize = 0
    [System.IO.FileInfo]$LargestFile = $null
    [string]$LargestFolder = ""
    [long]$LargestFolderSize = 0
    
    [void] AddFile([System.IO.FileInfo]$file) {
        $this.FilesPrinted++
        $this.TotalSize += $file.Length
        
        # Track largest file
        if ($null -eq $this.LargestFile -or $file.Length -gt $this.LargestFile.Length) {
            $this.LargestFile = $file
        }
    }
    
    [void] UpdateLargestFolder([string]$folderPath, [long]$folderSize) {
        if ($folderSize -gt $this.LargestFolderSize) {
            $this.LargestFolder = $folderPath
            $this.LargestFolderSize = $folderSize
        }
    }
    
    [void] UpdateMaxDepth([int]$depth) {
        if ($depth -gt $this.MaxDepth) {
            $this.MaxDepth = $depth
        }
    }
}