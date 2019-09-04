# Delete all HTTPERR log files that is older that 30 days.

$Now = Get-Date
$Days = "30"
$TargetFolder = "C:\Windows\System32\LogFiles\HTTPERR"
$Extension = "*.log"
$LastWrite = $Now.AddDays(-$Days)

if (Test-Path $TargetFolder) {
    $files = get-childitem -Path $TargetFolder -Include $Extension -Recurse | Where-Object {$_.lastwritetime -lt "$LastWrite"} 
    $filesFound = $false
    $files | Foreach-Object {$filesFound = $true} 

    if ($filesFound) { 
        Write-Output "Non-Compliant"
    } 
    else{
        Write-Output "Compliant"
    }
}
else {
    Write-Output "Compliant"
}