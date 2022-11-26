# Delete's obsolete package content which was delete from SCCM before being removed from the DPs

$PackagesAtWarningDP = Get-WmiObject -Namespace root\sms\site_$($SiteCode) -Class SMS_PackageStatusDistPointsSummarizer -Filter "ServerNALPath like '%$($WarningDP.Name)%'"

# Format the name of each package into a neat array.
foreach ($Sitepackage in $PackagesAtWarningDP) {
    $AllPackagesAtSite += $Sitepackage.PackageID
}

foreach ($WMIPackage in $AllPackagesInWMI) {
    if ($AllPackagesAtSite -notcontains $WMIPackage) {
        Write-Host "    $($WMIPackage) is NOT assigned to this DP but exists in WMI."
        $PackagesToRemoveFromWMI += "$($WMIPackage)"
    }
}

if ($PackagesToRemoveFromWMI) {
    Write-Host "  There are $($PackagesToRemoveFromWMI.Count) to remove from WMI."
    foreach ($OldPackage in $PackagesToRemoveFromWMI) {
        # Remove the Missing Package from WMI.
        Get-WmiObject -ComputerName $($WarningDP.Name) -Namespace root\sccmdp -Class SMS_PackagesInContLib -Filter "PackageID = '$($OldPackage)'" | Remove-WmiObject
        Write-Host "   Removed $($OldPackage) from WMI."
    }
}