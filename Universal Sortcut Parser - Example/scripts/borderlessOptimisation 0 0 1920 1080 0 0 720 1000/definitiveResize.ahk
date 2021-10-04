; It is part of the original script
; modifyed by IO_Nox for use with Universal Sortcut Parser v 1.0
; arguments:
;
; game process name
; client process name or "-" if game will be launched dirrectly
; x, y, width, height for "game waiting mode", autoset if no args provided, 3-6 args,
; x, y, width, height for "playing mode", autoset to twice the width of "singleScreen mode" if no args provided
;
; original script:
;
;//The Definitive Supreme Commander Windowed Borderless Script
;//thecore, tatsu, IO_Nox other sources on the net
;//1.04
; https://forum.faforever.com/topic/123/guide-fake-fullscreen-and-optimisation/45

;//hotkey for dual screen mode / second size is Ctrl F12
;//hotkey for single screen mode / first size is Ctrl F11


#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent


global startInDualScreenMode := false ;//Set the default Screen mode on startup, true is start in dual screen mode
;//all personal variables are here WILL BE SET AUTOMATICULLY
global moveX := 0 ;//Sets the main screen x location, 0 being the "main display" X location
global moveY := 0 ;//Sets the main screen x location, 0 being the "main display" Y location
global width := 0 ;//resolution width (do not change)
global height := 0 ;//resolution height (do not change)
global moveX_2 := 0
global moveY_2 := 0
global width_2 := 0
global height_2 := 0

global dualScreenActive := startInDualScreenMode ;//(do not change)

global procGame := "null" ;//holds the game exe to use
global procName := 0


; getting all variables from command line args

moveX = %3%
moveY = %4%
moveX := moveX != "" ? moveX : 0
moveY := moveY != "" ? moveY : 0
moveX_2 = %7%
moveY_2 = %8%
moveX_2 := moveX_2 != "" ? moveX_2 : 0
moveY_2 := moveY_2 != "" ? moveY_2 : 0

if(A_Args.Length() > 5)
{
	width = %5%
	height = %6%
	if(A_Args.Length() > 9)
	{
		width_2 = %9%
		height_2 = %10%
	}
	else
	{
		width_2 := width*2
		height_2 := height
	}
}
else
{
	; auto Set Monitor Size
	SysGet, Mon1, Monitor, 1 ;//get monitor 1 resolution
	width := % Mon1Left ; //set width resolution
	height := % Mon1Bottom ; //set width resolution
	
	;//if the value is negative change it to positive number
	if(width < 0)
	{
		width := (-1 * width)
	}
	if(height < 0)
	{
		height := (-1 * height)
	}
	width_2 := width*2
	height_2 := height
}


; process for game
procGame = %1%
procClient = %2%
directLaunch := (procClient = "-") or (procClient = "")
procName := directLaunch ? procGame : procClient



; this will automatically find your processor threads count
EnvGet, ProcessorCount, NUMBER_OF_PROCESSORS


Process, Wait, %procName%, 120 ;//Wait upto 120 seconds for the exe to start
procPID := ErrorLevel ;//set the error level

;//if the exe does not start show an error message and exit the script
if not procPID
{ 
	MsgBox The specified process did not appear.
    ExitApp ; Stop this script
}


;//Call the exitProc function after the set time
SetTimer, exitProc, 2000 



;//Function that will Manually switch from dual screen to single screen
resize(x0, y0, x, y, gametype,active) 
{
	if(active = true)
	{
		if(dualScreenActive = true)
			return
		dualScreenActive := true
	}
	else
	{
		if(dualScreenActive = false)
			return
		dualScreenActive := false
	}	
	
	WinMove, % "ahk_exe " gametype , , %x0%, %y0%, %x%, %y% 
	WinMaximize, % "ahk_exe " gametype 
	WinRestore, % "ahk_exe " gametype 
	
}

;//Hot key to switch from dual screen to single screen or to exit the script
^F12::resize(moveX_2, moveY_2, width_2, height_2,procGame,true) ;//Ctrl F12 to enter dual screen mode
^F11::resize(moveX, moveY, width, height,procGame,false) ;//Ctrl F11 to enter single screen mode




;//Check if the process exist
ProcessExist(exeName)
{ 
   Process, Exist, %exeName%
   return !!ERRORLEVEL
}

;//exit script if the procName is not running
exitProc:
	if (ProcessExist(procName) == 0)
	{
		quit()
	}
return	

;//exit the script
quit()
{ 	
	ExitApp
}
return