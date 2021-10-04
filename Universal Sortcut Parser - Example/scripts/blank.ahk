text := "BLANK Script"

for index, element in A_Args
{
	text = %text%`n%element%
}


t = %3%
t := t != "" ? "third arg exists: " . t : "no third arg"

text = %text%`n`n%t%
Msgbox, % text