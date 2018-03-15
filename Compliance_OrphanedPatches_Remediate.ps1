$VBSFile = @"
'Option Explicit

Dim msi : Set msi = CreateObject("WindowsInstaller.Installer")

'Output CSV header
WScript.Echo "The data format is ProductCode, PatchCode, PatchLocation"
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile("output.txt", True)
objFile.WriteLine "ProductCode, PatchCode, PatchLocation"
objFile.WriteLine ""
' Enumerate all products
Dim products : Set products = msi.Products
Dim productCode

For Each productCode in products
	' For each product, enumerate its applied patches
	Dim patches : Set patches = msi.Patches(productCode)
	Dim patchCode

	For Each patchCode in patches
		' Get the local patch location
		Dim location : location = msi.PatchInfo(patchCode, "LocalPackage")
        objFile.WriteLine productCode & ", " & patchCode & ", " & location
		
	Next
Next
WScript.Echo "Data written to output.txt, these are the registered objects and SHOULD be kept!"
"@

Remove-Item C:\Temp\output.txt -Force -ErrorAction SilentlyContinue
Remove-Item C:\Temp\WiMsps.vbs -Force -ErrorAction SilentlyContinue

Set-Location C:\Temp

$VBSFile | Set-Content C:\Temp\WiMsps.vbs

cscript WiMsps.vbs

$savelist = Import-Csv C:\Temp\output.txt

$filelocation = $savelist | Select-Object -ExpandProperty PatchLocation

#First pass to remove exact file names
Get-ChildItem C:\windows\Installer -file | ForEach-Object {
    $fullname = $_.FullName
    if ($filelocation | Where-Object {$_ -like "*$fullname*"}) {
        Write-Output "Keeping $fullname"
    }
    else {
        Remove-Item $fullname -Force -Verbose
    }
}

#second pass to match product and patch codes
Get-ChildItem C:\windows\Installer -Directory | ForEach-Object {
    $fullname = $_.name
    if($savelist | Where-Object {$_.ProductCode -like "*$fullname*" -or $_.PatchCode -like "*$fullname*" }) {
        Write-Output "Keeping $fullname"
    }
    else {
        Remove-Item $_.fullname -Force -Verbose -Recurse
    }
}

Remove-Item C:\Temp\output.txt -Force -ErrorAction SilentlyContinue
Remove-Item C:\Temp\WiMsps.vbs -Force -ErrorAction SilentlyContinue