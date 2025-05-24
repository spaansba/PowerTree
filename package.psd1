@{
    Root = 'c:\Users\barts\OneDrive\Bureaublad\Projects\Scripts\PowerTree\Private\PowerTree\Output\Get-TreeView.ps1'
    OutputPath = 'c:\Users\barts\OneDrive\Bureaublad\Projects\Scripts\PowerTree\out'
    Package = @{
        Enabled = $true
        Obfuscate = $false
        HideConsoleWindow = $false
        DotNetVersion = 'v4.6.2'
        FileVersion = '1.0.0'
        FileDescription = ''
        ProductName = ''
        ProductVersion = ''
        Copyright = ''
        RequireElevation = $false
        ApplicationIconPath = ''
        PackageType = 'Console'
    }
    Bundle = @{
        Enabled = $true
        Modules = $true
        # IgnoredModules = @()
    }
}
        