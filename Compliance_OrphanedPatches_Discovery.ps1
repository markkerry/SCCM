$x = (Get-ChildItem -Path "C:\Windows\Installer" -Recurse -Force | Measure-Object -Property Length -Sum).Sum

if ($x -gt 10000000000) {
    Write-Output "NonCompliant"
}
else {
    Write-Output "Compliant"
}