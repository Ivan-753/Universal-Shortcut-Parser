; arguments:
; process for mouse lock
; if set: process to stop script on it's end (if any game launcher is used)

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent


; process for game window to trap mouse into
procGame = %1%
procClient = %2%
directLaunch := (procClient = "-") or (procClient = "")
procName := directLaunch ? procGame : procClient


Process, Wait, %procName%, 120 ;//Wait upto 120 seconds for the exe to start
procPID := ErrorLevel ;//set the error level

;//if the exe does not start show an error message and exit the script
if not procPID
{ 
	MsgBox The specified process did not appear.
    ExitApp ; Stop this script
}


SetTimer, clipProc, 100 



clipProc: 
	if (!ProcessExist(procName)) 
		ExitApp
	if (!ProcessExist(procGame)) 
		return
		
	;//checks if the game window is active
	if !WinActive("ahk_exe " procGame)
	{
		return
	}
	
	; this will get your game window size
	WinGetTitle, winTitle, ahk_exe %procGame%
	WinGetPos, X, Y, W, H, %winTitle%
	w := w - 1
	h := h - 1
	;//trap mouse
	ClipCursor( true, X, Y, W, H)
	
return




; //lock the mouse within the game window
ClipCursor( Confine=True, x1=0 , y1=0, x2=1, y2=1 ) 
{
	VarSetCapacity(R,16,0),  NumPut(x1,&R+0),NumPut(y1,&R+4),NumPut(x2,&R+8),NumPut(y2,&R+12)
	return Confine ? DllCall( "ClipCursor", UInt,&R ) : DllCall( "ClipCursor" )
}


;//Check if the process exist
ProcessExist(exeName)
{ 
   Process, Exist, %exeName%
   return !!ERRORLEVEL
}