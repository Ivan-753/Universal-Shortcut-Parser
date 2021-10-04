; Universal Sortcut Parser
; Version 1.0
; By IO_Nox
; Source: https://forum.faforever.com/topic/123/guide-fake-fullscreen-and-optimisation/46
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SetWorkingDir %A_ScriptDir%
FormatTime, time, R

global scriptsFolder :=
global shortcutsFolder :=
global callListFile :=
global logFile :=
global saveLog :=
global testingMode :=

; load settings from config.ini
IniRead, scriptsFolder, config.ini, universalSortcutParser, scriptsFolder, "scripts"
IniRead, shortcutsFolder, config.ini, universalSortcutParser, shortcutsFolder, "shortcuts"
IniRead, callListFile, config.ini, universalSortcutParser, callListFile, "options.txt"
IniRead, logFile, config.ini, universalSortcutParser, logFile, "log.txt"
IniRead, saveLog, config.ini, universalSortcutParser, saveLog, false
IniRead, testingMode, config.ini, universalSortcutParser, testing, false


global callList := [] ; files and scripts to run
global errors := "`n**Errors**"
global log := "`n*****`n" . time . "`n*****"

FileRead, callsFromFile, %callListFile%
if (not ErrorLevel) ; Successfully loaded.
{
    Sort, callsFromFile ; alphabetical order
}
else
{
	recordError( callListFile . " not found!" )
}


for index, argument in A_Args
{
	log = %log%`n`nOPTION %argument%

	Loop, parse, callsFromFile, `n, `r  ; for both Windows and Unix files to be parsed.
	{
		if (InStr(A_LoopField, argument . " run ") == 1)
		{	; add string for ahk Run without any preproccessing
			addCall(SubStr(A_LoopField,StrLen(argument . " run ")+1), "RUN: ")
		}
		else if (InStr(A_LoopField, argument . " file ") == 1)
		{	; add file link to call
			path = % SubStr(A_LoopField,StrLen(argument . " file ")+1)
			
			if (! FileExist(path))
			{
				recordError( "No File to Call: " . path )
			}
			else if (InStr(FileExist(path), "D"))
			{	; add all files in directory
				Loop, Files, %path%\*, FR ; Files, Recursive
				{
					addCall(A_LoopFilePath, "FILE DIR: ")
				}
			}
			else
			{
				addCall(path, "FILE: ")
			}
		}
		else if (InStr(A_LoopField, argument . " script ") == 1)
		{	; add script to call with arg
			addScripts(SubStr(A_LoopField,StrLen(argument . " script ")+1))
		}
	}
	
	; scan files to call required

	; shortcut for file without scripts to run
	Loop, Files, %shortcutsFolder%\%argument%.*, F ; Files
	{
		addCall(A_LoopFilePath, "SORTCUT: ")
	}
	
	; shortcut for dir without scripts to run
	Loop, Files, %shortcutsFolder%\%argument%, D ; Directories
	{
		Loop, Files, %shortcutsFolder%\%A_LoopFileName%\*, FR ; Files, Recursive
		{
			addCall(A_LoopFilePath, "SORTCUT DIR: ")
		}
	}
	
	; shortcut for file with additional scripts to run
	Loop, Files, %shortcutsFolder%\%argument% *, F ; Files
	{
		addCall(A_LoopFilePath, "SORTCUT*: ")
		
		; cut path, argument part and file extension from file name
		SplitPath, A_LoopFileName, , , , name_no_ext
		addScripts(SubStr(name_no_ext,StrLen(argument)+2))
	}
	
	; shortcut for dir with additional scripts to run
	Loop, Files, %shortcutsFolder%\%argument% *, D ; Directories
	{
		; cut path, argument part and file extension from file name
		SplitPath, A_LoopFileName, , , , name_no_ext
		addScripts(SubStr(name_no_ext,StrLen(argument)+2))
		
		Loop, Files, %shortcutsFolder%\%A_LoopFileName%\*, FR ; Files, Recursive
		{
			addCall(A_LoopFilePath, "SORTCUT DIR*: ")
		}
	}
	
	; add scripts for argument
	addScripts(argument)	
}


; save log
log = %log%`n%errors%`n
if (%saveLog%)
{
	FileAppend , %log%, %logFile%, %A_FileEncoding%
}


if (%testingMode%)
{
	Msgbox % log
}
else
{
	; run all calls
	
	for index, element in callList
		Run, %element%
}






; functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

addCall( newCall, prefix := "")
{
	call := newCall . " " . scriptArgs
	
	
	; no dublicates
	dublicateCall := false
	
	for index, element in callList
        if( element == call )
		{
			dublicateCall := true
			break
		}

	if dublicateCall
	{
		recordError("DUBLICATE: " . prefix . call)
	}
	else
	{
		callList.Push(call)
		log = %log%`n%prefix%%call%
	}

}

recordError(text)
{
	errors = %errors%`n%text%
}


addScripts(str)
{
	if ! str
		return
	
	
	notFound := true

	nameLen = % InStr(str, A_Space)
	if(nameLen = 0)
		nameLen := StrLen(str) + 1
	scriptName = % SubStr(str, 1, nameLen-1)
	scriptArgs = % SubStr(str, nameLen)

	; add scripts from scripts folder
	Loop, Files, %scriptsFolder%\%scriptName%.*, F ; Files
	{
		addCall(A_LoopFilePath . " " . scriptArgs, "SCRIPT: ")
		notFound := false
	}
	Loop, Files, %scriptsFolder%\%scriptName% *, F ; Files
	{
		addCall(A_LoopFilePath . " " . scriptArgs, "SCRIPT*: ")
		notFound := false
	}
	
	
	; scripts in dir with no locked parameters to run
	Loop, Files, %scriptsFolder%\%scriptName%\*, FR ; Files, Recursive
	{
		addCall(A_LoopFilePath . " " . scriptArgs, "SCRIPT DIR: ")
		notFound := false
	}
	
	; scripts in dir to run with additional parameters
	Loop, Files, %scriptsFolder%\%scriptName% *, D ; Directories
	{
		moreScriptArgs := scriptArgs . " " . SubStr(A_LoopFileName,StrLen(scriptName)+2)
		Loop, Files, %scriptsFolder%\%A_LoopFileName%\*, FR ; Files, Recursive
		{
			addCall(A_LoopFilePath . " " . moreScriptArgs, "SCRIPT DIR*: ")
			notFound := false
		}
	}
	

	if notFound
		recordError( "No Scripts to Call: " . str )
}