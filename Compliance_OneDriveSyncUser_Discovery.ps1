$oneDriveSignIn = "$ENV:LOCALAPPDATA\Microsoft\OneDrive\settings\Business1\OfficeDiscoveryResponse.txt"
$oneDriveDir = "$ENV:LOCALAPPDATA\Microsoft\OneDrive\"
$oneDriveExe = "OneDrive.exe"

# Check if local admin. If so exit as compliant as OneDrive cannot be run as admin
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Check OneDrive has been installed and part configured for the user. If not exit as Compliant 
    if (Test-Path -Path (Join-Path -Path $oneDriveDir -ChildPath $oneDriveExe -ErrorAction SilentlyContinue)) {
        # If local user is not an admin and OneDrive is installed but not been signed into... Set as non compliant for remediate script
        if (!(Test-Path -Path $oneDriveSignIn -ErrorAction SilentlyContinue)) {
            $Compliance = "NonCompliant"
         }
         else {
            $Compliance = "Compliant"
         }
    }
    else {
        $Compliance = "Compliant"
    }
}
else {
    $Compliance = "Compliant"
}
Return $Compliance