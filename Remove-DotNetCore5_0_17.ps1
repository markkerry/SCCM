$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5A66E598-37BD-4C8A-A7CB-A71C32ABCD78}"
$arg = "/x {5A66E598-37BD-4C8A-A7CB-A71C32ABCD78} /qn /norestart IGNOREDEPENDENCIES=ALL"

if (Test-Path -Path $path) {
    try {
        Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList $arg -WindowStyle Hidden -Wait -Verbose -ErrorAction Stop
    }
    catch {
        Write-Output "Failed to remove .NetCore 5.0.17"
        exit 1
    }
}
