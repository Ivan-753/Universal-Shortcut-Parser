Universal Sortcut Parser
Version 1.0
By Ivan-753
Source: https://github.com/Ivan-753/Universal-Shortcut-Parser.git
Early as:
By IO_Nox
Source: https://forum.faforever.com/topic/123/guide-fake-fullscreen-and-optimisation/46

Launch multiple applications from one shortcut.
Call usp.ahk with launch parameters and it will run sortcuts and scripts for this parameters.

This script was made in AutoHotkey (https://www.autohotkey.com) for Windows, maybe one day I will remake it in C or any other language.

HOT TO USE IT:

lets create option MYOPT.
1. create shortcut for "usp.ahk", go in its properties and add command line parameter "MYOPT":
Object value will end like
...\usp.ahk" MYOPT
NOTE you can add many options to same shortcut: ...\usp.ahk" MYOPT opt2 opt3
and all options will be called
2. add records in "options.txt" like "MYOPT file files\test.txt"
3. add scripts and shortcuts or files in "scripts" and "shortcuts" dirs.
In "scripts" dir:
	scripst with names like "MYOPT.ahk", "MYOPT 01.exe" and all files in dirs "MYOPT" and "MYOPT arg1" will be called automatically, files in dir like "MYOPT arg1" will be called with command line parameters from dir name.
In "shortcuts" dir:
	files with names like "MYOPT.lnk", "MYOPT script2 arg01.txt" and all files in dirs "MYOPT" and "MYOPT script1 arg1" will be called automatically,
	for files and dirs named like "MYOPT scriptname arg1" will be called all scripts with command line parameters from file/dir name.

Naming for "scripts" folder is:
[SCRIPT_NAME].[ANY_EXT]
[SCRIPT_NAME] [ANY_TEXT].[ANY_EXT]
[SCRIPT_NAME] (dir)
	[ANY_NAME].[ANY_EXT] (subdirs allowed)
[SCRIPT_NAME] [ADDITIONAL_ARG_1] .. [ADDITIONAL_ARG_N] (dir)
	[ANY_NAME].[ANY_EXT] (subdirs allowed)
	
	
If called script [SCRIPT_NAME] with arguments [ARG_1] .. [ARG_N] then:
[SCRIPT_NAME].[ANY_EXT] will be called with arguments [ARG_1] .. [ARG_N]
[SCRIPT_NAME] [ANY_TEXT].[ANY_EXT] will be called with arguments [ARG_1] .. [ARG_N]
all files in folder [SCRIPT_NAME] and subfolders will be called with arguments [ARG_1] .. [ARG_N]
all files in folder [SCRIPT_NAME] [ADDITIONAL_ARG_1] .. [ADDITIONAL_ARG_N] and subfolders will be called with arguments [ARG_1] .. [ARG_N] [ADDITIONAL_ARG_1] .. [ADDITIONAL_ARG_N]
If [SCRIPT_NAME] is same as [OPTION] it will be called automatically without arguments for this [OPTION].


Naming for "sortcuts" folder is:
[OPTION].[ANY_EXT]
[OPTION] [SCRIPT_NAME] [ARG_1] .. [ARG_N].[ANY_EXT]
[OPTION] [ANY_TEXT].[ANY_EXT] 
[OPTION] (dir)
	[ANY_NAME].[ANY_EXT] (subdirs allowed)
[OPTION] [SCRIPT_NAME] [ARG_1] .. [ARG_N] (dir)
	[ANY_NAME].[ANY_EXT] (subdirs allowed)

For each [OPTION] all shortcuts will be called.
If sortcut name containes [SCRIPT_NAME] [ARG_1] .. [ARG_N] then scripts for [SCRIPT_NAME] will be started.
In case of [ANY_TEXT] - it will be parsed like [SCRIPT_NAME]... but you should be sure that where will be no scripts to run.
So EXAMPLE:

in "sortcuts" dir:
	myOption_1.txt
	myOption_1 01 .txt
	myOption_1 script_2 arg1.txt
	myOption_123.txt
	myOption_1 (dir)
		random file.exe
	myOption_1 script_1 (dir)
		one more random file.txt
		random sub dir (dir)
			random file 123.txt
	myOption_2 script_2 arg_a1 arg_a2 (empty dir)
in "scripts" dir:
	myOption_1.ahk
	myOption_1 1.exe
	myOption_1 (dir)
		file 1.exe
		file 2.bat
	myOption_1 argN(dir)
		file 3.exe
		file 4.bat
	script_2.ahk
	script_2 2.ahk
	
Lets call "usp.ahk myOption_1 myOption_2"
"sortcuts\myOption_1.txt" will be called.
"sortcuts\myOption_1 01 .txt" will be called AND it will try to call script "01", but we don't have any.
"sortcuts\myOption_1 script_2 arg1.txt" will be called,
	plus "script_2.ahk arg1" and "script_2 2.ahk arg1" scripts
"sortcuts\myOption_123.txt" will be ignored
"sortcuts\myOption_1 (dir)" all files in this folder will be called:
	"sortcuts\myOption_1\random file.exe"
"sortcuts\myOption_1 script_1" (dir) all files in this folder and subfolders will be called:
	"sortcuts\myOption_1 script_1\one more random file.txt"
	"sortcuts\myOption_1 script_1\random sub dir\random file 123.txt"
	where is no script like "script_1.*" or "script_1 *.*" to call
"sortcuts\myOption_2 script_2 arg_a1 arg_a2" (empty dir) will only call 
	scripts "script_2.ahk arg_a1 arg_a2" 
	and "script_2 2.ahk arg_a1 arg_a2"


"scripts\myOption_1.ahk" will be called
"scripts\myOption_1 1.exe" will be called
"scripts\myOption_1" (dir) all files in folder and subfolders will be called:
	"scripts\myOption_1\file 1.exe"
	"scripts\myOption_1\file 2.bat"
"scripts\myOption_1 argN"(dir)  all files in folder and subfolders will be called, last comand line patameter will be "argN":
	"scripts\myOption_1 argN\file 3.exe argN"
	"scripts\myOption_1 argN\file 4.bat argN"
"scripts\script_2.ahk" will be ignored (may be called from shortcuts)
"scripts\script_2 2.ahk" will be ignored (may be called from shortcuts)

Settings are in "config.ini" and defaults (if "config.ini" is not found) are same as

[universalSortcutParser]
scriptsFolder="scripts"
shortcutsFolder="shortcuts"
callListFile="options.txt"
logFile="log.txt"
saveLog=false
testing=false

If testing is "true", when script will NOT run anything BUT will show log for current launch.
If saveLog is "true", when script will save log in file.
I'm recommending to set both "false" for normal use and "true" only for debuggin of your new options.

Options in txt file:

[OPTION] file [FILE_OR_DIR_PATH]
will run file if it exists, or run all files in directory. NO COMMAND LINE ARGS here.

[OPTION] script [SCRIPT_NAME] [ARG_1] [ARG_2] .. [ARG_N]
will call file from scripts dir with arguments, file extension is optional, scriptname shoid NOT contain any white spaces.

[OPTION] run [AHK_Run_ARGUMENT]
will simply call "Run, %AHK_Run_ARGUMENT%" no cheking and prepocessing for input string will be done, run files with command line arguments by this command.
