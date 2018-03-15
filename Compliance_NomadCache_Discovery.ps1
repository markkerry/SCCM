function Get-NomadCache {
    # If the NomadBranch Cache Cleaner exists set the complaince state to 1. Uncompliant. 
    If (Test-Path -Path "C:\Program Files\1E\NomadBranch\CacheCleaner.exe") {
        $Compliance = '1'
    }
    else {
        $Compliance = '0'
    }
    Return $Compliance
}
Get-NomadCache