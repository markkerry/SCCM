function Clear-NomadCache {
    # Set the Cache Cleaner file and file parameters
    $CacheCleaner = "C:\Program Files\1E\NomadBranch\CacheCleaner.exe"
    $Params = "-MaxCacheAge=30"
    # Start the Cache Cleaner, deleting anything older than 14 days
    Start-Process $CacheCleaner -ArgumentList $Params -Wait -NoNewWindow
}
Clear-NomadCache