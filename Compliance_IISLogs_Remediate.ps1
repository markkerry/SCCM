# Delete all IIS log files that is older that 7 days.

$Now = Get-Date
$Days = "7"
$TargetFolder = "C:\inetpub\logs\LogFiles"
$Extension = "*.log"
$LastWrite = $Now.AddDays(-$Days)

if (Test-Path $TargetFolder) {
    $files = get-childitem -Path $TargetFolder -Include $Extension -Recurse | Where-Object {$_.lastwritetime -lt "$LastWrite"} 

    foreach ($File in $Files) {
        Write-Output "Deleting File $File"
        Remove-Item $File.FullName | out-null
    }
}
else {
    Write-Output "The Target folder does not exists"
}