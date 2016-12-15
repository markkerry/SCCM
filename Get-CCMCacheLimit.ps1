function Get-CCMCacheLimit {
    <#
    .Synopsis
        Displays the SCCM Cache limit of a machine.
    .DESCRIPTION
        This function allows you to remotely check the SCCM Cache limit of a machine.
    .PARAMETER ComputerName
        The computer(s) you want to change the cache size on.
    .EXAMPLE
        Check the SCCM cache size on a single machine.

        Get-CCMCacheLimit -ComputerName COMPUTER1
    .EXAMPLE
        Check the SCCM cache size on multiple machines.

        Get-CCMCacheLimit -ComputerName (Get-Content C:\Scripts\Computers.txt)
        Get-CCMCacheLimit -ComputerName COMPUTER1,COMPUTER2,COMPUTER3
    .NOTES
        Created:	2016-15-12            

        Author:     Mark Kerry
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String[]]$ComputerName
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
                    Write-Output "[$Computer  ] SCCM Cache limit is set to $($i.Size)"
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
