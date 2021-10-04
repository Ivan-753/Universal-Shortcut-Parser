; It is part of the original script
; modifyed by IO_Nox for use with Universal Sortcut Parser v 1.0
; it will automatically detect monitor resolution if called without some arguments
; it will NOT run any game or client process by itself
; arguments:
;
; game process name
; client process name or "-" if game will be launched dirrectly
; "true" to enable mouse lock, always third argument, "false" by default
; "true" to enable auto switch to dual screen mode, "false" by default
; x, y, width, height for "game waiting mode", autoset if no args provided, 5-8 args,
; x, y, width, height for "playing mode", autoset to twice the size of "singleScreen mode"t if no args provided
;
; original script:
;
;//The Definitive Supreme Commander Windowed Borderless Script
;//thecore, tatsu, IO_Nox other sources on the net
;//1.04
; https://forum.faforever.com/topic/123/guide-fake-fullscreen-and-optimisation/45
;
;//limitations
;//ui-party does not support steam Supreme Commander (9350)
;
;//hotkey for dual screen mode is Ctrl F12
;//hotkey for single screen mode is Ctrl F11



#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent

;//all personal variables are here WILL BE SET AUTOMATICULLY
global moveX := 0 ;//Sets the main screen x location, 0 being the "main display" X location
global moveY := 0 ;//Sets the main screen x location, 0 being the "main display" Y location
global width := 0 ;//resolution width (do not change)
global height := 0 ;//resolution height (do not change)
global moveX_2 := 0
global moveY_2 := 0
global width_2 := 0
global height_2 := 0
global clipMouse = false ;//This will trap the mouse cursor within the game while the game window is active, you can use windows key to deactivate the game window,
global enableAutoDualScreen := false ;//Auto checks if a game is loading and switches to dual screen mode


global startInDualScreenMode := false ;//Set the default Screen mode on startup, true is start in dual screen mode
global dualScreenActive := startInDualScreenMode ;//(do not change)

global procGame := "null" ;//holds the game exe to use
global procName := 0


; getting all variables from command line args

clipMouse = %3%
enableAutoDualScreen = %4%
clipMouse := clipMouse != "true" ? false : true
enableAutoDualScreen := enableAutoDualScreen != "true" ? false : true


moveX = %5%
moveY = %6%
moveX := moveX != "" ? moveX : 0
moveY := moveY != "" ? moveY : 0
moveX_2 = %9%
moveY_2 = %10%
moveX_2 := moveX_2 != "" ? moveX_2 : 0
moveY_2 := moveY_2 != "" ? moveY_2 : 0

if(A_Args.Length() > 7)
{
	width = %7%
	height = %8%
	if(A_Args.Length() > 11)
	{
		width_2 = %11%
		height_2 = %12%
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
	if(Mon1Right != 0)
		width := Mon1Right ; //set width resolution
	else if(Mon1Left != 0)
		width := % Mon1Left
	else 
		width := 1920

	if(Mon1Bottom != 0)
		height := Mon1Bottom ; //set width resolution
	else if(Mon1Top != 0)
		height := Mon1Top
	else 
		height := 1080
	
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


global loaded := false ;// has the game loaded
global loadingImageFound := 0 ;//How many times the loading image was found
global endImageFound := 0 //how many times the end image was found


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
;//Call the CheckProc function after the set time
SetTimer, CheckProc, 2000
if(clipMouse = true)
{
	SetTimer, clipProc, 100 
}

;// Try and auto detect if the game is loading or has finished

if(enableAutoDualScreen = true)
{
	SetTimer, loadingSearch, 10
	SetTimer, endGameSearch, 10
	SetTimer, endGameSearch, OFF
}
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

;//Resize the game on start up,
CheckProc:
	if (!ProcessExist(procName)) 
		return
	WinGet Style, Style, % "ahk_exe " procGame ;//Gets the style from the game exe
	
	if (Style & 0xC40000)
	{ 
        WinSet, Style, -0xC40000, % "ahk_exe " procGame ;//removes the titlebar and borders
		
		windowWidth := width ;//sets the windowWidth value to width
		windowHeight := height ;
		moveX0 := moveX
		moveY0 := moveY
		;//Checks the default screen mode
		if(startInDualScreenMode = true) 
		{ 
			;//use dual screen mode as default
			windowWidth := width_2 
			windowHeight := height_2
			moveX0 := moveX_2
			moveY0 := moveY_2
		}
		
		; //move the window to 0,0 and resize it to fit across 1 or 2 monitors.
		dualScreenActive = !dualScreenActive
		resize(moveX0, moveY0, windowWidth, windowHeight, procGame, startInDualScreenMode)
		

        ; //set High priority
        Process, Priority, %procGame%, H
        
		; //sets the number of processors to use, by default it will use all processor except CPU0
		; //NOTE with windows 10, windows 11 this is not really needed 
		gamePID := ErrorLevel
        ProcessHandle := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", false, "UInt", gamePID)
        DllCall("SetProcessAffinityMask", "UInt", ProcessHandle, "UInt", 2**ProcessorCount - 2 )
		DllCall("CloseHandle", "UInt", ProcessHandle)
		loaded := true
    }
return

clipProc: 
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
	
	;//trap mouse
	ClipCursor( true, X, Y, W, H)
	
return

loadingSearch:
	if (!ProcessExist(procGame)) 
	{
		settimer, endGameSearch, OFF
		settimer, loadingSearch, ON
		loadingImageFound = 0;
		if(dualScreenActive = true)
		{
			dualScreenActive := false
		}
		return
	}

	if !WinActive("ahk_exe " procGame)
	{
		return
	}	
	;//checks if t
	if(dualScreenActive = true)
		return
	if(!loaded) 
		return
	
	loop, %A_ScriptDir%\pics\loadgame\*.*
	{
	  CoordMode Pixel,Relative
	  ImageSearch, FoundX, FoundY, moveX, moveY, width, height, *50, %A_ScriptDir%\pics\loadgame\%A_Index%.jpg ;
	  if (ErrorLevel = 0)
	  {
		loadingImageFound++
		if(loadingImageFound = 2)
		{
			loadingImageFound := 0
			resize(moveX_2, moveY_2, width_2, height_2,procGame,true)
			settimer, endGameSearch, ON
			settimer, loadingSearch, OFF
		}
		break
	  }
	 }
return

; //Check to see if the game has ended are the users in at the stats menu, working for FAF and LOUD 
endGameSearch:
	if (!ProcessExist(procGame)) 
	{ ;//Check if the game is running
		
		settimer, endGameSearch, OFF
		settimer, loadingSearch, ON
		endImageFound = 0;
		if(dualScreenActive = true)
		{ ;//disable dual screen
			dualScreenActive := false
		}
		return
	}
	if !WinActive("ahk_exe " procGame)
	{
		return
	}	
	;//return if not in dual screen mode
	if(dualScreenActive = false)
		return
	
	;//checks if game is loaded
	if(!loaded) 
		return
	
	loop, %A_ScriptDir%\pics\endgame\*.*
	{ ;//Loop through all the images in endgame
	  CoordMode Pixel,Relative
	  ImageSearch, FoundX, FoundY, moveX_2, moveY_2, width_2, heigh_2, *80, %A_ScriptDir%\pics\endgame\%A_Index%.jpg ;
	  if (ErrorLevel = 0)
	  {
		endImageFound++
		if(endImageFound = 2)
		{
			endImageFound :=0
			resize(moveX, moveY, width, height,procGame,false)
			settimer, endGameSearch, OFF
			settimer, loadingSearch, ON
		}
		break
	  }
	 }
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