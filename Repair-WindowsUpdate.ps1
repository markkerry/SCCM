function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the RepairWindowsUpdate.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "RepairWindowsUpdate.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to RepairWindowsUpdate.log file"
        exit 1
    }
}

$svcName = "wuauserv"
$ctr = 0

Write-LogEntry -Value "$(Get-Date -format g): Starting the Windows Update repair script"
$service = Get-Service -Name $svcName
if ($service.Status -eq "Running") {
    $svcWasRunning = $true
    Stop-Service -Name $svcName -Force
    while (((Get-Service -Name wuauserv).Status -ne "Stopped") -and ($ct -lt 30)) {
        Start-Sleep -Seconds 1
        $ctr++
        Write-LogEntry -Value "$(Get-Date -format g): $($service.Name) service not stopped after $ctr seconds"
    }
    Write-LogEntry -Value "$(Get-Date -format g): Stopped the $svcName process"
}

$service = Get-Service -Name $svcName
if ($service.Status -eq "Stopped") {
    Write-LogEntry -Value "$(Get-Date -format g): The $($service.Name) service is not running"
    Write-LogEntry -Value "$(Get-Date -format g): Deleting the SoftwareDistribution folder"
    try {
        Rename-Item -Path "$env:windir\SoftwareDistribution" -NewName "SoftwareDistributionOld" -Force -ErrorAction Stop
        Remove-Item -Path "$env:windir\SoftwareDistributionOld" -Recurse -Force -ErrorAction Stop
        Write-LogEntry -Value "$(Get-Date -format g): Successfully removed the SoftwareDistribution folder"
    }
    catch {
        Write-LogEntry -Value "$(Get-Date -format g): Failed to rename/remove the SoftwareDistribution folder"
        exit 1
    }

    if ($svcWasRunning) {
        Start-Service -Name $service.Name 
    }
}
else {
    Write-LogEntry -Value "$(Get-Date -format g): Failed to stop the $($service.Name) service."
}