#include "..\UIAWrappers.au3"
#include "..\UIAutomation.au3"
#include "libraries\Assert.au3"

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe") ; forgive me!
WEnd

$pid = Run("notepad.exe")
WinWait("Untitled - Notepad")
$hWnd = WinGetHandle("Untitled - Notepad")

$oNotepad = _UIA_ControlSetText($hWnd, "[CLASS:Edit; INSTANCE:1]", "Hello World!")

Assert("Hello World!", ControlGetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]"))

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe") ; forgive me!
WEnd