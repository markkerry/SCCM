function Set-CCMCacheLimit {
    <#
    .Synopsis
        Change the SCCM Cache limit of a machine.
    .DESCRIPTION
        This function allows you to remotely change the SCCM Cache limit of a machine.
        I have set only three sizes in the parameter $Value. 5GB, 10GB, 15GB. You can
        change these to suit your needs.
    .PARAMETER ComputerName
        The computer(s) you want to change the cache size on.
    .PARAMETER Value
        The valuse of the cache size you want to set. Three options 5120, 10240 and 15360.
    .EXAMPLE
        Change the SCCM cache size on a single machine.

        Set-CCMCacheLimit -ComputerName COMPUTER1 -Value 5120
    .EXAMPLE
        Change the SCCM cache size on multiple machines.

        Set-CCMCacheLimit -ComputerName (Get-Content C:\Scripts\Computers.txt) -Value 15360
        Set-CCMCacheLimit -ComputerName COMPUTER1,COMPUTER2,COMPUTER3 -Value 10240
    .NOTES
        Created:	2016-15-12            

        Author:     Mark Kerry
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String[]]$ComputerName,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateSet("5120","10240","15360")]
        [UInt32]$Value
    )

    begin {
        # Check for elevation
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Warning "You need to run this script from an elevated PowerShell prompt!`nPlease start PowerShell as an Administrator and re-run the script..."
        break
        }
    }

    process {
        # Loop through each computer in the ComputerName parameter.
        foreach ($Computer in $ComputerName) {
            # Check if the computer is online
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                try {
                    # Get the SCCM CacheConfig size from the WMI of the machine.
                    $i = Get-WmiObject -Namespace Root\ccm\SoftMgmtAgent -Class CacheConfig -ComputerName $Computer -ErrorAction Stop
                    # If the current cache size is not the same as the value specified in the parameter, continue. If its the same move onto the next machine in the loop.
                    if (-not ($i.Size -like $Value)) {
                        Write-Output "[$Computer  ] SCCM Cache limit is set to $($i.Size)"
                        Write-Output "[$Computer  ] Attempting to change the SCCM cache limit to $Value"
                        # Set the new cache limit.
                        try {
                            $i.Size = $Value
                            $i.Put()
                            # Restart the SCCM CcmExec service.
                            try {
                                $Service = 'CcmExec'
                                Write-Verbose "[$Computer  ] Changed Cache limit. Restarting the $Service service."
                                $s = Get-Service -ComputerName $Computer -Name $Service -ErrorAction Stop
                                $s | Restart-Service -Verbose
                                Start-Sleep 1
                                Write-Output "[$Computer  ] SCCM cache limit has been changed to $Value"
                            }
                            catch {
                                Write-Warning "[$Computer  ] Unable to restart the $Service service."
                                Write-Warning $_.exception.message
                            }
                        }
                        catch {
                            Write-Warning "[$Computer  ] Failed to change cache."
                            Write-Warning $_.exception.message
                        }  
                    }
                    else {
                        Write-Output "[$Computer  ] SCCM cache limit is already the desired size of $($i.Size)"
                    }
                }
                catch {
                    Write-Warning "[$Computer  ] Unable to Query the WMI."
                    Write-Warning $_.exception.message
                }
            }
            else {
                Write-Output "[$Computer  ] Unable to connect"
            }
        }
    }
    end {}
}
