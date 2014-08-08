#include "..\UIAWrappers.au3"
#include "Assert.au3"

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe") ; forgive me!
WEnd

$pid = Run("notepad.exe")
WinWait("Untitled - Notepad")
$hWnd = WinGetHandle("Untitled - Notepad")

$oNotepad = __UIA_ControlGetFromHwnd($hWnd)

AssertIsType($oNotepad, "Object")

While ProcessExists("notepad.exe")
	ProcessClose("notepad.exe") ; forgive me!
WEnd