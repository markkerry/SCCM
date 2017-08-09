# Delete the user profiles which haven't been modified in over 90 days.
# Exclude C:\Users\Public and C:\Users\Administrator
# Using a WMI method it removes the directory and the registry info. 

$SuccessCount = 0
$ErrorCount = 0
$UsersPath = 'C:\Users\'
$UserProfiles = Get-ChildItem -Path $UsersPath | Where-Object {$_ -notlike "*Administrator*" -and $_ -notlike "*Public*" -and $_.LastWriteTime -le (Get-Date).AddDays(-90)} | Select-Object Name -ExpandProperty Name


foreach ($UserProfile in $UserProfiles) {
    try {
        $UserWMI = Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -eq (Join-Path -Path $UsersPath -ChildPath "$UserProfile")}
        if ($UserWMI) {
            $UserWMI.Delete()
            $SuccessCount++
        }
        else {
            Write-Output "Cannot find $UserPofile profile in WMI."
        }
    }
    catch {
        Write-Output "Failed to gather WMI info from $ENV:COMPUTERNAME."
        $ErrorCount++
    }
}

If ($ErrorCount -gt $SuccessCount) {Write-Output "Error count $ErrorCount is higher than success count $SuccessCount.";exit 1}