function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the ResetWinActivation.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "ResetWinActivation.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to ResetWinActivation.log file"
        exit 1
    }
}

# Original firmware embedded product key location
$originalKey = Get-WmiObject -query 'select * from SoftwareLicensingService' | Select-Object -ExpandProperty OA3xOriginalProductKey
# Process to change the product key
$keyProc = "C:\Windows\System32\changepk.exe"
$keyParams = "/ProductKey $originalKey"

if ($originalKey) {
    Write-LogEntry -Value "$(Get-Date -format g): Installing the original firmware embedded product key"
    try {
        Start-Process -FilePath $keyProc -ArgumentList $keyParams -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-LogEntry -Value "$(Get-Date -format g): Unable to change install the original key"
    }
}
else {
    Write-LogEntry -Value "$(Get-Date -format g): No key present"
    exit 1
}