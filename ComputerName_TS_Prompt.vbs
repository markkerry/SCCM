Dim TSenv, oTSProgressUI, ComputerName, OSDComputerName, Confirmed
Set TSenv = CreateObject("Microsoft.SMS.TSEnvironment")

Set oTSProgressUI = CreateObject("Microsoft.SMS.TSProgressUI")
oTSProgressUI.CloseProgressDialog()

ComputerName=Inputbox("Please enter the name for the computer.  It should be the same as the Asset Tag")

Do Until Confirmed = "Yes"
If MsgBox ("Are you sure that the computer name entered matches the Asset Tag? > " & ComputerName, vbYesNo) = vbNo then
	ComputerName = Inputbox("Please enter the correct name for the computer as per the Asset Tag","Confirmation Required", ComputerName)
	Else
		If ComputerName = "" then
			Confirmed = "No"
	Else
		TSenv("OSDComputerName") = ComputerName
		Confirmed = "Yes"
	End If
End If
Loop
