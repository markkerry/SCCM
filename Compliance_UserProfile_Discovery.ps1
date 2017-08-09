# Search for user profiles which haven't been modified in over 90 days. 

$UserProfiles = Get-ChildItem -Path 'C:\Users' | Where-Object {$_.LastWriteTime -le (Get-Date).AddDays(-90)} | Select-Object Name -ExpandProperty Name

if ($UserProfiles -eq $null) {
    Write-Output "Compliant"
}
else {
    Write-Output "Non-Compliant"
}