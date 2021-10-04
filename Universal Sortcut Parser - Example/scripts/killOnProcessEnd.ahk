; first arg: process name to wait
; other args - process names to kill
; kill instantly if called without argument or first argument is empty string
; kill all running *.ahk scripts if where is only one argument or no arguments

if %1%
{
	; wait for process to start, but no more then 120 seconds
	Process, Wait, %1%, 120
	procPID := ErrorLevel
	if not procPID
	{
		MsgBox The specified process did not appear.
		ExitApp ; Stop this script
	}
	Process, WaitClose, %1%
}

killList := A_args
killList.RemoveAt(1)

if(killList.Length() = 0)
	killList.Push("autohotkey.exe")


for index, element in killList
{
	Process, Exist, %element%
	if (!!ERRORLEVEL)
		Run, %ComSpec% /c Taskkill -f -im %element%, , Hide
}