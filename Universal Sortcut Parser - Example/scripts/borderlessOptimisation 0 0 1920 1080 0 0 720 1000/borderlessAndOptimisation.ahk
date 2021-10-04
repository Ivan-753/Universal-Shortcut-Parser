#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent

; arg example:
; SupremeCommander.exe - 0 0 1920 1080
; ForgedAlliance.exe downlords-faf-client.exe
;
; all personal variables are here and got from command line arguments
; this script version will NOT run client or game

; move the window to 0,0 and resize it to fit across 1 or 2 monitors
moveX = %3%
moveY = %4%
width = %5%
height = %6%
moveX := moveX != "" ? moveX : 0
moveY := moveY != "" ? moveY : 0
width := width != "" ? width : 1920
height := height != "" ? height : 1080

; process for game
procGame = %1%
procClient = %2%

directLaunch := (procClient = "-") or (procClient = "")

procName := directLaunch ? procGame : procClient



; this will automatically find your processor threads count
EnvGet, ProcessorCount, NUMBER_OF_PROCESSORS

; wait for process to start, but no more then 120 seconds
Process, Wait, %procName%, 120
procPID := ErrorLevel
if not procPID
{
	MsgBox The specified process did not appear.
	ExitApp ; Stop this script
}

SetTimer, CheckProc, 2000

if(!directLaunch)
{
	; Stop then Client stoped
	Process, WaitClose, %procClient%
	ExitApp
}


CheckProc:
	if (!ProcessExist(procGame))
		return

	WinGet Style, Style, % "ahk_exe " procGame
	if (Style & 0xC40000)
	{
		; remove the titlebar and borders
		WinSet, Style, -0xC40000, % "ahk_exe " procGame 
		; move the window to 0,0 and resize it to fit across 1 or 2 monitors.
		WinMove, % "ahk_exe " procGame , , moveX, moveY, width, height
		WinMaximize, % "ahk_exe " procGame
		WinRestore, % "ahk_exe " procGame

		; set High priority and cores affinity 
		Process, Priority, %procGame%, H
		gamePID := ErrorLevel
		ProcessHandle := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", false, "UInt", gamePID)
		DllCall("SetProcessAffinityMask", "UInt", ProcessHandle, "UInt", 2**ProcessorCount - 2 )
		DllCall("CloseHandle", "UInt", ProcessHandle)
		
		
		if(directLaunch)
		{
			ExitApp  ; Stop this script
		}
		else
		{
			Process, WaitClose, %procGame%
		}
	}
return

ProcessExist(exeName)
{
	Process, Exist, %exeName%
	return !!ERRORLEVEL
}
return
