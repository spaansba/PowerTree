
function Build-ChildItemDirectoryParams {
    param(
        [boolean]$ShowHiddenFiles
    )

    $dirParams = @{
        Directory = $true
        ErrorAction = "SilentlyContinue"
    }
    
    if ($ShowHiddenFiles) {
        $dirParams.Add("Force", $true)
    }
    return $dirParams 
}