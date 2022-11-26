function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the RegistryPolFile.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "RegistryPolFile.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to RegistryPolFile.log file"
        exit 1
    }
}

$regPol = "C:\WINDOWS\System32\GroupPolicy\Machine\Registry.pol"

if (Test-Path $regPol) {
    $regpolProp = Get-Item $regPol
}
else {
    Write-LogEntry -Value "$(Get-Date -format g): Reistry.pol not found on $env:COMPUTERNAME"
    exit
}

$regPolDate = $regPolProp.LastWriteTime
$dateValid = (Get-Date).AddDays(-2)
$svcName = wuauserv

if ($regPolDate -lt $dateValid) {
    Write-LogEntry -Value "$(Get-Date -format g): Registry.pol is out of date $regPolDate"
    $service = Get-Service -Name $svcName
    if ($service.Status -eq "Running") {
        Stop-Service -Name $svcName -Force
        while (((Get-Service -Name $svcName).Status -ne "Stopped") -and ($ct -lt 30)) {
            Start-Sleep -Seconds 1
            $ctr++
            Write-LogEntry -Value "$(Get-Date -format g): $($service.Name) service not stopped after $ctr seconds"
        }
        Write-LogEntry -Value "$(Get-Date -format g): Stopped the $svcName process"
    }

    $service = Get-Service -Name $svcName
    if ($service.Status -eq "Stopped") {
        Write-LogEntry -Value "$(Get-Date -format g): The $($service.Name) service is not running"
        try {
            Remove-Item $regPol -Force -ErrorAction Stop
        }
        catch {
            Write-LogEntry -Value "$(Get-Date -format g): Failed to delete the $regPol file."
            exit
        }

        try {
            Rename-Item -Path "$env:windir\SoftwareDistribution" -NewName "SoftwareDistributionOld" -Force -ErrorAction Stop
            Remove-Item -Path "$env:windir\SoftwareDistributionOld" -Recurse -Force -ErrorAction Stop
        }
        catch {
            Write-LogEntry -Value "$(Get-Date -format g): Failed to rename/remove the SoftwareDistribution folder"
        }
    }
    else {
        Write-LogEntry -Value "$(Get-Date -format g): Failed to stop the $($service.Name) service."
    }
}
else {
    Write-LogEntry -Value "$(Get-Date -format g): Registry.pol LastWriteTime is OK - $regPolDate"
}