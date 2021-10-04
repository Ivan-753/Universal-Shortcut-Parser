;//The Definitive Supreme Commander Windowed Borderless Script
;//thecore, tatsu, IO_Nox other sources on the net
;//1.04

;//Supports 
;//dual Monitors of the same resolution
;//mouse cursor traping
;//Supreme Commander steam version
;//Supreme Commander Forged Alliance steam version
;//Forged Alliance Forever 
;//Downlord's FAF Client
;//LOUD

;//limitations
;//Only supports monitors of the same resolution
;//ui-party does not support steam Supreme Commander (9350)

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#Persistent

;//all personal variables are here
global moveX := 0 ;//Sets the main screen x location, 0 being the "main display" X location
global moveY := 0 ;//Sets the main screen x location, 0 being the "main display" Y location
global width := 0 ;//resolution width (do not change)
global height := 0 ;//resolution height (do not change)
global clipMouse = true ;//This will trap the mouse cursor within the game while the game window is active, you can use windows key to deactivate the game window,
global autoSetMonitorSize := true ;//set to use auto set resolution 
global enableAutoDualScreen := true ;//Auto checks if a game is loading and switches to dual screen mode
if(autoSetMonitorSize == true)
{
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
}
else
{ ;//manually set monitor resolution size
	width := 1920  ;2560, 3840 ;//Sets the width resolution, for 1080p use (1920), for 1440p use (2560), for 4k use (3840) or use a custom value
	height := 1080 ;1440, 2160 ;//Sets the height resolution
}

global startInDualScreenMode := false ;//Set the default Screen mode on startup, true is start in dual screen mode
global dualScreenActive := startInDualScreenMode ;//(do not change)
;//hotkey for dual screen mode is Ctrl F12
;//hotkey for single screen mode is Ctrl F11
;//hotkey for exit script is Ctrl F10

;//Paths to different game exe types
global pathOrLinkSteamSC := "steam://rungameid/9350" ;//Location to Supreme Commander steam version
global pathOrLinkSteamFaf := "steam://rungameid/9420" ;//Location to Supreme Commander Forged Alliance steam version

global pathOrLinkFAF := "C:\ProgramData\FAForever\bin" ;//Location to Forged Alliance Forever exe (this is normally found in "C:\ProgramData\FAForever\bin")
global pathOrLinkLOUD := "E:\Games\supreme commander forged alliance\Supreme Commander - Forged Alliance\Supreme Commander - Forged Alliance" ;//Location to LOUD SCFA_Updater.exe
global pathOrLinkClient := "E:\Games\supreme commander forged alliance\forged alliance forever\Downlord's FAF Client" ;//Location to Downlord's FAF Client exe

;//the name of the exe for each game type
global procSteamSC := "SupremeCommander.exe" ;//Supreme Commander steam version
global procSteamFaf := "SupremeCommander.exe" ;//Supreme Commander Forged Alliance steam version
global procFAF := "ForgedAlliance.exe" ;//Forged Alliance Forever 
global procClient := "downlords-faf-client.exe" ;//Downlord's FAF Client
global procLOUD := "SCFA_Updater.exe" ;//LOUD Updater

;//Set the number of processor threads to use, by default it will find auto find the max supported processors
EnvGet, ProcessorCount, NUMBER_OF_PROCESSORS

firstArg := A_Args[1] ;//get shortcut parameters command line first agrument
StringLower, lowerCaseFirstArg, firstArg ;//Sets firstArg to lower case, not really needed but just in case the user puts in a uppercase value
global procGame := "null" ;//holds the game exe to use 

global loaded := false ;// has the game loaded
global loadingImageFound := 0 ;//How many times the loading image was found
global endImageFound := 0 //how many times the end image was found
	
;//Run the following exe based off pram from shortcut
;//procGame - Sets which game exe name to use, this is the exe that will have the width and height changed
;//procName - Sets which exe that needs to be closed to stop the ahk script (e.g for the Downlord's FAF Client the script will stop once the client is shutdown and not the game exe)
;//procPath - Sets the game path
;//Run, %procName%, %procPath% - run the exe at the path
global procGame := 0
global procName := 0
global procPath := 0

if(lowerCaseFirstArg = "client")
{ ;//Run the Downlord's FAF Client
	procGame := procFAF
	procName := procClient
	procPath := pathOrLinkClient
	Run, %procName%, %procPath%
}
else if(lowerCaseFirstArg = "faf" )
{ ;//Run Forged Alliance Forever
	procGame := procFAF
	procName := procFAF
	procPath := pathOrLinkFAF
	Run, %procName%, %procPath%
}
else if(lowerCaseFirstArg = "steamFAF")
{ ;//Run upreme Commander Forged Alliance steam version
	procGame := procSteamFaf
	procName := procSteamFaf
	procPath := pathOrLinkSteamFaf
	Run, %procPath%
}
else if(lowerCaseFirstArg = "loud")
{ ;//Run LOUD 
	procGame := procFAF
	procName := procLOUD
	procPath := pathOrLinkLOUD
	Run, %procName%, %procPath%
}
else if(lowerCaseFirstArg = "steamSC")
{ ;//Run LOUD 
	procGame := procSteamSC
	procName := procSteamSC
	procPath := pathOrLinkSteamSC
	Run, %procPath%
}

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
if(clipMouse == true)
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
resize(x, y, gametype,active) 
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
		WinMove, % "ahk_exe " gametype , , moveX, moveY, %x%, %y% 
		WinMaximize, % "ahk_exe " gametype
		WinRestore, % "ahk_exe " gametype
}

;//Hot key to switch from dual screen to single screen or to exit the script
^F12::resize(width*2, height,procGame,true) ;//Ctrl F12 to enter dual screen mode
^F11::resize(width, height,procGame,false) ;//Ctrl F11 to enter single screen mode
^F10::quit() ;//Ctrl F10 to stop the script

;//Resize the game on start up,
CheckProc:
	if (!ProcessExist(procName)) 
		return
	WinGet Style, Style, % "ahk_exe " procGame ;//Gets the style from the game exe
	
	if (Style & 0xC40000)
	{ 
        WinSet, Style, -0xC40000, % "ahk_exe " procGame ;//removes the titlebar and borders
		
		windowWidth := width ;//sets the windowWidth value to width
		;//Checks the default screen mode
		if(startInDualScreenMode = true) 
		{ 
			windowWidth := windowWidth*2 ;//use dual screen mode as default
		}
		
		; //move the window to 0,0 and resize it to fit across 1 or 2 monitors.
		WinMove, % "ahk_exe " procGame , , moveX, moveY, windowWidth, height
        WinMaximize, % "ahk_exe " procGame
        WinRestore, % "ahk_exe " procGame

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
	;//trap mouse
	Confine := !Confine
	setWidth := width
	;//trap mouse to dual screen
	if(dualScreenActive == true)
	{
		setWidth := setWidth * 2
	}
	ClipCursor( Confine, 0, 0, setWidth, height)
	
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
	  ImageSearch, FoundX, FoundY, 0, 0, width, height, *50, %A_ScriptDir%\pics\loadgame\%A_Index%.jpg ;
	  if (ErrorLevel = 0)
	  {
		loadingImageFound++
		if(loadingImageFound = 2)
		{
			loadingImageFound := 0
			resize(width*2, height,procGame,true)
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
	  ImageSearch, FoundX, FoundY, 0, 0, width*2, height, *80, %A_ScriptDir%\pics\endgame\%A_Index%.jpg ;
	  if (ErrorLevel = 0)
	  {
		endImageFound++
		if(endImageFound = 2)
		{
			endImageFound :=0
			resize(width, height,procGame,false)
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