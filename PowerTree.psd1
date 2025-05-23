
@{
    # Core module information
    RootModule        = 'PowerTree.psm1'
    ModuleVersion     = '1.1.5'
    GUID              = 'bd5a541e-746e-438d-9b57-28f6d9df01a3'
    Author            = 'Bart Spaans'
    CompanyName       = 'Personal'
    Copyright         = '(c) 2025 Bart Spaans. All rights reserved.'
    Description       = 'Advanced directory tree visualization tool with powerful filtering and display options. More information: https://github.com/spaansba/PowerTree'

    # Requirements
    PowerShellVersion      = '7.0'
    CompatiblePSEditions   = @('Desktop', 'Core')

    # Exports
    FunctionsToExport = @('Show-PowerTree', 'Edit-PowerTreeConfig', "Show-PowerTreeRegistry")
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @('ptree', 'Start-PowerTree', 'PowerTree', 'Edit-PtreeConfig', 'Edit-Ptree', 'Edit-PowerTree', "ptreer")

    # PowerShell Gallery metadata
    PrivateData = @{
        PSData = @{
            Tags         = @('FileSystem', 'Directory', 'Tree', 'Cross-Platform', 'PowerTree', 'File-Management', 'System-Administration')
            LicenseUri   = 'https://github.com/spaansba/PowerTree/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/spaansba/PowerTree'
            ReleaseNotes = 'Advanced directory tree visualization with filtering, sorting, and size analysis capabilities.'
        }
    }
}
