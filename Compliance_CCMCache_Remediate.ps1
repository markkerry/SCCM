function SCCMPurgeList
{
	# Specify Max Days For CCM Cache Entries
	$MaxRetention = "14"
	
	# Connect To Resource Manager Com Object
	$SCCMClient = New-Object -ComObject UIResource.UIResourceMgr
	
	# Get SCCM Client Cache Directory Location
	$SCCMCacheDir = ($SCCMClient.GetCacheInfo().Location)
	
	# List All Applications Due In The Future Or Currently Running
	$PendingApps = $SCCMClient.GetAvailableApplications() | Where-Object { (($_.StartTime -gt (Get-Date)) -or ($_.IsCurrentlyRunning -eq "1")) }
	
	# Create List Of Applications To Purge From Cache
	$PurgeApps = $SCCMClient.GetCacheInfo().GetCacheElements() | Where-Object { ($_.ContentID -notin $PendingApps.PackageID) -and $((Test-Path -Path $_.Location) -eq $true) -and ($_.LastReferenceTime -lt (Get-Date).AddDays(- $MaxRetention)) }
	
	# Purge Apps No Longer Required
	foreach ($App in $PurgeApps)
	{
		$SCCMClient.GetCacheInfo().DeleteCacheElement($App.CacheElementID)
	}
	
	# Clean Up Misc Directories 
	$ActiveDirs = $SCCMClient.GetCacheInfo().GetCacheElements() | ForEach-Object { Write-Output $_.Location }
	Get-ChildItem -Path $SCCMCacheDir | Where-Object { (($_.PsIsContainer -eq $true) -and ($_.FullName -notin $ActiveDirs)) } | Remove-Item -Recurse -Force
}
SCCMPurgeList