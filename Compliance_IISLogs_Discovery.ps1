# Delete all IIS log files that is older that 7 days.

$Now = Get-Date
$Days = "7"
$TargetFolder = "C:\inetpub\logs\LogFiles"
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