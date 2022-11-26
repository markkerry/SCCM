# OSDBuilder

To mount and update the Wim with latest patches

* Download ISO
* Mount ISO
* Run PowerShell as Admin

```powershell
Import-Module OSDBuilder -force -verbose
OSDBuilder -Update
# Restart PowerShell as Admin

Import-OSMedia -Edition Enterprise -SkipGrid -Update
# Import-OSMedia -EditionID Enterprise -SkipGrid -Update
# Import-OSMedia -ImageName 'Windows 10 Enterprise' -SkipGrid -Update
```
